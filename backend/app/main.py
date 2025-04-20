from fastapi import FastAPI, Depends
from app.routes import user, conversation, audio, feedback, mistake
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.models import SecurityScheme
from fastapi.security import OAuth2PasswordBearer
from typing import Dict

# Create FastAPI app with metadata
app = FastAPI(
    title="Speak AI API",
    description="""
    API for the Speak AI application.
    
    ## Authentication
    This API uses OAuth2 with JWT tokens for authentication.
    
    To authenticate:
    1. Use the `/api/users/login` endpoint with your email and password
    2. Use the received token in the Authorize dialog (click the 🔓 button)
    
    ## Authorization
    The API uses role-based access control with two main roles:
    * **user**: Basic access to own profile and conversations
    * **admin**: Full access including user management
    """,
    version="1.0.0",
    openapi_tags=[
        {
            "name": "users",
            "description": "Operations with users. Includes registration, authentication, and profile management."
        },
        {
            "name": "conversations",
            "description": "Operations with conversations. Requires authentication."
        },
        {
            "name": "audio",
            "description": "Operations with audio recordings. Includes transcription and pronunciation assessment."
        },
        {
            "name": "feedback",
            "description": "Operations for generating and managing language feedback."
        },
        {
            "name": "mistakes",
            "description": "Operations for tracking and drilling language mistakes."
        }
    ]
)

# Configure security scheme for Swagger UI
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/users/login",
    scopes={
        "user": "Read/write access to private user data",
        "admin": "Full access to all operations"
    }
)

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],  # Explicitly list allowed methods
    allow_headers=["*"],  # Allows all headers including Authorization
    expose_headers=["*"],  # Expose all headers to the client
)

# Include routers
app.include_router(
    user.router,
    prefix="/api/users",
    tags=["users"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    conversation.router,
    prefix="/api",
    tags=["conversations"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    audio.router,
    prefix="/api/audio",
    tags=["audio"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    feedback.router,
    prefix="/api/feedback",
    tags=["feedback"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    mistake.router,
    prefix="/api/mistakes",
    tags=["mistakes"],
    responses={401: {"description": "Unauthorized"}}
)

@app.get("/", tags=["root"])
async def root():
    """
    Root endpoint that returns a welcome message.
    
    Returns:
        dict: A dictionary containing a welcome message for the FastAPI + MongoDB project.
    """
    return {
        "message": "Welcome to Speak AI API",
        "docs_url": "/docs",
        "openapi_url": "/openapi.json"
    }