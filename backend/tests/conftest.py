import os
import sys
import pytest
from fastapi.testclient import TestClient

# Add the backend directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app
from app.config.database import db

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def test_user():
    return {
        "name": "Test User",
        "email": "test@example.com",
        "password": "Test123456"
    }

@pytest.fixture(autouse=True)
def setup_teardown():
    # Setup: Clear the users collection before each test
    db.users.delete_many({})
    yield
    # Teardown: Clear the users collection after each test
    db.users.delete_many({}) 