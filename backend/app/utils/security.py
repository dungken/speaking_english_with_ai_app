# Import bcrypt for password hashing and verification
import bcrypt

# Define a function to hash a plain-text password
# - Parameter: password (str) - The plain-text password to hash
# - Returns: str - The hashed password suitable for storage
def hash_password(password: str) -> str:
    # Generate a salt and hash the password
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    # Return the hash as a string
    return hashed.decode('utf-8')

# Define a function to verify a plain-text password against a stored hash
# - Parameters:
#   - plain_password (str): The plain-text password provided by the user
#   - hashed_password (str): The stored hashed password from the database
# - Returns: bool - True if the password matches the hash, False otherwise
def verify_password(plain_password: str, hashed_password: str) -> bool:
    # Check if the plain password matches the hash
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

