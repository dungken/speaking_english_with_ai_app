# Import FastAPI to create the web application
from fastapi import FastAPI
# Import the user routes module to include user-related endpoints
from app.routes import user

# Initialize the FastAPI application instance
# This is the main entry point for the app
app = FastAPI()

# Include the user router in the application
# - user.router: The APIRouter instance from app.routes.user
# - prefix="/api/users": All user endpoints will be prefixed with /api/users
# - tags=["users"]: Group these endpoints under the "users" tag in API documentation
app.include_router(user.router, prefix="/api/users", tags=["users"])

# Define a root endpoint for the application
# - HTTP Method: GET
# - Path: /
# - Returns a simple welcome message
@app.get("/")
async def root():
    # Return a JSON response with a message
    return {"message": "FastAPI + MongoDB project"}