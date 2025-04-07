# Import BaseModel for creating Pydantic models, EmailStr for email validation, and Field for additional field options
from pydantic import BaseModel, EmailStr, Field, validator
# Import Optional from typing to indicate fields that can be None
from typing import Optional
# Import datetime to handle timestamp fields
from datetime import datetime
import re
from bson import ObjectId
from fastapi.security import OAuth2PasswordRequestForm

# Define a base schema for common user fields
# This is inherited by other schemas to avoid repetition
class UserBase(BaseModel):
    name: str = Field(
        min_length=2,
        max_length=50,
        description="User's full name"
    )
    email: EmailStr = Field(
        description="User's email address"
    )

    @validator('name')
    def name_must_contain_space(cls, v):
        if ' ' not in v:
            raise ValueError('Name must contain a space')
        return v.title()

# Define a schema for creating a new user
# Inherits from UserBase and adds a password field
class UserCreate(UserBase):
    password: str = Field(
        min_length=8,
        max_length=100,
        description="User's password"
    )

    @validator('password')
    def password_strength(cls, v):
        # Updated regex to allow special characters
        if not re.match(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$', v):
            raise ValueError('Password must contain at least one letter, one number, and one special character')
        return v

# Define a schema for user response data
# Inherits from UserBase and adds additional fields for returning user details
class UserResponse(UserBase):
    id: str = Field(alias="_id")
    avatar_url: Optional[str] = Field(
        default=None,
        description="URL to the user's avatar image"
    )
    role: str = Field(
        default="user",
        description="User's role in the system"
    )
    created_at: datetime = Field(
        description="Timestamp of when the user was created"
    )
    updated_at: datetime = Field(
        description="Timestamp of the last update"
    )

    # Configuration class for Pydantic model behavior
    class Config:
        # Allow population of the model from attributes (e.g., from MongoDB documents)
        from_attributes = True
        # Custom JSON encoders to format specific types
        json_encoders = {
            # Convert datetime objects to ISO 8601 string format (e.g., "2025-04-01T12:00:00")
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }

    @validator("id", pre=True)
    def convert_objectid_to_str(cls, v):
        if isinstance(v, ObjectId):
            return str(v)
        return v

class UserLogin(BaseModel):
    username: str  # Using username instead of email for OAuth2 compatibility
    password: str

    @classmethod
    def from_form(cls, form_data: OAuth2PasswordRequestForm):
        """Create UserLogin from OAuth2 form data."""
        return cls(username=form_data.username, password=form_data.password)

class UserUpdate(BaseModel):
    name: Optional[str] = None
    avatar_url: Optional[str] = None

    @validator('name')
    def name_must_contain_space(cls, v):
        if v and ' ' not in v:
            raise ValueError('Name must contain a space')
        return v.title() if v else None

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    scope: str

class UserRegisterResponse(UserResponse):
    access_token: str
    token_type: str = "bearer"

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
