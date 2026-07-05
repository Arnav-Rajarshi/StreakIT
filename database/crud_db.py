from uuid import UUID
from database.db import get_connection
import psycopg
import models

def get_HabitConfig(uid, HabitName:str)->models.HabitConfig:
    with get_connection() as conn: 
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                "SELECT hid, user_id, habit_name, icon, color, track_on, minimum_days, target_duration_per_session, is_active, created_at FROM habit_config WHERE user_id = %s AND habit_name = %s",
                (uid, HabitName)
            )
            result=cur.fetchone()
            if result:
                return models.HabitConfig(**result)
    return None


def get_HabitCache(hid:UUID)->models.HabitCache:
    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                "SELECT habit_id, current_streak, best_streak, total_sessions, total_duration, last_completed_date, last_cache_update, curr_streak_start_date FROM habit_cache WHERE habit_id = %s",
                (str(hid),)
            )
            result=cur.fetchone()
            if result:
                return models.HabitCache(**result)
    return None


def get_UserDetails(user_name=None , email=None)->models.User:
    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            if user_name:
                cur.execute(
                    "SELECT * FROM users WHERE user_name = %s",
                    (user_name,)
                )
            elif email:
                cur.execute(
                    "SELECT * FROM users WHERE email = %s",
                    (email,)
                )
            else:
                return None
            
            result=cur.fetchone()
            #print(result)
            if result:
                return models.User(**result)
    return None


def post_HabitConfig(habit_config: models.HabitConfig):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO habit_config (hid, user_id, habit_name, icon, color, track_on, minimum_days, target_duration_per_session, is_active, created_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                (
                    str(habit_config.hid),        #psycopg auto converts this string to the expected dtype i.e UUID 
                    str(habit_config.user_id),
                    habit_config.habit_name,
                    habit_config.icon,
                    habit_config.color,
                    habit_config.track_on,
                    habit_config.minimum_days,
                    habit_config.target_duration_per_session,
                    habit_config.is_active,
                    habit_config.created_at
                )
            )
        conn.commit()



