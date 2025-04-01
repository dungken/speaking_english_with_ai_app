# Import CryptContext from passlib to handle password hashing and verification
from passlib.context import CryptContext

# Initialize a CryptContext instance for password hashing
# - schemes=["bcrypt"]: Use the bcrypt algorithm for secure hashing
# - deprecated="auto": Automatically handle deprecated schemes if they arise
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Define a function to hash a plain-text password
# - Parameter: password (str) - The plain-text password to hash
# - Returns: str - The hashed password suitable for storage
def hash_password(password: str) -> str:
    # Use the CryptContext instance to generate a secure hash of the password
    return pwd_context.hash(password)

# Define a function to verify a plain-text password against a stored hash
# - Parameters:
#   - plain_password (str): The plain-text password provided by the user
#   - hashed_password (str): The stored hashed password from the database
# - Returns: bool - True if the password matches the hash, False otherwise
def verify_password(plain_password: str, hashed_password: str) -> bool:
    # Use the CryptContext instance to check if the plain password matches the hash
    return pwd_context.verify(plain_password, hashed_password)