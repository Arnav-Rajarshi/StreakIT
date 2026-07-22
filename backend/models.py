import datetime
from pydantic import BaseModel
from uuid import UUID

#------------------------------------------
# DATABASE MODELS
#------------------------------------------
class HabitCache(BaseModel):
    habit_id: UUID
    current_streak: int
    best_streak: int
    total_sessions: int
    total_duration: int
    last_cache_update: datetime.datetime
    curr_streak_start_date: datetime.date | None = None
    recompute_from_date: datetime.date | None = None
    last_streak_break_date: datetime.date | None = None


class HabitConfig(BaseModel):
    hid: UUID
    user_id: UUID
    habit_name: str
    icon: str
    color: str
    track_on: list[int]
    minimum_days: int
    allowed_consecutive_misses: int = 0
    target_duration_per_session: int
    is_active: bool
    created_at: datetime.datetime

class HabitLogs(BaseModel):
    log_id: UUID
    habit_id: UUID
    date: datetime.date
    started_at: datetime.time
    ended_at: datetime.time
    duration: int
    completed: bool
    scheduled: bool
    consistency_score: float


class User(BaseModel):
    uid: UUID
    user_name: str
    email: str
    encrypted_password: str
    created_at: datetime.datetime


#------------------------------------------
# API REQUEST MODELS
#------------------------------------------


class UserCreate(BaseModel):
    user_name: str
    email: str
    password: str

class LoginRequest(BaseModel):
    user_details: str
    password: str

class HabitLogCreate(BaseModel):
    habit_id: UUID
    started_at: datetime.time
    ended_at: datetime.time
    duration: int
    
#---------------------------------------
# API RESPONSE MODELS
#---------------------------------------


class TodaysHabits(BaseModel):
    config:HabitConfig
    cache:HabitCache
    completed:bool


class HeatmapData(BaseModel):
    habit_id: UUID
    date:datetime.date
    completed:bool
    scheduled:bool
    duration:int


class GraphData(BaseModel):
    habit_id: UUID
    date:datetime.date
    consistency_score: float


class SummaryData(BaseModel):
    HabitName: str
    HabitColor: str
    HabitIcon: str
    curr_streak: int
    best_streak: int
    avg_session_duration: float
    total_sessions: int
    total_duration: int
    td_week: int
    td_month: int
    td_year: int
    

class DashboardPage(BaseModel):
    HeatmapData:list[HeatmapData]
    GraphData:list[GraphData]
    SummaryData:list[SummaryData]
