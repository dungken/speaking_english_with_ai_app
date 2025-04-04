from fastapi import FastAPI
from app.routes import user, conversation

app = FastAPI()

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