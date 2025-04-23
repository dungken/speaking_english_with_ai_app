from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from app.config.database import db
from app.schemas.user import UserCreate, UserResponse, UserLogin, UserUpdate, UserRegisterResponse, Token
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


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    OAuth2 compatible token login, get an access token for future requests.
    
    Args:
        form_data (OAuth2PasswordRequestForm): OAuth2 form containing username (email) and password.
            Input fields:
            - username: User's email address
            - password: User's password
    
    Returns:
        Token: Access token information.
            Fields:
            - access_token: JWT token for authentication
            - token_type: Type of token (always "bearer")
            - expires_in: Token expiration time in seconds
            - scope: User permissions ("admin" or "user")
    """
    try:
        user = db.users.find_one({"email": form_data.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Verify password using bcrypt directly
        if not bcrypt.checkpw(form_data.password.encode('utf-8'), user["password"].encode('utf-8')):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Create token with role-based scope
        scopes = ["admin"] if user.get("role") == "admin" else ["user"]
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={
                "sub": user["email"],
                "scopes": scopes
            },
            expires_delta=access_token_expires
        )
        
        return Token(
            access_token=access_token,
            token_type="bearer",
            expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60,  # Convert to seconds
            scope=" ".join(scopes)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@router.get("/me", response_model=UserResponse)
async def get_user_profile(current_user: dict = Depends(get_current_user)):
    """
    Get current user's profile. Requires authentication token.
    
    Args:
        current_user (dict): The authenticated user's information from token.
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role ("admin" or "user")
    
    Returns:
        UserResponse: The user profile information.
            Fields:
            - _id: User's ObjectId as string
            - name: User's full name
            - email: User's email address
            - role: User's role ("admin" or "user")
            - created_at: Account creation timestamp
            - updated_at: Last update timestamp
            - avatar_url: URL to user's profile image (optional)
    """
    try:
        user = db.users.find_one({"_id": ObjectId(current_user["_id"])})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
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
async def update_user_profile(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_user)
):
    """
    Update current user's profile. Requires authentication token.
    Only allows updating specific fields and validates the changes.
    
    Args:
        user_update (UserUpdate): The user profile update data.
            Updatable fields:
            - name: User's full name
            - avatar_url: URL to user's profile image
        current_user (dict): The authenticated user's information.
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
    
    Returns:
        UserResponse: The updated user profile information.
            Fields:
            - _id: User's ObjectId as string
            - name: User's updated name
            - email: User's email address (unchanged)
            - role: User's role ("admin" or "user")
            - created_at: Original account creation timestamp
            - updated_at: New update timestamp
            - avatar_url: Updated profile image URL if provided
    """
    try:
        # Get current user
        user = db.users.find_one({"_id": ObjectId(current_user["_id"])})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        # Validate update data
        update_data = user_update.dict(exclude_unset=True)
        
        # Only allow updating specific fields
        allowed_fields = {"name", "avatar_url"}
        update_data = {k: v for k, v in update_data.items() if k in allowed_fields}
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No valid fields to update"
            )
        
        # Add updated_at timestamp
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
    Soft delete the current user's profile by marking it as deleted.
    Requires authentication token.
    
    Args:
        current_user (dict): The authenticated user's information.
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role
    
    Returns:
        None: 204 No Content response with no body.
    """
    try:
        # Soft delete by marking user as deleted
        result = db.users.update_one(
            {"_id": ObjectId(current_user["_id"])},
            {
                "$set": {
                    "deleted": True,
                    "deleted_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                }
            }
        )
        
        if result.modified_count == 0:
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
async def get_users(current_user: dict = Depends(get_current_user)):
    """
    Get a list of all users. Only accessible by admin users.
    Requires authentication token and admin role.
    
    Args:
        current_user (dict): The authenticated user's information.
            Fields:
            - _id: User's ObjectId
            - email: User's email
            - role: User's role (must be "admin" to access)
    
    Returns:
        List[UserResponse]: A list of all user objects.
            Each user object contains:
            - _id: User's ObjectId as string
            - name: User's full name
            - email: User's email address
            - role: User's role
            - created_at: Account creation timestamp
            - updated_at: Last update timestamp
            - avatar_url: Profile image URL if available
    """
    try:
        # Check if user is admin
        if current_user.get("role") != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only admin users can access this endpoint"
            )
        
        # Fetch all non-deleted users from the database
        users = list(db.users.find({"deleted": {"$ne": True}}))
        
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
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
