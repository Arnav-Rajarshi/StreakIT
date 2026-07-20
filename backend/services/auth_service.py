import bcrypt
from backend.database import crud, db
from backend.database.db import get_connection

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


def validate_user(password: str, user_name: str = None, email: str = None) -> bool:
    with db.get_connection() as conn:
        with conn.cursor() as cur:
            if user_name:
                user = crud.read_UserDetails(user_name=user_name)
            elif email:
                user = crud.read_UserDetails(email=email)
            else:
                return False
            if user and verify_password(password, user.encrypted_password):
                return True
    return False