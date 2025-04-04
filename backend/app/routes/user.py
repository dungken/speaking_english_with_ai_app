from fastapi import APIRouter, HTTPException
from app.config.database import db
from app.schemas.user import UserCreate, UserResponse
from app.utils.security import hash_password, verify_password
from app.models.user import User
from app.utils.auth import create_access_token
from pydantic import BaseModel, EmailStr
from bson import ObjectId
from app.schemas.user import UserLogin

router = APIRouter()


@router.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate):
    """
    Register a new user in the system.
    
    Args:
        user (UserCreate): User registration data containing name, email, and password.
            Sample input:
            {
                "name": "John Doe",
                "email": "john@example.com",
                "password": "securepassword123"
            }
        
    Returns:
        UserResponse: The created user's information (excluding password hash).
            Sample output:
            {
                "id": "507f1f77bcf86cd799439011",
                "name": "John Doe",
                "email": "john@example.com",
                "created_at": "2024-04-04T12:00:00"
            }
        
    Raises:
        HTTPException: If the email is already registered (400) or other registration errors occur.
    """
    if db.users.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email already registered")
    password_hash = hash_password(user.password)
    new_user = User(name=user.name, email=user.email, password_hash=password_hash)
    result = db.users.insert_one(new_user.to_dict())
    created_user = db.users.find_one({"_id": result.inserted_id})
    return UserResponse(**created_user)


@router.post("/login")
async def login_user(login_data: UserLogin):
    """
    Authenticate a user and generate an access token.
    
    Args:
        login_data (UserLogin): User login credentials containing email and password.
            Sample input:
            {
                "email": "john@example.com",
                "password": "securepassword123"
            }
        
    Returns:
        dict: A dictionary containing the access token and token type.
            Sample output:
            {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer"
            }
        
    Raises:
        HTTPException: If the email/password combination is invalid (401).
    """
    user = db.users.find_one({"email": login_data.email})
    if not user or not verify_password(login_data.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    # Generate JWT token with user ID
    access_token = create_access_token(data={"sub": str(user["_id"])})
    return {"access_token": access_token, "token_type": "bearer"}