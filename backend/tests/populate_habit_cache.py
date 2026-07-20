from backend.services.streak_service import refresh_habit_cache
from backend.database.db import get_connection

with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT hid FROM habit_config")

        for (hid,) in cur.fetchall():
            refresh_habit_cache(hid)

print("Done.")