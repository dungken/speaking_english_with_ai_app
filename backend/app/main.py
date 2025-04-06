from fastapi import FastAPI
from app.routes import user, conversation
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Speak AI API",
    description="API for the Speak AI application",
    version="1.0.0"
)

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],  # Explicitly list allowed methods
    allow_headers=["*"],  # Allows all headers including Authorization
    expose_headers=["*"],  # Expose all headers to the client
)

app.include_router(user.router, prefix="/api/users", tags=["users"])
app.include_router(conversation.router, prefix="/api", tags=["conversations"])

@app.get("/")
async def root():
    """
    Root endpoint that returns a welcome message.
    
    Returns:
        dict: A dictionary containing a welcome message for the FastAPI + MongoDB project.
    """
    return {"message": "FastAPI + MongoDB project"}