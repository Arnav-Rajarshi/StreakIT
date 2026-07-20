from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from typing import Sequence
from uuid import UUID

import psycopg

import backend.models as models
from backend.database.db import get_connection


@dataclass(slots=True)
class HabitLogRecord:
    """A light-weight representation of one habit log row for replay."""

    date: date
    scheduled: bool
    completed: bool
    duration: int = 0


@dataclass(slots=True)
class ReplayState:
    """Mutable replay state used while rebuilding streak metrics from logs."""

    current_streak: int = 0
    best_streak: int = 0
    consecutive_misses: int = 0
    weekly_misses: int = 0
    curr_streak_start_date: date | None = None
    last_streak_break_date: date | None = None
    current_week: int | None = None
    total_sessions: int = 0
    total_duration: int = 0
 


def calculate_current_streak(
    logs: Sequence[HabitLogRecord],
    scheduled_days_per_week : int,
    minimum_days: int,
    allowed_consecutive_misses: int,
    state: ReplayState | None = None,
    recompute_from_date: date | None = None,
) -> ReplayState:
    """Replay habit logs in chronological order and rebuild streak state."""

    replay_state = state or ReplayState()
    ordered_logs = _filter_logs_for_replay(logs, recompute_from_date)

    for log in ordered_logs:
        _advance_week_if_needed(replay_state, log.date)

        if log.completed:
            _handle_completion(replay_state, log)
            continue

        if log.scheduled:
            _handle_scheduled_miss(replay_state, log, scheduled_days_per_week, minimum_days, allowed_consecutive_misses)

    return replay_state


def refresh_habit_cache(hid: UUID) -> models.HabitCache:
    """Rebuild the cache row from the authoritative habit_logs table."""

    config_row = _read_habit_config(hid)
    if config_row is None:
        raise ValueError(f"Habit config for {hid} was not found")

    minimum_days = int(config_row.get("minimum_days", 0))
    scheduled_days_per_week= len(config_row.get("track_on",[]))
    allowed_consecutive_misses = int(config_row.get("allowed_consecutive_misses", 0))

    logs = _read_habit_logs(hid)
    recompute_from_date = _read_recompute_from_date(hid)

    replay_state = calculate_current_streak(
        logs=logs,
        scheduled_days_per_week=scheduled_days_per_week,
        minimum_days=minimum_days,
        allowed_consecutive_misses=allowed_consecutive_misses,
        recompute_from_date=recompute_from_date,
    )

    cache_row = models.HabitCache(
        habit_id=hid,
        current_streak=replay_state.current_streak,
        best_streak=replay_state.best_streak,
        total_sessions=replay_state.total_sessions,
        total_duration=replay_state.total_duration,
        last_cache_update=datetime.utcnow(),
        curr_streak_start_date=replay_state.curr_streak_start_date,
        recompute_from_date=recompute_from_date,
        last_streak_break_date=replay_state.last_streak_break_date,
    )

    _upsert_habit_cache(cache_row)
    return cache_row


def _filter_logs_for_replay(
    logs: Sequence[HabitLogRecord],
    recompute_from_date: date | None,
) -> list[HabitLogRecord]:
    """Return logs in chronological order, optionally starting from a replay window."""

    ordered_logs = sorted(logs, key=lambda item: item.date)
    if recompute_from_date is None:
        return ordered_logs

    return [log for log in ordered_logs if log.date >= recompute_from_date]


def _advance_week_if_needed(state: ReplayState, log_date: date) -> None:
    """Reset weekly-miss tracking whenever the ISO week changes."""

    week_key = log_date.isocalendar().week
    if state.current_week is None or week_key != state.current_week:
        state.weekly_misses = 0
        state.current_week = week_key


def _handle_completion(state: ReplayState, log: HabitLogRecord) -> None:
    """Treat every completed row as a successful session that should advance the streak."""

    state.consecutive_misses = 0
    state.total_sessions += 1
    state.total_duration += log.duration

    if state.current_streak == 0:
        state.current_streak = 1
        state.curr_streak_start_date = log.date
    else:
        state.current_streak += 1

    state.best_streak = max(state.best_streak, state.current_streak)


def _handle_scheduled_miss(
    state: ReplayState,
    log: HabitLogRecord,
    scheduled_days_per_week : int,
    minimum_days: int,
    allowed_consecutive_misses: int,
) -> None:
    """Apply the miss rules for scheduled days and break the streak when needed."""

    allowed_weekly_misses = max(0, scheduled_days_per_week - minimum_days)
    state.consecutive_misses += 1
    state.weekly_misses += 1

    if state.consecutive_misses > allowed_consecutive_misses:
        _break_streak(state, log.date)
        return

    if state.weekly_misses > allowed_weekly_misses:
        _break_streak(state, log.date)


def _break_streak(state: ReplayState, break_date: date) -> None:
    """Reset the active streak when the miss rules are exceeded."""

    state.current_streak = 0
    state.curr_streak_start_date=None
    state.last_streak_break_date = break_date


def _read_habit_config(hid: UUID) -> dict | None:
    """Read the habit configuration needed for replay rules."""

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                "SELECT hid, track_on , minimum_days, allowed_consecutive_misses FROM habit_config WHERE hid = %s",
                (str(hid),),
            )
            return cur.fetchone()


def _read_habit_logs(hid: UUID) -> list[HabitLogRecord]:
    """Load habit logs from the database as replay-friendly records."""

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                """
                SELECT date, scheduled, completed, duration
                FROM habit_logs
                WHERE habit_id = %s
                ORDER BY date ASC
                """,
                (str(hid),),
            )
            rows = cur.fetchall()

    return [
        HabitLogRecord(
            date=row["date"],
            scheduled=bool(row.get("scheduled", False)),
            completed=bool(row.get("completed", False)),
            duration=int(row.get("duration") or 0),
        )
        for row in rows
    ]


def _read_recompute_from_date(hid: UUID) -> date | None:
    """Read the replay start date if the column is available."""

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            try:
                cur.execute(
                    "SELECT recompute_from_date FROM habit_cache WHERE habit_id = %s",
                    (str(hid),),
                )
                row = cur.fetchone()
                if row:
                    return row.get("recompute_from_date")
            except psycopg.Error:
                return None

    return None


def _upsert_habit_cache(cache: models.HabitCache) -> None:
    """Persist the fully recomputed cache row back to the database."""

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO habit_cache (
                    habit_id,
                    current_streak,
                    best_streak,
                    total_sessions,
                    total_duration,
                    curr_streak_start_date,
                    recompute_from_date,
                    last_streak_break_date,
                    last_cache_update
                )
                VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
                ON CONFLICT (habit_id) DO UPDATE SET
                    current_streak = EXCLUDED.current_streak,
                    best_streak = EXCLUDED.best_streak,
                    total_sessions = EXCLUDED.total_sessions,
                    total_duration = EXCLUDED.total_duration,
                    curr_streak_start_date = EXCLUDED.curr_streak_start_date,
                    recompute_from_date = EXCLUDED.recompute_from_date,
                    last_streak_break_date = EXCLUDED.last_streak_break_date,
                    last_cache_update = EXCLUDED.last_cache_update
                """,
                (
                    str(cache.habit_id),
                    cache.current_streak,
                    cache.best_streak,
                    cache.total_sessions,
                    cache.total_duration,
                    cache.curr_streak_start_date,
                    cache.recompute_from_date,
                    cache.last_streak_break_date,
                    cache.last_cache_update,
                ),
            )
        conn.commit()
