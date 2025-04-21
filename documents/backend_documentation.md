# Speak AI Backend Documentation

## Overview
The Speak AI Backend is a FastAPI-based API service that powers the Speak AI Flutter application, focusing on English language learning through speech interaction, feedback, and mistake tracking. It provides audio processing, user management, conversation systems, mistake tracking, and image description features.

## Architecture
The backend follows a modular architecture with clear separation of concerns:

- **Routes**: API endpoints organized by feature
- **Models**: Data structures for database storage
- **Schemas**: Pydantic models for request/response validation
- **Utilities**: Helper functions and services
- **Configuration**: Database and environment settings

## Technology Stack
- **FastAPI**: Modern, fast API framework with automatic documentation
- **MongoDB**: NoSQL database for flexible data storage
- **Azure Speech Services**: For speech-to-text and pronunciation assessment
- **SpeechRecognition**: Python library for local speech-to-text processing (faster alternative)
- **Gemini AI**: For generating language feedback and suggestions
- **Docker**: Containerized deployment for easy setup and scaling

## Core Features

### 1. Audio Processing
- **Transcription**: Convert audio to text using Azure Speech Services or local speech recognition
- **Pronunciation Assessment**: Evaluate pronunciation quality with detailed feedback
- **Language Analysis**: Generate comprehensive language feedback on speech samples

### 2. User Management
- **Authentication**: JWT-based auth with secure password handling
- **User Profiles**: Store and manage user data and learning progress
- **Role-based Access**: Different permission levels for users and admins

### 3. Conversation System
- **AI Conversations**: Role-play conversations for language practice
- **Message History**: Track and store conversation history
- **Feedback Generation**: Provide real-time feedback on language use

### 4. Mistake Tracking
- **Error Detection**: Automatically identify language errors
- **Categorization**: Classify mistakes by type (grammar, vocabulary, etc.)
- **Spaced Repetition**: Schedule review of mistakes based on learning algorithms

### 5. Image Description
- **Description Practice**: Users describe images and receive feedback
- **Vocabulary Building**: Focus on expanding descriptive vocabulary

## API Endpoints

### User Management
- `POST /api/users/register`: Register a new user
- `POST /api/users/login`: Authenticate and get access token
- `GET /api/users/me`: Get current user's profile
- `PUT /api/users/me`: Update user profile

### Audio Processing
- `POST /api/audio/upload`: Register audio recording metadata
- `POST /api/audio/upload-file`: Upload an audio file directly
- `POST /api/audio/save-mic-recording`: Save raw microphone data directly to server
- `POST /api/audio/transcribe`: Transcribe audio to text (from URL or file_id)
- `POST /api/audio/transcribe-local`: Transcribe audio from a local file path
- `POST /api/audio/pronunciation`: Analyze pronunciation quality (from URL or file_id)
- `POST /api/audio/pronunciation-local`: Analyze pronunciation from a local file path
- `POST /api/audio/analyze`: Comprehensive audio analysis (from URL or file_id)
- `POST /api/audio/analyze-local`: Comprehensive analysis from a local file path
- `GET /api/audio/history`: Get user's audio history
- `GET /api/audio/{audio_id}`: Get specific audio record

### Conversations
- `POST /api/conversations`: Create a new conversation
- `GET /api/conversations`: List user's conversations
- `POST /api/conversations/{id}/messages`: Add a message to a conversation
- `GET /api/conversations/{id}/messages`: Get messages for a conversation

### Mistakes
- `GET /api/mistakes`: Get user's tracked mistakes
- `POST /api/mistakes/{id}/drill`: Create a practice drill for a mistake
- `PUT /api/mistakes/{id}`: Update mistake information

### Feedback
- `POST /api/feedback/generate`: Generate feedback on language samples
- `GET /api/feedback/history`: Get user's feedback history

## Database Models

### User Model
- Basic profile (name, email, etc.)
- Authentication data (hashed password)
- Learning preferences and settings

### Audio Model
- Audio metadata (URL, duration)
- Transcription data
- Analysis results (pronunciation scores, feedback)

### Conversation Model
- Conversation metadata (topic, date)
- Relationship to users
- Settings for AI interlocutor

### Message Model
- Message content
- Sender information
- Timestamp and metadata

### Mistake Model
- Error description and context
- Categorization
- Spaced repetition metadata

### Feedback Model
- Generated feedback content
- Related content (audio, conversation)
- Timestamp and metadata

## Authentication System
The backend uses JWT (JSON Web Tokens) for authentication:
- Tokens contain user ID and permission scopes
- Configurable expiration times
- Role-based authorization for API endpoints

## External Services Integration

### Azure Speech Services
- Used for high-quality speech-to-text transcription
- Pronunciation assessment with detailed word-level feedback
- Languages supported: English (multiple dialects)

### Gemini AI
- Used for generating contextual language feedback
- Helps create conversational responses for practice
- Analyzes language errors and provides improvement suggestions

## Deployment

### Docker Setup
- Multi-container setup with Docker Compose
- Services:
  - Backend API (FastAPI)
  - MongoDB database
- Volume mapping for data persistence

### Environment Configuration
Key environment variables:
- Database connection string
- JWT secret key and configuration
- API keys for Azure Speech and Gemini AI
- Logging configuration

## Development Guidelines
- API endpoints follow RESTful design principles
- Error handling with appropriate HTTP status codes
- Comprehensive input validation
- Consistent response formatting

## Integration with Flutter App
The backend provides all necessary endpoints for the Flutter app to:
- Manage user accounts and authentication
- Process audio for language analysis
- Store and retrieve conversation history
- Track mistakes and learning progress 


# File Upload Documentation

## Backend Audio File Upload Support

The backend now supports direct file uploads for audio processing and raw microphone data. This allows the Flutter app to upload audio files directly or send microphone data instead of requiring HTTP URLs.

### New Endpoints

- **POST /api/audio/upload-file**: Upload an audio file directly
  - Request: Multipart form with `file`, `duration_seconds` (optional), and `language` fields
  - Response: Audio record with file ID

- **POST /api/audio/save-mic-recording**: Save raw microphone data directly to server
  - Request: JSON with base64-encoded `file_content`, `filename`, `language`, and optional `duration_seconds`
  - Response: Audio record with file ID

- **POST /api/audio/transcribe-local**: Transcribe audio from a local file path
  - Request: JSON with `file_path`, `language`, and optional `user_id` and `reference_text`
  - Response: Transcription with text and confidence
  - Query param: `use_azure_engine=true` to use Azure Speech Services instead of local recognition

- **POST /api/audio/pronunciation-local**: Analyze pronunciation from a local file path
  - Request: JSON with `file_path`, `language`, and optional `user_id` and `reference_text`
  - Response: Detailed pronunciation assessment

- **POST /api/audio/analyze-local**: Comprehensive analysis from a local file path
  - Request: JSON with `file_path`, `language`, and optional `user_id` and `reference_text`
  - Response: Complete analysis with transcription, pronunciation, and language feedback

### Modified Endpoints

All existing endpoints now support both file_id and URL-based processing:

- **POST /api/audio/transcribe**: Now accepts either `audio_url` or `file_id`
- **POST /api/audio/pronunciation**: Now accepts either `audio_url` or `file_id`
- **POST /api/audio/analyze**: Now accepts either `audio_url` or `file_id`

### Implementation Details

- Audio files are stored in `app/uploads/{user_id}/` directories
- Unique filenames are generated to prevent conflicts
- Local file detection avoids unnecessary downloads
- Temporary files are properly cleaned up

## Flutter Integration

### Uploading Files

To integrate with the Flutter app, use the `http` package's `MultipartRequest` for file uploads:

```dart
// Example of file upload
final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/audio/upload-file'));
request.headers.addAll({'Authorization': 'Bearer $token'});
request.fields['language'] = 'en-US';
request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

final response = await request.send();
final responseData = await http.Response.fromStream(response);

if (response.statusCode == 200) {
  final audioRecord = jsonDecode(responseData.body);
  final fileId = audioRecord['_id'];
  
  // Use the file_id for further processing
  // ...
}
```

### Recording and Processing Microphone Audio

For processing audio directly from the microphone, you can use the new endpoints:

```dart
// Example of recording from microphone and sending to server
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioRecorder {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _recordingPath;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    await _recorder.openRecorder();
    _isInitialized = true;
  }
  
  Future<void> startRecording() async {
    if (!_isInitialized) await initialize();
    
    final dir = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    
    await _recorder.startRecorder(toFile: _recordingPath, codec: Codec.pcm16WAV);
  }
  
  Future<String?> stopRecording() async {
    await _recorder.stopRecorder();
    return _recordingPath;
  }
  
  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
  
  // Method 1: Send file path to server for processing
  Future<Map<String, dynamic>> processLocalFile(String filePath, String language) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/audio/transcribe-local?use_azure_engine=true'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'file_path': filePath,
        'language': language
      })
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process audio: ${response.statusCode}');
    }
  }
  
  // Method 2: Send raw audio data directly to server
  Future<Map<String, dynamic>> sendMicRecording(String filePath, String language) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/audio/save-mic-recording'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'file_content': base64Encode(bytes), // Base64-encode binary data
        'filename': 'mic_recording.wav',
        'language': language,
        'duration_seconds': _recorder.recorderState.duration.inSeconds.toDouble()
      })
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload recording: ${response.statusCode}');
    }
  }
}
```

### Analyzing Speech

Example of using the comprehensive analysis endpoint for pronunciation and language feedback:

```dart
Future<Map<String, dynamic>> analyzeRecording(String audioFileId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/audio/analyze'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode({
      'file_id': audioFileId,
      'language': 'en-US'
    })
  );
  
  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    
    // Now you can use the analysis data
    final transcription = result['transcription'];
    final pronunciationScore = result['pronunciation']['overall_score'];
    final languageFeedback = result['language_feedback'];
    
    return result;
  } else {
    throw Exception('Failed to analyze speech: ${response.statusCode}');
  }
}
```

For real-time transcription, use the transcribe-local endpoint which processes faster:

```dart
Future<String> getTranscription(String filePath) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/audio/transcribe-local?use_azure_engine=true'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode({
      'file_path': filePath,
      'language': 'en-US'
    })
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['text'];
  } else {
    throw Exception('Failed to transcribe speech: ${response.statusCode}');
  }
}
```

## Local Speech Recognition

The backend supports local speech recognition through the Python SpeechRecognition library, providing a faster alternative to Azure Speech Services. This is particularly useful for:

1. Faster processing when speed is more important than accuracy
2. Development and testing without consuming Azure API quotas
3. Situations with limited internet connectivity

### Docker Installation Note

When running in Docker, the local speech recognition may not be fully available as it requires system dependencies like PortAudio. The implementation will automatically fall back to Azure Speech Services if local processing fails.

### Local Development Setup

For full local speech recognition support outside Docker, install the required dependencies:

#### On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y python3-pyaudio portaudio19-dev
pip install SpeechRecognition PyAudio
```

#### On Windows:
```bash
pip install SpeechRecognition PyAudio
```

#### On macOS:
```bash
brew install portaudio
pip install SpeechRecognition PyAudio
```

### Usage

Local speech recognition is now the default for the `/api/audio/transcribe-local` endpoint. Simply call it without any special parameters:

```dart
// Local speech recognition (default method)
final response = await http.post(
  Uri.parse('$baseUrl/api/audio/transcribe-local'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  },
  body: jsonEncode({
    'file_path': filePath,
    'language': 'en-US'
  })
);

if (response.statusCode == 200) {
  final transcription = jsonDecode(response.body)['text'];
  // Use the transcription
}
```

To use Azure Speech Services instead:

```dart
// Use Azure Speech Services 
final response = await http.post(
  Uri.parse('$baseUrl/api/audio/transcribe-local?use_azure_engine=true'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  },
  body: jsonEncode({
    'file_path': filePath,
    'language': 'en-US'
  })
);
```

The local speech recognition still requires internet access as it uses Google's speech recognition API by default. For a fully offline solution, additional configuration with PocketSphinx would be required. 