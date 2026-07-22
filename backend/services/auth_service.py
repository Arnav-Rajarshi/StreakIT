import bcrypt
from backend.database import crud, db
from backend.database.db import get_connection
import psycopg

def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw (
        password.encode(),
        hashed.encode() 
        )

def create_user(user):
    # Hash the password before storing it
    hashed_password = hash_password(user.password)
    user_data = {
        "user_name": user.user_name,
        "email": user.email,
        "encrypted_password": hashed_password
    }
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO users (user_name, email, encrypted_password)
                VALUES (%(user_name)s, %(email)s, %(encrypted_password)s)
                """,
                user_data
            )


def validate_user(password: str, user_details: str):
    with db.get_connection() as conn:
        with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:

            cur.execute("""
                SELECT uid, encrypted_password , user_name
                FROM users
                WHERE email = %s
                   OR user_name = %s
            """, (user_details, user_details))

            user = cur.fetchone()

            if user is None:
                return None

            stored_hash = user["encrypted_password"]

            if not bcrypt.checkpw(
                password.encode("utf-8"),
                stored_hash.encode("utf-8")
            ):
                return None

            return user