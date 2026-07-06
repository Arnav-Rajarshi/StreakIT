from uuid import UUID
from backend.database.db import get_connection
import psycopg
import backend.models as models

def read_HabitConfigs(hid)->models.HabitConfig: 
    with get_connection() as conn: 
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur: 
            cur.execute( "SELECT * FROM habit_config WHERE user_id = %s", (hid,) ) 
            result=cur.fetchone() 
            if result: 
                return models.HabitConfig(**result) 
    return None

def read_HabitConfigs(uid) -> list[models.HabitConfig]:
    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            cur.execute(
                """
                SELECT *
                FROM habit_config
                WHERE user_id = %s
                """,
                (uid,)
            )

            results = cur.fetchall()
            if results:
                return [
                    models.HabitConfig(**row)
                    for row in results
                ]
            else:
                print("No habits for this user")
                return None
    return None

def read_HabitCache(hid:UUID)->models.HabitCache:
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

def read_UserDetails(user_name=None , email=None)->models.User:
    with get_connection() as conn:
        print("connection established")
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
            if user_name:
                cur.execute(
                    "SELECT * FROM users WHERE user_name = %s",
                    (user_name,)
                )
                print("query executed")
            elif email:
                cur.execute(
                    "SELECT * FROM users WHERE email = %s",
                    (email,)
                )
                print("query executed")
            else:
                return None
                print("returning None")
            
            result=cur.fetchone()
            print(result)
            if result:
                return models.User(**result)
    return None


def create_HabitConfigAndCache(HabitConfig: models.HabitConfig):
    '''This function inserts habit_config into the database.Also insert a corresponding habit_cache entry with default values '''

    with get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:

            data = HabitConfig.model_dump()  # Convert the HabitConfig object to a dictionary
            cur.execute(
                """ 
                INSERT INTO habit_config 
                (
                    hid, 
                    user_id, 
                    habit_name, 
                    icon, 
                    color, 
                    track_on, 
                    minimum_days, 
                    target_duration_per_session, 
                    is_active, 
                    created_at
                ) 
                VALUES 
                (
                    %(hid)s, 
                    %(user_id)s, 
                    %(habit_name)s, 
                    %(icon)s, %(color)s, 
                    %(track_on)s, 
                    %(minimum_days)s, 
                    %(target_duration_per_session)s, 
                    %(is_active)s, %(created_at)s
                )
                """
                ,data
            ) 
            # psycopg natively maps the dicts key value pairs with its corresponding columns 

            # inserting default row in habit_cache for the newly created habit_config
            cur.execute(
                "INSERT INTO habit_cache (habit_id, current_streak, best_streak, total_sessions, total_duration, last_completed_date, curr_streak_start_date) VALUES (%(habit_id)s, %(current_streak)s, %(best_streak)s, %(total_sessions)s, %(total_duration)s, %(last_completed_date)s, %(curr_streak_start_date)s)",
                {
                    "habit_id":data['hid'],
                    "current_streak": 0,
                    "best_streak": 0,
                    "total_sessions": 0,
                    "total_duration": 0,
                    "last_completed_date": None,
                    # database will insert last_cache_update as current timestamp by default 
                    "curr_streak_start_date": None
                }
            )
        conn.commit()

def update_HabitCache(habit_cache: models.HabitCache):
    ...



