from datetime import datetime, timedelta
from fastapi import Depends, HTTPException, status, Security
from fastapi.security import OAuth2PasswordBearer, SecurityScopes
from jose import jwt, JWTError
from typing import Optional
from app.config.database import db
from bson import ObjectId
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# JWT configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY","alksdngaowengoiijoiAJEOIGJAOWIEJGOPAIWJEGIORWJGAAA")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

if not SECRET_KEY:
    raise ValueError("JWT_SECRET_KEY environment variable is not set")

# OAuth2 scheme for token authentication (points to the login endpoint)
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/users/login",
    scopes={"user": "Read user information", "admin": "Full access"}
)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """
    Generate a JWT access token with an expiration time.
    
    Args:
        data (dict): Dictionary containing the data to encode in the token.
            Sample input:
            {
                "sub": "user@example.com"  # user email
            }
        expires_delta (Optional[timedelta], optional): Custom expiration time for the token.
            If not provided, defaults to ACCESS_TOKEN_EXPIRE_MINUTES.
    
    Returns:
        str: The encoded JWT token.
            Sample output:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyQGV4YW1wbGUuY29tIiwiZXhwIjoxNzEyMjI0MDAwfQ.xyz..."
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(
    security_scopes: SecurityScopes,
    token: str = Depends(oauth2_scheme)
):
    """
    Verify the JWT token and retrieve the current user's information.
    Also verifies that the user has the required scopes.
    
    Args:
        security_scopes (SecurityScopes): Required scopes for the endpoint.
        token (str): The JWT token from the request header.
    
    Returns:
        dict: The current user's information from the database.
    
    Raises:
        HTTPException: If the token is invalid, expired, or user lacks required scopes.
    """
    authenticate_value = f'Bearer scope="{security_scopes.scope_str}"'
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": authenticate_value},
    )
    
    try:
        # Decode the JWT token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
            
        # Get token scopes
        token_scopes = payload.get("scopes", [])
        
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": authenticate_value},
        )
    except JWTError:
        raise credentials_exception
    
    # Find the user in the database
    user = db.users.find_one({"email": email})
    if user is None:
        raise credentials_exception
        
    # Check for required scopes
    for scope in security_scopes.scopes:
        if scope not in token_scopes:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions",
                headers={"WWW-Authenticate": authenticate_value},
            )
    
    return user