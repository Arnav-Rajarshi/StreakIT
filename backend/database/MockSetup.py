import os
import datetime
import psycopg
import backend.services.auth_service as auth_service
from dotenv import load_dotenv
from backend.database.db import get_connection

# to cheeck if a connection is established 
"""
with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version();")
        print(cur.fetchone())
"""

# to insert mock users into the database and check if they are inserted correctly
"""
with get_connection() as conn:
    with conn.cursor() as cur:
        cur.executemany(
            "INSERT INTO users (user_name, email , pass , created_at) VALUES (%s, %s , %s ,LOCALTIMESTAMP);",
            [
                ("mock1", "mock1@example.com", auth.hash_password("password123")),
                ("mock2", "mock2@example.com", auth.hash_password("password456")),
                ("mock3", "mock3@example.com", auth.hash_password("password789")),
                ("mock4", "mock4@example.com", auth.hash_password("password101112")),
                ("mock5", "mock5@example.com", auth.hash_password("password131415")),
            ]
        )
    conn.commit()

with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM users;")
        rows = cur.fetchall()
        for row in rows:
            print(row)
            print('')
"""

# to insert mock habit_config data into the database and check if they are inserted correctly
'''
habit_config_rows = [
    ["mock1", "Morning Run", "running-shoe", "#FF6B6B", [1, 3, 5], 4, 30, True],
    ["mock1", "Daily Reading", "book-open", "#4ECDC4", [0, 1, 2, 3, 4], 5, 25, True],
    ["mock1", "Water Intake", "water-drop", "#5D8AA8", [0, 2, 4, 6], 3, 150, True],
    ["mock2", "Evening Yoga", "lotus-flower", "#556B2F", [1, 3, 5], 3, 200, True],
    ["mock2", "Code Practice", "code", "#1E90FF", [1, 2, 3, 4, 5], 5, 45, True],
    ["mock2", "Sleep Tracking", "moon", "#483D8B", [0, 1, 2, 3, 4, 5, 6], 7, 100, True],
    ["mock3", "Meditation", "meditation", "#FFB347", [0, 2, 4, 6], 4, 15, True],
    ["mock3", "Healthy Meals", "salad", "#8FBC8F", [0, 1, 2, 3, 4, 5], 6, 30, True],
    ["mock3", "Language Practice", "language", "#B22222", [1, 3, 5], 3, 20, True],
    ["mock4", "Strength Training", "dumbbell", "#2F4F4F", [1, 4, 6], 3, 40, True],
    ["mock4", "Stretch Breaks", "stretch", "#9ACD32", [1, 2, 3, 4, 5], 5, 10, True],
    ["mock4", "Budget Review", "wallet", "#DAA520", [0, 3, 6], 3, 15, True],
    ["mock5", "Journal", "journal", "#FF69B4", [0, 1, 2, 3, 4], 5, 20, True],
    ["mock5", "Guitar Practice", "guitar", "#228B22", [2, 4, 6], 3, 30, True],
    ["mock5", "Weekly Planning", "calendar", "#4169E1", [6], 1, 60, False],
]

with get_connection() as conn:
    with conn.cursor() as cur:
        for user_name, habit_name, icon, color, track_on, minimum_days, target_duration_per_session, is_active in habit_config_rows:

            cur.execute(
                "SELECT uid FROM users WHERE user_name = %s;",
                (user_name,)
            )

            user_id_record = cur.fetchone()

            if user_id_record is None:
                print(f"Skipping habit for missing user {user_name}")
                continue

            cur.execute(
                "INSERT INTO habit_config (user_id, habit_name, icon, color, track_on, minimum_days, target_duration_per_session, is_active) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s);",
                (
                    user_id_record[0],
                    habit_name,
                    icon,
                    color,
                    track_on,
                    minimum_days,
                    target_duration_per_session,
                    is_active,
                ),
            )
    conn.commit()

'''


# to update the target_duration_per_session for habits with a value less than or equal to 20
'''

with get_connection() as conn:
    print('connection established')
    with conn.cursor() as cur:
        print('cursor opened')
        cur.execute(
            "select * from habit_config where target_duration_per_session <= 20"
        )
        result = cur.fetchall()
        for row in result:
            print(row)
            print("The target duration is too low")
            new=int(input("enter how many minutes you want to set as a target: (in minutes > 20)  "))
            hid=row[0]
            print(f"Updating habit {row[2]} with new target duration: {new}")
            cur.execute(
                    "update habit_config set target_duration_per_session = %s where hid = %s", (new, hid)
                )
      
'''


# to insert mock habit_cache data into the database and check if they are inserted correctly
"""
with get_connection() as conn:
    with conn.cursor() as cur:
        habit_cache_rows = [
            ("mock1", "Morning Run", 3, 5, 12, 360, datetime.datetime.now(), datetime.date(2026, 6, 30)),
            ("mock1", "Daily Reading", 5, 7, 20, 500, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 6, 29)),
            ("mock1", "Water Intake", 6, 9, 25, 3750, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 6, 29)),
            ("mock2", "Evening Yoga", 4, 6, 14, 2800, datetime.date(2026, 7, 4), datetime.datetime.now(), datetime.date(2026, 7, 1)),
            ("mock2", "Code Practice", 5, 8, 18, 810, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 6, 28)),
            ("mock2", "Sleep Tracking", 7, 10, 24, 2400, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 6, 27)),
            ("mock3", "Meditation", 4, 6, 16, 240, datetime.date(2026, 7, 4), datetime.datetime.now(), datetime.date(2026, 7, 1)),
            ("mock3", "Healthy Meals", 5, 7, 18, 540, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 6, 29)),
            ("mock3", "Language Practice", 3, 5, 12, 240, datetime.date(2026, 7, 4), datetime.datetime.now(), datetime.date(2026, 7, 2)),
            ("mock4", "Strength Training", 2, 4, 10, 400, datetime.date(2026, 7, 3), datetime.datetime.now(), datetime.date(2026, 7, 1)),
            ("mock4", "Stretch Breaks", 5, 7, 20, 200, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 7, 1)),
            ("mock4", "Budget Review", 1, 2, 6, 90, datetime.date(2026, 7, 3), datetime.datetime.now(), datetime.date(2026, 7, 3)),
            ("mock5", "Journal", 4, 6, 18, 360, datetime.date(2026, 7, 5), datetime.datetime.now(), datetime.date(2026, 7, 1)),
            ("mock5", "Guitar Practice", 3, 5, 15, 450, datetime.date(2026, 7, 4), datetime.datetime.now(), datetime.date(2026, 7, 2)),
            ("mock5", "Weekly Planning", 0, 1, 2, 120, datetime.date(2026, 6, 28), datetime.datetime.now(), datetime.date(2026, 6, 28)),
        ]

        for user_name, habit_name, current_streak, best_streak, total_sessions, total_duration, last_completed_date, last_cache_update, curr_streak_start_date in habit_cache_rows:
            cur.execute(
                "SELECT c.hid FROM habit_config c JOIN users u ON c.user_id = u.uid WHERE u.user_name = %s AND c.habit_name = %s",
                (user_name, habit_name),
            )
            habit_id_record = cur.fetchone()
            if habit_id_record is None:
                print(f"Skipping habit_cache insert for missing habit {habit_name} of user {user_name}")
                continue

            cur.execute(
                "INSERT INTO habit_cache (habit_id, current_streak, best_streak, total_sessions, total_duration, last_completed_date, last_cache_update, curr_streak_start_date) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                (
                    habit_id_record[0],
                    current_streak,
                    best_streak,
                    total_sessions,
                    total_duration,
                    last_completed_date,
                    last_cache_update,
                    curr_streak_start_date,
                ),
            )
    conn.commit()

"""


# to insert mock habit_logs data into the database and check if they are inserted correctly
"""
import csv
import os
from db import get_connection

CSV_PATH = os.path.join(os.path.dirname(__file__), "habit_log_mocks.csv")

with open(CSV_PATH, newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    with get_connection() as conn:
        with conn.cursor() as cur:
            for row in reader:
                cur.execute(
                    "SELECT c.hid FROM habit_config c JOIN users u ON c.user_id = u.uid WHERE u.user_name = %s AND c.habit_name = %s",
                    (row["user_name"], row["habit_name"]),
                )
                habit_id_record = cur.fetchone()
                if habit_id_record is None:
                    print(f"Skipping habit_logs insert for missing habit {row['habit_name']} of user {row['user_name']}")
                    continue

                cur.execute(
                    "INSERT INTO habit_logs (habit_id, date, started_at, ended_at, duration, completed, scheduled) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s)",
                    (
                        habit_id_record[0],
                        row["date"],
                        row["started_at"],
                        row["ended_at"],
                        int(row["duration"]),
                        row["completed"].strip().lower() == "true",
                        row["scheduled"].strip().lower() == "true",
                    ),
                )
            conn.commit()

print(f"Inserted habit_logs from {CSV_PATH}")

"""