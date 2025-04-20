# Import the MongoClient class from pymongo to interact with MongoDB
from pymongo import MongoClient
# Import load_dotenv to load environment variables from a .env file
from dotenv import load_dotenv
# Import os to access environment variables via os.getenv
import os

# Load environment variables from the .env file in the project root
# This allows us to keep sensitive data like database credentials out of the codebase
load_dotenv()

# Retrieve the MongoDB connection string from environment variables
# Example: "mongodb://localhost:27017" (default local MongoDB instance)
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://admin:password@mongodb:27017/speak_ai_db?authSource=admin")

# Retrieve the database name from environment variables
# Example: "fastapi_db" (the specific database we want to connect to)
DATABASE_NAME = os.getenv("DATABASE_NAME", "speak_ai_db")

# Create a MongoDB client instance using the connection string
# This establishes a connection to the MongoDB server
client = MongoClient(MONGODB_URL)

# Access the specific database using the database name
# 'db' will be the object we use to perform operations (e.g., insert, find) on this database
db = client[DATABASE_NAME]