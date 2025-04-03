from fastapi import APIRouter, HTTPException
from app.config.database import db
from app.schemas.user import UserCreate, UserResponse
from app.utils.security import hash_password, verify_password
from app.models.user import User
from app.utils.auth import create_access_token
from pydantic import BaseModel, EmailStr
from bson import ObjectId

router = APIRouter()

# Define a login request schema
class UserLogin(BaseModel):
    email: EmailStr
    password: str

@router.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate):
    if db.users.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email already registered")
    password_hash = hash_password(user.password)
    new_user = User(name=user.name, email=user.email, password_hash=password_hash)
    result = db.users.insert_one(new_user.to_dict())
    created_user = db.users.find_one({"_id": result.inserted_id})
    return UserResponse(**created_user)

@router.post("/login")
async def login_user(login_data: UserLogin):
    user = db.users.find_one({"email": login_data.email})
    if not user or not verify_password(login_data.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    # Generate JWT token with user ID
    access_token = create_access_token(data={"sub": str(user["_id"])})
    return {"access_token": access_token, "token_type": "bearer"}