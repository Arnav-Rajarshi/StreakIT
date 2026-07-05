from database import crud_db , db
import auth
 

def validate_user(password: str, user_name: str = None, email: str = None) -> bool:
    with db.get_connection() as conn:
        with conn.cursor() as cur:
            if user_name:
                user = crud_db.read_UserDetails(user_name=user_name)
            elif email:
                user = crud_db.read_UserDetails(email=email)
            else:
                return False
            if user and auth.verify_password(password, user.encrypted_password):
                return True
    return False

"""
print(validate_user("password123", user_name="mock1"))
print(validate_user("password456", email="mock2@example.com"))
"""

username="mock1"
password="password123"
habit_name = "Daily Reading"

def main():
    if validate_user(password, user_name=username):
        global user
        user=crud_db.read_UserDetails(user_name=username)
        print(f"User {username} validated successfully.")
        global habit_config
        habit_config = crud_db.read_HabitConfig(user.uid, habit_name)

        if habit_config:

            print(f"Habit Config for '{habit_name}': {habit_config}")
            print("-*-"*25)
            
            habit_cache = crud_db.read_HabitCache(habit_config.hid) 
            if habit_cache:
               print(f"Habit Cache for '{habit_name}': {habit_cache}")
            else:
                print(f"No Habit Cache found for '{habit_name}'.")
        
        else:
            print(f"No Habit Config found for '{habit_name}'.")

    else:
        print(f"User {username} validation failed.")

main()


