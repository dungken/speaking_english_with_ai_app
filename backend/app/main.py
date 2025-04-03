from fastapi import FastAPI
from app.routes import user, conversation

app = FastAPI()

app.include_router(user.router, prefix="/api/users", tags=["users"])
app.include_router(conversation.router, prefix="/api", tags=["conversations"])

@app.get("/")
async def root():
    return {"message": "FastAPI + MongoDB project"}