# Backend Component Diagram

The following component diagram illustrates the architecture of the backend system focusing on the speech feedback and mistake practice features.

```plantuml
@startuml Backend Component Diagram

!define RECTANGLE class

package "Client Applications" {
  [Mobile App] as MobileApp
}

package "API Layer" {
  [Audio API] as AudioAPI
  [Mistake API] as MistakeAPI
  [Feedback API] as FeedbackAPI
  [Conversation API] as ConversationAPI
}

package "Service Layer" {
  [Audio Processor] as AudioProcessor
  [Feedback Service] as FeedbackService
  [Mistake Service] as MistakeService
  [Conversation Service] as ConversationService
  [Authentication Service] as AuthService
}

package "External Services" {
  [Google Web Speech API] as WebSpeechAPI
  [Gemini API] as GeminiAPI
}

package "Data Layer" {
  database "MongoDB" {
    [Audio Collection] as AudioDB
    [Mistake Collection] as MistakeDB
    [Feedback Collection] as FeedbackDB
    [Conversation Collection] as ConversationDB
    [User Collection] as UserDB
  }
}

' Client to API connections
MobileApp --> AudioAPI : HTTP requests
MobileApp --> MistakeAPI : HTTP requests
MobileApp --> FeedbackAPI : HTTP requests
MobileApp --> ConversationAPI : HTTP requests

' API to Service connections
AudioAPI --> AudioProcessor : Uses
AudioAPI --> FeedbackService : Uses
MistakeAPI --> MistakeService : Uses
FeedbackAPI --> FeedbackService : Uses
ConversationAPI --> ConversationService : Uses

' Authentication flows
AudioAPI --> AuthService : Verifies user
MistakeAPI --> AuthService : Verifies user
FeedbackAPI --> AuthService : Verifies user
ConversationAPI --> AuthService : Verifies user

' Service to external connections
AudioProcessor --> WebSpeechAPI : Transcribes audio
FeedbackService --> GeminiAPI : Generates feedback

' Service to data connections
AudioProcessor --> AudioDB : Stores/retrieves
FeedbackService --> FeedbackDB : Stores/retrieves
MistakeService --> MistakeDB : Stores/retrieves
ConversationService --> ConversationDB : Stores/retrieves
AuthService --> UserDB : Validates

' Service to service connections
AudioAPI --> MistakeService : Background tasks
FeedbackService --> MistakeService : Extracts mistakes

@enduml
```

This diagram shows the component architecture of the backend system with a focus on speech feedback and mistake practice functionality. The architecture follows a layered approach:

1. **Client Applications Layer** - Mobile app that interacts with the backend
2. **API Layer** - FastAPI endpoints that handle HTTP requests
3. **Service Layer** - Business logic for processing audio, generating feedback, and managing mistakes
4. **External Services Layer** - Third-party APIs for speech recognition and AI-based feedback
5. **Data Layer** - MongoDB collections for persistent storage

Key components:
- **Audio Processor** - Handles audio transcription using Google Web Speech API
- **Feedback Service** - Generates grammar and vocabulary feedback using Gemini API
- **Mistake Service** - Manages the extraction, storage, and practice of language mistakes
- **Authentication Service** - Validates user requests across all APIs 