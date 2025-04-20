# Speak AI Backend

This is the backend API for the Speak AI Flutter application, focusing on English language learning through speech interaction, feedback, and mistake tracking.

## Features

- **Audio Processing**: Transcription, pronunciation assessment, and comprehensive language analysis
- **User Management**: Authentication, profile management, and progress tracking
- **Conversation System**: Role-play conversations with AI feedback
- **Mistake Tracking**: Systematic tracking and drilling of language mistakes
- **Image Description**: Practice describing images with feedback

## Technology Stack

- **FastAPI**: Modern, fast API framework with automatic documentation
- **MongoDB**: NoSQL database for flexible data storage
- **Azure Speech Services**: For high-quality speech-to-text and pronunciation assessment
- **Gemini AI**: For generating language feedback and suggestions
- **Docker**: Containerized deployment for easy setup and scaling

## Getting Started

### Prerequisites

- Python 3.8+
- Docker and Docker Compose (for containerized setup)
- Azure Speech Services account
- Gemini AI API key

### Environment Setup

1. Clone the repository
2. Copy `env.txt` to `.env` and fill in the required environment variables:

```
# MongoDB Configuration
MONGODB_URL=mongodb://localhost:27017
DATABASE_NAME=speak_ai_db

# Authentication
JWT_SECRET=your_jwt_secret_key
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Azure Speech Services
AZURE_SPEECH_KEY=your_azure_speech_key
AZURE_SPEECH_REGION=eastus

# Gemini AI for Feedback Generation
GEMINI_API_KEY=your_gemini_api_key
```

### Running Locally

1. Create and activate a virtual environment:
   ```
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Start the FastAPI server:
   ```
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. Visit `http://localhost:8000/docs` to access the Swagger documentation

### Running with Docker

1. Build and start the containers:
   ```
   docker-compose up -d
   ```

2. This will start both the API server and MongoDB database

3. Visit `http://localhost:8000/docs` to access the Swagger documentation

## Azure Speech Services Integration

This project uses Azure Speech Services for:

1. **Speech-to-Text**: Converting audio to accurate text transcriptions
2. **Pronunciation Assessment**: Evaluating pronunciation quality and providing detailed feedback
3. **Comprehensive Analysis**: Combined transcription, pronunciation assessment, and language feedback

### Azure Speech Services Setup

1. Create an Azure account and set up a Speech Services resource
2. Get your Speech Service key and region 
3. Add these to your .env file as `AZURE_SPEECH_KEY` and `AZURE_SPEECH_REGION`

## API Documentation

The API is documented using FastAPI's built-in Swagger UI:

- `/docs`: Swagger UI documentation
- `/redoc`: ReDoc documentation

## Key Endpoints

### Audio Processing
- `POST /api/audio/upload`: Register audio recording metadata
- `POST /api/audio/transcribe`: Transcribe audio to text
- `POST /api/audio/pronunciation`: Analyze pronunciation quality
- `POST /api/audio/analyze`: Comprehensive analysis (transcription + pronunciation + language feedback)

### Users
- `POST /api/users/register`: Register a new user
- `POST /api/users/login`: Authenticate and get access token
- `GET /api/users/me`: Get current user's profile
- `PUT /api/users/me`: Update user profile

### Conversations
- `POST /api/conversations`: Create a new conversation
- `GET /api/conversations`: List user's conversations
- `POST /api/conversations/{id}/messages`: Add a message to a conversation
- `GET /api/conversations/{id}/messages`: Get messages for a conversation

### Mistakes
- `GET /api/mistakes`: Get user's tracked mistakes
- `POST /api/mistakes/{id}/drill`: Create a practice drill for a mistake
- `PUT /api/mistakes/{id}`: Update mistake information

## Development

### Project Structure

```
app/
├── config/         # Configuration modules
├── models/         # Database models
├── routes/         # API route handlers
├── schemas/        # Pydantic schemas
├── utils/          # Utility functions
└── main.py         # Application entry point
```

### Adding New Features

1. Define new models in `app/models/`
2. Create Pydantic schemas in `app/schemas/`
3. Implement route handlers in `app/routes/`
4. Register new routers in `main.py`

## Testing

Run tests using pytest:

```
pytest
```

## Deployment

For production deployment:

1. Update the `.env` file with production settings
2. Set `DEBUG=False` in production
3. Use a proper MongoDB setup with authentication
4. Set up SSL/TLS for secure communication
5. Consider using a reverse proxy like Nginx
