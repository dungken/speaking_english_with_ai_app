"""
Entry point for the Speak AI backend application.
This file is placed at the root level to avoid import issues.
"""

import uvicorn
from app.main import app

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
