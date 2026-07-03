from uuid import UUID

from database.db import get_connection
import psycopg

def get_current_streak(hid:UUID) -> int:
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT current_streak FROM habit_cache WHERE habit_id = %s;", (hid,))
            result = cur.fetchone()
            print(result)
            

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
