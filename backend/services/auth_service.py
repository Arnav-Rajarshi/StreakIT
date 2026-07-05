import bcrypt

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

