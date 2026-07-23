from uuid import UUID

from fastapi import FastAPI, HTTPException

from fastapi.middleware.cors import CORSMiddleware

from backend.models import (
    LoginRequest,
    UserCreate,
    HabitCreate,
    #HabitUpdate,
    HabitLogCreate,
    TodaysHabits,
    DashboardPage,
)

from backend.services import (
    auth_service,
    today_service,
    dashboard_service,
    habit_service,
)

app = FastAPI(
    title="StreakIT API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or ["*"] during development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =============================
# Authentication
# =============================
@app.post("/signup")
def signup(user: UserCreate):
    # Ensure create_user returns the newly inserted user DB object/dict
    new_user = auth_service.create_user(user)

    return {
        "message": "Account created successfully",
        "uid": str(new_user["uid"]),       # or new_user.uid if it's an ORM/Pydantic model
        "user_name": str(new_user["user_name"]) # or new_user.user_name
    }

@app.post("/login")
def login(credentials: LoginRequest):

    user = auth_service.validate_user(
    password=credentials.password,
    user_details=credentials.user_details
    )

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    return {
        "message": "Login Successful",
        "uid": str(user["uid"]),
        "user_name":str(user["user_name"])
    }


# =============================
# Home
# =============================

@app.get("/today", response_model=list[TodaysHabits])
def today(uid: UUID):
    return today_service.getTodayPage(uid)


# =============================
# Dashboard
# =============================

@app.get("/dashboard", response_model=DashboardPage)
def dashboard(uid: UUID):

    return dashboard_service.getDashboardPage(uid)


# =============================
# Habits
# =============================

@app.post("/habits/{uid}")
def create_habit(uid: UUID, habit: HabitCreate):

    return habit_service.createHabit(uid, habit)

"""
@app.put("/habits/{hid}")
def update_habit(hid: UUID, habit: HabitUpdate):

    return habit_service.updateHabit(hid, habit)
"""

@app.delete("/habits/{hid}")
def delete_habit(hid: UUID):

    return habit_service.deleteHabit(hid)


# =============================
# Habit Logging
# =============================

@app.post("/habit-log")
def log_habit(log: HabitLogCreate):

    return habit_service.logHabit(log)