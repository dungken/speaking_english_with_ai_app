# Speak AI Backend API Documentation (Frontend Requirements)

This document outlines the critical backend API endpoints required by the frontend application.

## Authentication

### Register User
- **URL**: `/api/users/register`
- **Method**: `POST`
- **Description**: Register a new user
- **Request Body**:
  ```json
  {
    "name": "string",
    "email": "string",
    "password": "string"
  }
  ```
- **Response**: User details with token

### Login User
- **URL**: `/api/users/login`
- **Method**: `POST`
- **Description**: Authenticate a user and get access token
- **Request Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response**: User details with token

## Conversations

### Create Conversation
- **URL**: `/api/conversations`
- **Method**: `POST`
- **Description**: Create a new conversation with specific roles
- **Request Body**:
  ```json
  {
    "user_role": "string",
    "ai_role": "string",
    "situation": "string"
  }
  ```
- **Response**: Contains the created conversation and initial AI message
- **Example Response**:
  ```json
  {
    "conversation": {
      "id": "507f1f77bcf86cd799439012",
      "user_id": "507f1f77bcf86cd799439011",
      "user_role": "a job seeker",
      "ai_role": "an experienced interviewer",
      "situation": "preparing for a software engineering job interview",
      "created_at": "2024-04-04T12:00:00"
    },
    "initial_message": {
      "id": "507f1f77bcf86cd799439013",
      "conversation_id": "507f1f77bcf86cd799439012",
      "sender": "ai",
      "content": "Hello! I'll be your interviewer today...",
      "created_at": "2024-04-04T12:00:00"
    }
  }
  ```

### Process Speech in Conversation
- **URL**: `/api/conversations/{conversation_id}/speechtomessage`
- **Method**: `POST`
- **Description**: Upload speech audio and get an AI response
- **Path Parameters**:
  - `conversation_id`: ID of the conversation
- **Request Body**: `multipart/form-data`
  - `audio_file`: The audio recording file (WAV, MP3, etc.)
- **Response**: AI response message
- **Example Response**:
  ```json
  {
    "id": "507f1f77bcf86cd799439014",
    "conversation_id": "507f1f77bcf86cd799439012",
    "sender": "ai",
    "content": "That's a good question about your experience...",
    "timestamp": "2024-04-04T12:05:00",
    "audio_path": null,
    "transcription": null,
    "feedback_id": null
  }
  ```
- **Note**: The backend handles audio processing, transcription, user message creation, and feedback generation in the background.

### Add Text Message to Conversation
- **URL**: `/api/conversations/{conversation_id}/messages`
- **Method**: `POST`
- **Description**: Send a text message in a conversation and get AI response
- **Request Body**:
  ```json
  {
    "content": "string",
    "audio_path": "string", // optional
    "transcription": "string", // optional
    "feedback_id": "string" // optional
  }
  ```
- **Response**: AI response message (same format as speech response)

### Get Message Feedback
- **URL**: `/api/messages/{message_id}/feedback`
- **Method**: `GET`
- **Description**: Get user-friendly feedback for a specific message
- **Response**:
  ```json
  {
    "user_feedback": "Your grammar was generally good. Consider using 'has been' instead of 'have been' when referring to a singular subject. Your pronunciation of 'specifically' was excellent!"
  }
  ```
- **Note**: This endpoint is designed to be called when the user clicks the feedback button in the UI, not automatically with each message.

## Image Description Practice

### Get Images for Practice
- **URL**: `/api/images`
- **Method**: `GET`
- **Description**: Get a list of images for description practice
- **Query Parameters**:
  - `topic`: (optional) Filter images by topic
  - `difficulty`: (optional) Filter by difficulty level
- **Response**: Array of available images with metadata

### Submit Image Description
- **URL**: `/api/images/{image_id}/descriptions`
- **Method**: `POST`
- **Description**: Submit audio description for an image and get feedback
- **Request Body**: `multipart/form-data`
  - `audio_file`: The audio recording of the image description
- **Response**: Feedback and suggested description

## Mistake Practice

### Get Practice Items
- **URL**: `/api/mistakes/practice`
- **Method**: `GET`
- **Description**: Get mistakes for practice based on user's history
- **Query Parameters**:
  - `limit`: (optional) Maximum number of mistakes to return
- **Response**: Array of mistakes with practice prompts

### Submit Practice Attempt
- **URL**: `/api/mistakes/{mistake_id}/practice`
- **Method**: `POST`
- **Description**: Submit a practice attempt for a specific mistake
- **Request Body**: `multipart/form-data`
  - `audio_file`: The audio recording of the practice attempt
- **Response**: Feedback on the practice attempt

## Progress Tracking

### Get User Progress
- **URL**: `/api/users/progress`
- **Method**: `GET`
- **Description**: Get user's learning progress statistics
- **Response**: Progress data including streak, total study time, and performance metrics

### Get Mistake Statistics
- **URL**: `/api/mistakes/statistics`
- **Method**: `GET`
- **Description**: Get statistics about user's mistakes
- **Response**: Mistake statistics including counts by type, mastery percentages, etc.

## Error Handling

All endpoints follow consistent error response patterns:

- **401**: Unauthorized - Invalid or missing authentication token
- **404**: Not Found - Requested resource doesn't exist
- **400**: Bad Request - Invalid input parameters
- **500**: Internal Server Error - Server-side error

Error responses include a `detail` field with a description of the error.

## Implementation Notes for Frontend Developers

1. **Authentication**: Store the JWT token and include it in all requests in the `Authorization` header as `Bearer {token}`.

2. **Conversation Flow**:
   - Create a conversation first
   - Use either text messages or speech audio for user inputs
   - Display AI responses
   - Show feedback button for each user message
   - Fetch feedback only when the user clicks the button

3. **Audio Recording**:
   - Record audio in WAV or MP3 format
   - Send the file directly to the backend
   - The backend handles all processing and returns the AI response

4. **Feedback Display**:
   - Feedback is generated asynchronously in the background
   - When the user clicks the feedback button, fetch it from the `/messages/{id}/feedback` endpoint
   - If feedback is still processing, provide a loading state and retry after a short delay

5. **Mistake Tracking**:
   - All mistake tracking is handled automatically in the backend
   - The frontend only needs to provide interfaces for practicing mistakes
