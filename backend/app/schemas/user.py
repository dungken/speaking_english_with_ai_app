# Import BaseModel for creating Pydantic models, EmailStr for email validation, and Field for additional field options
from pydantic import BaseModel, EmailStr, Field
# Import Optional from typing to indicate fields that can be None
from typing import Optional
# Import datetime to handle timestamp fields
from datetime import datetime

# Define a base schema for common user fields
# This is inherited by other schemas to avoid repetition
class UserBase(BaseModel):
    name: str          # User's full name, required field
    email: EmailStr    # User's email address, required and validated as a proper email format

# Define a schema for creating a new user
# Inherits from UserBase and adds a password field
class UserCreate(UserBase):
    password: str      # User's plain-text password, required for registration

# Define a schema for user response data
# Inherits from UserBase and adds additional fields for returning user details
class UserResponse(UserBase):
    avatar_url: Optional[str] = None  # Optional URL to the user's avatar, defaults to None
    role: str = "user"                # User's role, defaults to "user" (could be "admin")
    created_at: datetime              # Timestamp of when the user was created, required
    updated_at: datetime              # Timestamp of the last update, required

    # Configuration class for Pydantic model behavior
    class Config:
        # Allow population of the model from attributes (e.g., from MongoDB documents)
        from_attributes = True
        # Custom JSON encoders to format specific types
        json_encoders = {
            # Convert datetime objects to ISO 8601 string format (e.g., "2025-04-01T12:00:00")
            datetime: lambda v: v.isoformat()
        }

class UserLogin(BaseModel):
    email: EmailStr
    password: str
