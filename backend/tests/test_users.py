import os
import sys
import pytest
from fastapi.testclient import TestClient
from bson import ObjectId
import json
from datetime import datetime, timedelta
from jose import jwt
from dotenv import load_dotenv

# Add the backend directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load environment variables
load_dotenv()

from app.main import app
from app.config.database import db

client = TestClient(app)

# Test data - Updated to match validation rules
TEST_USER = {
    "name": "Test User",  # Contains space and is between 2-50 characters
    "email": "test@example.com",  # Valid email format
    "password": "Test123456"  # At least 8 characters, contains both letters and numbers
}

# JWT configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

@pytest.fixture(autouse=True)
def setup_teardown():
    """Fixture to clear the database before and after each test"""
    db.users.delete_many({})
    yield
    db.users.delete_many({})

def create_test_token(email: str) -> str:
    """Helper function to create a test JWT token"""
    expires_delta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    expire = datetime.utcnow() + expires_delta
    to_encode = {"sub": email, "exp": expire}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# ============== Registration Tests ==============
def test_register_user_success():
    """Test successful user registration with valid data"""
    response = client.post("/api/users/register", json=TEST_USER)
    assert response.status_code == 201, f"Response: {response.json()}"  # Added error message
    data = response.json()
    assert data["name"] == TEST_USER["name"]
    assert data["email"] == TEST_USER["email"]
    assert "_id" in data  # MongoDB uses _id instead of id
    assert "created_at" in data
    assert "updated_at" in data

def test_register_user_duplicate_email():
    """Test registration with an email that already exists"""
    # First registration
    client.post("/api/users/register", json=TEST_USER)
    
    # Try to register with same email
    response = client.post("/api/users/register", json=TEST_USER)
    assert response.status_code == 400
    assert "Email already registered" in response.json()["detail"]

def test_register_user_invalid_email_format():
    """Test registration with invalid email format"""
    invalid_user = TEST_USER.copy()
    invalid_user["email"] = "invalid-email"
    response = client.post("/api/users/register", json=invalid_user)
    assert response.status_code == 422
    assert "email" in str(response.json()["detail"]).lower()

def test_register_user_short_name():
    """Test registration with name shorter than minimum length"""
    invalid_user = TEST_USER.copy()
    invalid_user["name"] = "T"
    response = client.post("/api/users/register", json=invalid_user)
    assert response.status_code == 422
    assert "name" in str(response.json()["detail"]).lower()

def test_register_user_long_name():
    """Test registration with name longer than maximum length"""
    invalid_user = TEST_USER.copy()
    invalid_user["name"] = "A" * 51  # 51 characters
    response = client.post("/api/users/register", json=invalid_user)
    assert response.status_code == 422
    assert "name" in str(response.json()["detail"]).lower()

def test_register_user_short_password():
    """Test registration with password shorter than minimum length"""
    invalid_user = TEST_USER.copy()
    invalid_user["password"] = "123"
    response = client.post("/api/users/register", json=invalid_user)
    assert response.status_code == 422
    assert "password" in str(response.json()["detail"]).lower()

def test_register_user_long_password():
    """Test registration with password longer than maximum length"""
    invalid_user = TEST_USER.copy()
    invalid_user["password"] = "A" * 101  # 101 characters
    response = client.post("/api/users/register", json=invalid_user)
    assert response.status_code == 422
    assert "password" in str(response.json()["detail"]).lower()

# ============== Login Tests ==============
def test_login_success():
    """Test successful login with correct credentials"""
    # Register user first
    client.post("/api/users/register", json=TEST_USER)
    
    # Test login
    response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "token_type" in data
    assert data["token_type"] == "bearer"
    assert "user" in data

def test_login_invalid_email():
    """Test login with non-existent email"""
    response = client.post(
        "/api/users/login",
        data={
            "username": "nonexistent@example.com",
            "password": "wrongpassword"
        }
    )
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

def test_login_wrong_password():
    """Test login with wrong password"""
    # Register user first
    client.post("/api/users/register", json=TEST_USER)
    
    # Try login with wrong password
    response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": "wrongpassword"
        }
    )
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

# ============== Profile Management Tests ==============
def test_get_user_profile_success():
    """Test successful retrieval of user profile"""
    # Register and login to get token
    client.post("/api/users/register", json=TEST_USER)
    login_response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    token = login_response.json()["access_token"]
    
    # Test getting profile
    response = client.get(
        "/api/users/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == TEST_USER["name"]
    assert data["email"] == TEST_USER["email"]
    assert "_id" in data

def test_get_user_profile_unauthorized():
    """Test profile retrieval without authentication"""
    response = client.get("/api/users/me")
    assert response.status_code == 401

def test_get_user_profile_invalid_token():
    """Test profile retrieval with invalid token"""
    response = client.get(
        "/api/users/me",
        headers={"Authorization": "Bearer invalid_token"}
    )
    assert response.status_code == 401

def test_update_user_profile_success():
    """Test successful profile update"""
    # Register and login
    client.post("/api/users/register", json=TEST_USER)
    login_response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    token = login_response.json()["access_token"]
    
    # Update profile
    update_data = {
        "name": "Updated Name",
        "avatar_url": "https://example.com/avatar.jpg"
    }
    response = client.put(
        "/api/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json=update_data
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == update_data["name"]
    assert data["avatar_url"] == update_data["avatar_url"]

def test_update_user_profile_invalid_data():
    """Test profile update with invalid data"""
    # Register and login
    client.post("/api/users/register", json=TEST_USER)
    login_response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    token = login_response.json()["access_token"]
    
    # Try update with invalid data
    invalid_update = {
        "name": "T",  # Too short
        "avatar_url": "not-a-url"  # Invalid URL
    }
    response = client.put(
        "/api/users/me",
        headers={"Authorization": f"Bearer {token}"},
        json=invalid_update
    )
    assert response.status_code == 422

def test_delete_user_profile_success():
    """Test successful profile deletion"""
    # Register and login
    client.post("/api/users/register", json=TEST_USER)
    login_response = client.post(
        "/api/users/login",
        data={
            "username": TEST_USER["email"],
            "password": TEST_USER["password"]
        }
    )
    token = login_response.json()["access_token"]
    
    # Delete profile
    response = client.delete(
        "/api/users/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 204
    
    # Verify user is deleted
    get_response = client.get(
        "/api/users/me",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert get_response.status_code == 401

# ============== Password Validation Tests ==============
def test_password_validation_numbers_only():
    """Test password validation with numbers only"""
    weak_password_user = TEST_USER.copy()
    weak_password_user["password"] = "12345678"
    response = client.post("/api/users/register", json=weak_password_user)
    assert response.status_code == 422
    assert "Password must contain at least one letter and one number" in str(response.json()["detail"])

def test_password_validation_letters_only():
    """Test password validation with letters only"""
    weak_password_user = TEST_USER.copy()
    weak_password_user["password"] = "abcdefgh"
    response = client.post("/api/users/register", json=weak_password_user)
    assert response.status_code == 422
    assert "Password must contain at least one letter and one number" in str(response.json()["detail"])

# ============== Name Validation Tests ==============
def test_name_validation_no_space():
    """Test name validation without space"""
    invalid_name_user = TEST_USER.copy()
    invalid_name_user["name"] = "Test"
    response = client.post("/api/users/register", json=invalid_name_user)
    assert response.status_code == 422
    assert "Name must contain a space" in str(response.json()["detail"])

def test_name_validation_multiple_spaces():
    """Test name validation with multiple spaces"""
    valid_name_user = TEST_USER.copy()
    valid_name_user["name"] = "Test  User  Name"  # Multiple spaces
    response = client.post("/api/users/register", json=valid_name_user)
    assert response.status_code == 201  # Should be valid 