# Import APIRouter for defining API endpoints and HTTPException for error handling
from fastapi import APIRouter, HTTPException
# Import the database connection from the config module
from app.config.database import db
# Import Pydantic schemas for user input validation and response formatting
from app.schemas.user import UserCreate, UserResponse
# Import security utilities for password hashing and verification
from app.utils.security import hash_password, verify_password
# Import the User model for creating user instances
from app.models.user import User
# Import ObjectId for working with MongoDB document IDs
from bson import ObjectId

# Create an APIRouter instance to group user-related endpoints
router = APIRouter()

# Define the register endpoint to create a new user
# - HTTP Method: POST
# - Path: /register
# - Response: UserResponse schema (returns user details without password)
@router.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate):
    # Check if a user with the provided email already exists in the database
    if db.users.find_one({"email": user.email}):
        # Raise a 400 Bad Request error if the email is already registered
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Hash the user's plain-text password for secure storage
    password_hash = hash_password(user.password)
    
    # Create a new User instance with the provided data
    new_user = User(
        name=user.name,           # User's full name from the request
        email=user.email,         # User's email from the request
        password_hash=password_hash  # Hashed password
    )
    
    # Insert the new user into the MongoDB 'users' collection
    result = db.users.insert_one(new_user.to_dict())
    
    # Fetch the newly created user from the database using the inserted ID
    created_user = db.users.find_one({"_id": result.inserted_id})
    
    # Return the user data formatted as a UserResponse schema
    return UserResponse(**created_user)

# Define the login endpoint to authenticate a user
# - HTTP Method: POST
# - Path: /login
# - Request: Expects email and password as form data or JSON
@router.post("/login")
async def login_user(email: str, password: str):
    # Find a user in the database by their email
    user = db.users.find_one({"email": email})
    
    # Check if the user exists and the provided password matches the stored hash
    if not user or not verify_password(password, user["password_hash"]):
        # Raise a 401 Unauthorized error if email or password is invalid
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    # Return a success message and user details if authentication succeeds
    return {
        "message": "Login successful",           # Confirmation of successful login
        "user": UserResponse(**user).dict()      # User data as a dictionary
    }