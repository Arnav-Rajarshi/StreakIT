import datetime
from pydantic import BaseModel
from uuid import UUID


class HabitCache(BaseModel):
    habit_id: UUID
    current_streak: int
    best_streak: int
    total_sessions: int
    total_duration: int
    last_completed_date: datetime.date
    last_cache_update: datetime.datetime
    curr_streak_start_date: datetime.date


class HabitConfig(BaseModel):
    hid: UUID
    user_id: UUID
    habit_name: str
    icon: str
    color: str
    track_on: list[int]
    minimum_days: int
    target_duration_per_session: int
    is_active: bool
    created_at: datetime.datetime


class HabitLogs(BaseModel):
    log_id: UUID
    habit_id: UUID
    date: datetime.date
    started_at: datetime.datetime
    ended_at: datetime.datetime
    duration: int
    completed: bool
    scheduled: bool

class User(BaseModel):
    uid: UUID
    user_name: str
    email: str
    encrypted_password: str
    created_at: datetime.datetime