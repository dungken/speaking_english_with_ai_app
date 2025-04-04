import jwt
from datetime import datetime, timedelta
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from app.config.database import db
from bson import ObjectId
import os
# Makes a JWT token after login.

SECRET_KEY = os.getenv("JWT_SECRET")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# OAuth2 scheme for token authentication (points to the login endpoint)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/users/login")


#input  "sub" : {userid} as input
#output jwt token
def create_access_token(data: dict):
    """
    Generate a JWT access token with an expiration time.
    
    Args:
        data (dict): Dictionary containing the data to encode in the token.
            Sample input:
            {
                "sub": "507f1f77bcf86cd799439011"  # user ID
            }
    
    Returns:
        str: The encoded JWT token.
            Sample output:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MDdmMWY3N2JjZjg2Y2Q3OTk0MzkwMTEiLCJleHAiOjE3MTIyMjQwMDB9.xyz..."
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)  



# Verifies the token and gets the user for protected routes.
# input: authenticated token from header 
# ouput: return user object
def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Verify the JWT token and retrieve the current user's information.
    
    Args:
        token (str): The JWT token from the request header.
            Sample input:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MDdmMWY3N2JjZjg2Y2Q3OTk0MzkwMTEiLCJleHAiOjE3MTIyMjQwMDB9.xyz..."
    
    Returns:
        dict: The current user's information from the database.
            Sample output:
            {
                "_id": "507f1f77bcf86cd799439011",
                "name": "John Doe",
                "email": "john@example.com",
                "password_hash": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/vYBxLri"
            }
        
    Raises:
        HTTPException: If the token is invalid (401) or the user is not found (401).
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        user = db.users.find_one({"_id": ObjectId(user_id)})
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")