# Speak AI Backend

A FastAPI-based backend for the Speak AI English learning application.

## Project Structure

```
/backend
│
├── /app
│   ├── /config
│   │   ├── __init__.py
│   │   └── database.py
│   │
│   ├── /models
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   ├── message.py
│   │   ├── user.py
│   │   ├── audio.py
│   │   ├── feedback.py
│   │   └── mistake.py
│   │
│   ├── /routes
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   ├── user.py
│   │   ├── audio.py
│   │   ├── feedback.py
│   │   └── mistake.py
│   │
│   ├── /schemas
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   ├── message.py
│   │   ├── user.py
│   │   ├── audio.py
│   │   ├── feedback.py
│   │   └── mistake.py
│   │
│   ├── /utils
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── gemini.py
│   │   ├── security.py
│   │   ├── audio_processor.py
│   │   ├── error_handler.py
│   │   └── spaced_repetition.py
│   │
│   ├── __init__.py
│   └── main.py
│
├── .env
├── .dockerignore
├── Dockerfile
├── .gitignore
├── README.md
└── requirements.txt
```

## Setup Options

### Option 1: Using Docker (Recommended)

The easiest way to run the backend is using Docker with Docker Compose.

#### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

#### Steps

1. Create a `.env` file in the root directory based on `.env.example`
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and fill in your Google Gemini API key and other variables

3. Start the services
   ```bash
   docker-compose up -d
   ```

4. Access the API at `http://localhost:8000`
   - API documentation: `http://localhost:8000/docs`

5. To stop the services
   ```bash
   docker-compose down
   ```

### Option 2: Local Development (Windows)

#### Prerequisites
- Python 3.10+
- MongoDB running locally or accessible remotely

#### Steps

1. Create a Virtual Environment
   ```bash
   python -m venv venv
   ```

2. Activate the Virtual Environment
   ```bash
   # Windows (Command Prompt)
   venv\Scripts\activate
   
   # Windows (Git Bash)
   source venv/Scripts/activate
   ```

3. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```

4. Create `.env` file with your environment variables
   ```
   MONGODB_URL=mongodb://localhost:27017
   DATABASE_NAME=speak_ai_db
   JWT_SECRET_KEY=your_secret_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

5. Run the application
   ```bash
   uvicorn app.main:app --reload
   ```

6. Access the API at `http://localhost:8000`

## API Documentation

When the application is running, you can access:
- Interactive API documentation: `http://localhost:8000/docs`
- OpenAPI specification: `http://localhost:8000/openapi.json`

## Main Features

- User authentication with JWT
- Role-based access control
- Conversation role-play with AI
- Audio processing and transcription
- Pronunciation assessment
- Language feedback generation
- Mistake tracking and drilling with spaced repetition
