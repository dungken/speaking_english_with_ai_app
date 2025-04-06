from fastapi import FastAPI
from app.routes import user, conversation
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
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