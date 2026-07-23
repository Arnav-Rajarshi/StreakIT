import backend.database.crud as crud
from backend.models import (
    HabitLogCreate,
    HabitCreate,
    HabitConfig)
from backend.services import streak_service
from uuid import UUID, uuid4
import datetime

def logHabit(log: HabitLogCreate):

    if crud.habitLogExists(log.habit_id):
        crud.update_HabitLog(log)
    else:
        crud.insert_HabitLog(log)

    streak_service.refresh_habit_cache(log.habit_id)

    return {
        "message": "Habit logged successfully"
    }


def createHabit(user_id: UUID, habit: HabitCreate):

    config = HabitConfig(
        hid=uuid4(),
        user_id=user_id,
        habit_name=habit.habit_name,
        icon=habit.icon,
        color=habit.color,
        track_on=habit.track_on,
        minimum_days=habit.minimum_days,
        allowed_consecutive_misses=habit.allowed_consecutive_misses,
        target_duration_per_session=habit.target_duration_per_session,
        is_active=True,
        created_at=datetime.datetime.now()
    )

    crud.create_HabitConfigAndCache(config)

    return {
        "message": "Habit created successfully",
        "habit_id": config.hid
    }


def deleteHabit(hid):

    crud.delete_Habit(hid)

    return {
        "message": "Habit deleted successfully"
    }