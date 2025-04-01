# Import datetime to set timestamps for when users are created or updated
from datetime import datetime
# Import ObjectId from bson to generate unique identifiers for MongoDB documents
from bson import ObjectId

# Define the User class to represent a user entity in the application
class User:
    # Initialize a User instance with required and optional attributes
    # Parameters:
    # - name: The user's full name (required)
    # - email: The user's email address (required)
    # - password_hash: The hashed password for security (required)
    # - avatar_url: Optional URL to the user's profile picture (defaults to None)
    # - role: User's role, either "user" or "admin" (defaults to "user")
    def __init__(self, name: str, email: str, password_hash: str, avatar_url: str = None, role: str = "user"):
        # Generate a unique ObjectId for the user, used as the primary key in MongoDB
        self._id = ObjectId()
        # Store the user's name
        self.name = name
        # Store the user's email
        self.email = email
        # Store the hashed password (not plain text for security)
        self.password_hash = password_hash
        # Store the avatar URL, if provided, otherwise None
        self.avatar_url = avatar_url
        # Store the user's role, defaulting to "user" if not specified
        self.role = role
        # Set the creation timestamp to the current UTC time
        self.created_at = datetime.utcnow()
        # Set the last updated timestamp to the current UTC time (initially same as created_at)
        self.updated_at = datetime.utcnow()

    # Convert the User instance to a dictionary for MongoDB storage
    # Returns a dict representation of the user that can be inserted into MongoDB
    def to_dict(self):
        return {
            # Unique identifier for the user
            "_id": self._id,
            # User's full name
            "name": self.name,
            # User's email address
            "email": self.email,
            # Hashed password for authentication
            "password_hash": self.password_hash,
            # URL to the user's avatar, if available
            "avatar_url": self.avatar_url,
            # User's role in the system
            "role": self.role,
            # Timestamp of when the user was created
            "created_at": self.created_at,
            # Timestamp of the last update to the user's data
            "updated_at": self.updated_at
        }