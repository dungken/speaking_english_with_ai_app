# Speak AI Backend

This repository contains the backend code for the Speak AI application, a platform designed to help users improve their English speaking skills through feedback and practice.

## Key Features

- **Speech Transcription**: Transcribes user speech using local speech recognition
- **Grammar & Vocabulary Feedback**: Analyzes speech and provides detailed feedback on grammar and vocabulary
- **Mistake Tracking**: Identifies and tracks language mistakes for targeted practice
- **Spaced Repetition Practice**: Implements a spaced repetition algorithm for effective language learning
- **Conversation Context**: Considers conversation context when providing feedback

## Architecture

The backend follows a clean architecture approach with layers:

- **API Layer**: FastAPI endpoints for handling HTTP requests
- **Service Layer**: Business logic for processing audio, generating feedback, and managing mistakes
- **Data Layer**: MongoDB collections for persistent storage

### Component Diagrams

For detailed architecture information, see the component diagrams:
- [Component Architecture](docs/component-diagram.md)
- [Speech Analysis Sequence](docs/speech-analysis-sequence.md)
- [Mistake Practice Sequence](docs/mistake-practice-sequence.md)

## Key Components

1. **Audio Processing**: Handles audio transcription using the SpeechRecognition library
2. **Feedback Service**: Generates dual feedback (user-friendly and detailed) using Gemini API
3. **Mistake Service**: Extracts, stores, and manages language mistakes
4. **Background Processing**: Processes time-consuming tasks asynchronously

## API Endpoints

### Audio Endpoints

- **POST /api/audio/analyze-speech**: Analyzes speech audio and provides feedback
  - Accepts audio file upload
  - Optional conversation context
  - Returns transcription and user-friendly feedback
  - Processes mistakes in the background

### Mistake Endpoints

- **GET /api/mistakes/practice**: Retrieves mistakes due for practice
  - Returns a list of practice exercises based on spaced repetition
- **POST /api/mistakes/practice/{mistake_id}/result**: Records practice results
  - Updates mistake mastery and schedules next practice
- **GET /api/mistakes/statistics**: Returns statistics about the user's mistakes

## Getting Started

### Prerequisites

- Python 3.9+
- MongoDB
- Google API key for Gemini (add to .env file)

### Installation

1. Clone this repository
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
3. Set up environment variables in `.env` file:
   ```
   GEMINI_API_KEY=your_gemini_api_key
   MONGODB_URL=your_mongodb_connection_string
   ```

### Running the server

```
uvicorn app.main:app --reload
```

## Testing

Run tests using pytest:
```
pytest
```

## Technology Stack

- **FastAPI**: Modern, fast API framework with automatic documentation
- **MongoDB**: NoSQL database for flexible data storage
- ** Speech Services**: For high-quality speech-to-text and pronunciation assessment
- **Gemini AI**: For generating language feedback and suggestions
- **Docker**: Containerized deployment for easy setup and scaling

## Getting Started

### Prerequisites

- Python 3.8+
- Docker and Docker Compose (for containerized setup)
- Gemini AI API key


### Running with Docker

1. Build and start the containers:
   ```
   docker-compose up -d
   ```

2. This will start both the API server and MongoDB database

3. Visit `http://localhost:8000/docs` to access the Swagger documentation


4. Connect to database using mongodbCompass desktop  with this connection string: 
   ```
   mongodb://admin:password@localhost:27017/speak_ai_db?authSource=admin
   ```


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

## Deployment

For production deployment:

1. Update the `.env` file with production settings
2. Set `DEBUG=False` in production
3. Use a proper MongoDB setup with authentication
4. Set up SSL/TLS for secure communication
5. Consider using a reverse proxy like Nginx
