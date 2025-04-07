from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from app.config.database import db
from app.schemas.user import UserCreate, UserResponse, UserLogin, UserUpdate, UserRegisterResponse
from app.utils.security import hash_password, verify_password
from app.models.user import User
from app.utils.auth import create_access_token, get_current_user
from bson import ObjectId
from typing import List, Optional
from datetime import datetime, timedelta
from jose import JWTError, jwt
import bcrypt
import os
from dotenv import load_dotenv
from pydantic import BaseModel

# Load environment variables
load_dotenv()

router = APIRouter()

# JWT configuration from environment variables
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

if not SECRET_KEY:
    raise ValueError("JWT_SECRET_KEY environment variable is not set")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/users/login")

@router.post("/register", response_model=UserRegisterResponse, status_code=status.HTTP_201_CREATED)
async def register_user(user: UserCreate):
    """
    Register a new user and return an authentication token.
    
    Args:
        user (UserCreate): User registration data.
            Sample input:
            {
                "name": "John Doe",
                "email": "john@example.com",
                "password": "SecurePassword123!"
            }
    
    Returns:
        UserRegisterResponse: User information and authentication token.
            Sample output:
            {
                "id": "507f1f77bcf86cd799439011",
                "name": "John Doe",
                "email": "john@example.com",
                "role": "user",
                "created_at": "2024-04-04T12:00:00",
                "updated_at": "2024-04-04T12:00:00",
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer"
            }
    """
    try:
        # Check if email already exists
        existing_user = db.users.find_one({"email": user.email})
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Hash password using bcrypt directly
        salt = bcrypt.gensalt()
        hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), salt)
        
        # Create user document
        user_data = {
            "name": user.name,
            "email": user.email,
            "password": hashed_password.decode('utf-8'),
            "role": "user",
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        
        # Insert user and get the inserted ID
        result = db.users.insert_one(user_data)
        user_data["_id"] = result.inserted_id
        
        # Create access token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email}, expires_delta=access_token_expires
        )
        
        # Add token to response
        user_data["access_token"] = access_token
        user_data["token_type"] = "bearer"
        
        # Convert to response model
        return UserRegisterResponse(**user_data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.post("/login")
async def login(login_data: UserLogin):
    """
    Authenticate a user and return an access token.
    
    Args:
        login_data (UserLogin): Login credentials.
            Sample input:
            {
                "email": "john@example.com",
                "password": "SecurePassword123!"
            }
    
    Returns:
        dict: Authentication token and user information.
            Sample output:
            {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "user": {
                    "id": "507f1f77bcf86cd799439011",
                    "name": "John Doe",
                    "email": "john@example.com",
                    "role": "user",
                    "created_at": "2024-04-04T12:00:00",
                    "updated_at": "2024-04-04T12:00:00"
                }
            }
    """
    try:
        user = db.users.find_one({"email": login_data.email})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Verify password using bcrypt directly
        if not bcrypt.checkpw(login_data.password.encode('utf-8'), user["password"].encode('utf-8')):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user["email"]}, expires_delta=access_token_expires
        )
        
        # Convert user to response model
        user_response = UserResponse(
            _id=str(user["_id"]),
            email=user["email"],
            name=user["name"],
            role=user.get("role", "user"),
            created_at=user["created_at"],
            updated_at=user["updated_at"]
        )
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_response
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.get("/me", response_model=UserResponse)
async def get_user_profile():
    """
    Get user profile (testing version without authentication).
    
    Returns:
        UserResponse: The user profile information.
    """
    try:
        # For testing, get the first user from database
        user = db.users.find_one()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No users found in database"
            )
            
        return UserResponse(
            _id=str(user["_id"]),
            name=user["name"],
            email=user["email"],
            role=user.get("role", "user"),
            created_at=user["created_at"],
            updated_at=user["updated_at"],
            avatar_url=user.get("avatar_url")
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.put("/me", response_model=UserResponse)
async def update_user_profile(user_update: UserUpdate):
    """
    Update user profile (testing version without authentication).
    
    Args:
        user_update (UserUpdate): The user profile update data.
    
    Returns:
        UserResponse: The updated user profile information.
    """
    try:
        # For testing, update the first user in database
        user = db.users.find_one()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No users found in database"
            )
        
        # Prepare update data
        update_data = user_update.dict(exclude_unset=True)
        update_data["updated_at"] = datetime.utcnow()
        
        # Update user in database
        result = db.users.update_one(
            {"_id": user["_id"]},
            {"$set": update_data}
        )
        
        if result.modified_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Get updated user data
        updated_user = db.users.find_one({"_id": user["_id"]})
        
        return UserResponse(
            _id=str(updated_user["_id"]),
            name=updated_user["name"],
            email=updated_user["email"],
            role=updated_user.get("role", "user"),
            created_at=updated_user["created_at"],
            updated_at=updated_user["updated_at"],
            avatar_url=updated_user.get("avatar_url")
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user_profile(current_user: dict = Depends(get_current_user)):
    """
    Delete the current user's profile.
    
    Args:
        current_user (dict): The authenticated user's information.
    
    Returns:
        None: 204 No Content response.
    """
    try:
        # Delete user from database
        result = db.users.delete_one({"_id": current_user["_id"]})
        
        if result.deleted_count == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        return None
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.get("/list", response_model=List[UserResponse])
async def get_users():
    """
    Get a list of all users.
    
    Returns:
        List[UserResponse]: A list of all user objects.
            Sample output:
            [
                {
                    "id": "507f1f77bcf86cd799439011",
                    "name": "John Doe",
                    "email": "john@example.com",
                    "role": "user",
                    "avatar_url": null,
                    "created_at": "2024-04-04T12:00:00",
                    "updated_at": "2024-04-04T12:00:00"
                },
                ...
            ]
    """
    try:
        # Fetch all users from the database
        users = list(db.users.find())
        
        # Convert users to response model format
        user_responses = []
        for user in users:
            user_response = UserResponse(
                _id=str(user["_id"]),
                name=user["name"],
                email=user["email"],
                role=user.get("role", "user"),
                created_at=user["created_at"],
                updated_at=user["updated_at"],
                avatar_url=user.get("avatar_url")
            )
            user_responses.append(user_response)
        
        return user_responses
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )