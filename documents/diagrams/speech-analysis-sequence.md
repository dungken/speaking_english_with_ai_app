# Speech Analysis Sequence Diagram

The following sequence diagram illustrates the process flow for speech analysis in the backend.

```plantuml
@startuml Speech Analysis Process

actor User
participant "Mobile App" as App
participant "Audio Endpoint" as AudioAPI
participant "FeedbackService" as FeedbackSvc
participant "Gemini API" as Gemini
participant "BackgroundTasks" as BgTasks
participant "MistakeService" as MistakeSvc
database MongoDB as DB

User -> App: Record speech audio
App -> AudioAPI: POST /api/audio/analyze-speech\n(audio file, conversation_id)
activate AudioAPI

AudioAPI -> AudioAPI: Save audio file
AudioAPI -> AudioAPI: Transcribe audio locally
note right: Uses SpeechRecognition library\nwith Google Web Speech API

alt Has conversation context
    AudioAPI -> DB: Fetch conversation context
    DB --> AudioAPI: Return conversation details
end

AudioAPI -> FeedbackSvc: generate_dual_feedback(transcription, context)
activate FeedbackSvc

FeedbackSvc -> FeedbackSvc: Build prompt
FeedbackSvc -> Gemini: Generate content
activate Gemini
Gemini --> FeedbackSvc: JSON response with dual feedback
deactivate Gemini

FeedbackSvc -> FeedbackSvc: Parse and validate response
FeedbackSvc --> AudioAPI: Return feedback (user-friendly & detailed)
deactivate FeedbackSvc

AudioAPI -> DB: Store audio record
DB --> AudioAPI: Return audio_id

AudioAPI -> DB: Store feedback record
DB --> AudioAPI: Confirm storage

AudioAPI -> BgTasks: Schedule mistake extraction
activate BgTasks
BgTasks -> MistakeSvc: process_feedback_for_mistakes()
activate MistakeSvc

MistakeSvc -> MistakeSvc: Extract grammar mistakes
MistakeSvc -> MistakeSvc: Extract vocabulary mistakes
MistakeSvc -> MistakeSvc: Calculate next practice dates
MistakeSvc -> DB: Store unique mistakes
DB --> MistakeSvc: Confirm storage
deactivate MistakeSvc
deactivate BgTasks

AudioAPI --> App: Return analysis response\n(transcription & user feedback)
deactivate AudioAPI

App -> User: Display feedback to user

@enduml
```

This diagram shows the flow from the user recording speech through processing and feedback generation, ending with displaying results to the user while mistakes are extracted and stored in the background.

Key components in this process:
1. **Audio Endpoint** - Handles the API request, audio saving, and transcription
2. **FeedbackService** - Generates dual feedback using Gemini API
3. **BackgroundTasks** - Processes mistake extraction asynchronously
4. **MistakeService** - Extracts and stores mistakes for future practice
5. **MongoDB** - Stores audio, feedback, and mistake records 