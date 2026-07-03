from database.db import get_connection
import auth

def validate_user(entered_password:str,username:str=None ,email:str=None)->bool:
    with get_connection() as conn:
        with conn.cursor() as cur:
            if username:
                cur.execute(t"SELECT pass FROM users WHERE user_name = {username};")
            elif email:
                cur.execute(t"SELECT pass FROM users WHERE email = {email};")
            result = cur.fetchone()
            try:
                hashed_passsword = result[0]
                if auth.verify_password(entered_password, hashed_passsword):
                    return True
            except:
                print("Verification failed: User not found or password is incorrect.")
                return False
            
"""
print(validate_user("password123", username="mock1"))
print(validate_user("password456", email="mock2@example.com"))
"""