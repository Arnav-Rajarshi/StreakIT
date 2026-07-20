from datetime import date

from backend.services.streak_service import HabitLogRecord, calculate_current_streak


def test_calculate_current_streak_breaks_after_consecutive_misses() -> None:
    logs = [
        HabitLogRecord(date=date(2024, 1, 1), scheduled=True, completed=True, duration=20),
        HabitLogRecord(date=date(2024, 1, 2), scheduled=True, completed=False, duration=0),
        HabitLogRecord(date=date(2024, 1, 3), scheduled=True, completed=False, duration=0),
        HabitLogRecord(date=date(2024, 1, 4), scheduled=True, completed=True, duration=25),
    ]

    state = calculate_current_streak(
        logs=logs,
        minimum_days=1,
        allowed_consecutive_misses=1,
    )

    assert state.current_streak == 1
    assert state.best_streak == 1
    assert state.last_streak_break_date == date(2024, 1, 3)
    assert state.curr_streak_start_date == date(2024, 1, 4)
    assert state.total_sessions == 2
    assert state.total_duration == 45

