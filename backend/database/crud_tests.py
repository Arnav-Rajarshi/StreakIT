# Testing get_streak function()
from backend.database.crud import get_current_streak
from backend.database.db import get_connection


with get_connection() as conn:
    print('connection established')
    with conn.cursor() as cur:
        cur.execute(
            "select hid from habit_config where habit_name = 'Meditation' "
        )
        print('cursor opened')
        result = cur.fetchone()
        print(result)
        if result:
            hid = result[0]
            get_current_streak(hid)
        else:
            print("Habit 'Meditation' not found in habit_config.")
