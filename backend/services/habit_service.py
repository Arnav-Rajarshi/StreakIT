import backend.database.crud as crud
from backend.models import HabitLogCreate
from backend.services import streak_service

def logHabit(log: HabitLogCreate):

    if crud.habitLogExists(log.habit_id):
        crud.update_HabitLog(log)
    else:
        crud.insert_HabitLog(log)

    streak_service.refresh_habit_cache(log.habit_id)

    return {
        "message": "Habit logged successfully"
    }