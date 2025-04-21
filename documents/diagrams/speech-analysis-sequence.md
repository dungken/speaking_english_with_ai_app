# Speech Analysis Sequence Diagram

The following sequence diagram illustrates the process flow for speech analysis in the backend.

```plantuml
@startuml Speech Analysis Process

actor User
participant "Mobile App" as App
participant "SpeechController" as AudioAPI
participant "SpeechService" as SpeechSvc
participant "FeedbackService" as FeedbackSvc
participant "GeminiClient" as Gemini
participant "EventHandler" as BgTasks
participant "MistakeService" as MistakeSvc
database "Audio Collection" as AudioDB
database "Feedback Collection" as FeedbackDB
database "Mistake Collection" as MistakeDB
database "Conversation Collection" as ConvDB

User -> App: Record speech audio
App -> AudioAPI: POST /api/audio/analyze-speech\n(audio file, conversation_id)
activate AudioAPI

AudioAPI -> SpeechSvc: transcribeAudio(audioFile)
activate SpeechSvc
SpeechSvc -> SpeechSvc: Process audio file
SpeechSvc --> AudioAPI: Return transcription
deactivate SpeechSvc

AudioAPI -> SpeechSvc: saveAudioFile(audioFile, userId)
activate SpeechSvc
SpeechSvc --> AudioAPI: Return file path
deactivate SpeechSvc

alt Has conversation context
    AudioAPI -> ConvDB: Fetch conversation context
    ConvDB --> AudioAPI: Return conversation details
end

AudioAPI -> FeedbackSvc: generateDualFeedback(transcription, context)
activate FeedbackSvc

FeedbackSvc -> FeedbackSvc: buildDualFeedbackPrompt(transcription, context)
FeedbackSvc -> Gemini: generateContent(prompt)
activate Gemini
note right: Prompt requests well-formatted feedback\nwith user-friendly and detailed versions
Gemini --> FeedbackSvc: JSON response with dual feedback
deactivate Gemini

FeedbackSvc -> FeedbackSvc: Parse and create FeedbackResult
FeedbackSvc --> AudioAPI: Return FeedbackResult object
deactivate FeedbackSvc

AudioAPI -> AudioDB: Store audio record
AudioDB --> AudioAPI: Return audio_id

AudioAPI -> FeedbackSvc: storeFeedback(userId, feedbackData)
activate FeedbackSvc
FeedbackSvc -> FeedbackDB: Store feedback with conversation context
FeedbackDB --> FeedbackSvc: Return feedback_id
deactivate FeedbackSvc

AudioAPI --> App: Return analysis response\n(transcription & user feedback)
deactivate AudioAPI

App -> User: Display feedback to user

== After Conversation Ends ==

BgTasks -> BgTasks: Trigger scheduled mistake extraction 
activate BgTasks
BgTasks -> FeedbackDB: Fetch stored feedback with context
FeedbackDB --> BgTasks: Return feedback records

loop For each feedback record
    BgTasks -> MistakeSvc: processFeedbackForMistakes(userId, transcription, feedback, context)
    activate MistakeSvc
    
    MistakeSvc -> Gemini: generateContent(mistakeExtractionPrompt)
    activate Gemini
    note right: Prompt asks to identify and structure\ngrammar and vocabulary mistakes
    Gemini --> MistakeSvc: Return structured mistake data
    deactivate Gemini
    
    MistakeSvc -> MistakeSvc: storeUniqueMistakes(userId, mistakes)
    MistakeSvc -> MistakeDB: Store unique mistakes
    MistakeDB --> MistakeSvc: Confirm storage
    deactivate MistakeSvc
end

BgTasks -> MistakeSvc: calculateNextPracticeDates(userId)
activate MistakeSvc
MistakeSvc -> MistakeDB: Update practice scheduling for all mistakes
MistakeDB --> MistakeSvc: Confirm updates
deactivate MistakeSvc
deactivate BgTasks

@enduml
```

This diagram shows the flow from the user recording speech through processing and feedback generation, ending with displaying results to the user while mistakes are extracted and stored in the background.

Key components in this process:
1. **Audio Endpoint** - Handles the API request, audio saving, and transcription
2. **FeedbackService** - Generates dual feedback using Gemini API
3. **BackgroundTasks** - Processes mistake extraction asynchronously
4. **MistakeService** - Extracts and stores mistakes for future practice
5. **MongoDB** - Stores audio, feedback, and mistake records 