# Mistake Practice Sequence Diagram

The following sequence diagram illustrates the process flow for mistake practice in the backend.

```plantuml
@startuml Mistake Practice Process

actor User
participant "Mobile App" as App
participant "MistakeController" as MistakeAPI
participant "MistakeService" as MistakeSvc
participant "PracticeSession" as Session
database "Mistake Collection" as MistakeDB
database "PracticeSession Collection" as SessionDB

== Get Practice Items ==

User -> App: Open practice screen
App -> MistakeAPI: GET /api/mistakes/practice?limit=5
activate MistakeAPI

MistakeAPI -> MistakeSvc: getMistakesForPractice(userId, limit)
activate MistakeSvc

MistakeSvc -> MistakeDB: Find mistakes due for practice
note right: Query based on nextPracticeDate,\nstatus, and sorted by frequency/severity
MistakeDB --> MistakeSvc: Return matching mistakes

MistakeSvc -> Session: new PracticeSession(userId, mistakes)
activate Session
Session -> Session: initialize()
Session -> SessionDB: Save session
SessionDB --> Session: Return sessionId
Session --> MistakeSvc: Return session with practice items
deactivate Session

MistakeSvc --> MistakeAPI: Return practice items
deactivate MistakeSvc

MistakeAPI --> App: Return practice exercises
deactivate MistakeAPI

App -> User: Display practice exercises

== Submit Practice Result ==

User -> App: Submit practice answer
App -> MistakeAPI: POST /api/mistakes/practice/{mistakeId}/result
activate MistakeAPI
note right: With wasSuccessful and userAnswer

MistakeAPI -> MistakeSvc: updateAfterPractice(mistakeId, result)
activate MistakeSvc

MistakeSvc -> MistakeDB: Get the mistake
MistakeDB --> MistakeSvc: Return mistake details

MistakeSvc -> MistakeSvc: Update practiceCount and successCount
MistakeSvc -> MistakeSvc: calculateMasteryLevel()
MistakeSvc -> MistakeSvc: Determine status (NEW/LEARNING/MASTERED)
MistakeSvc -> MistakeSvc: calculateNextPracticeDate(practiceCount, wasSuccessful)

MistakeSvc -> MistakeDB: Update mistake record
MistakeDB --> MistakeSvc: Confirm update

MistakeSvc -> Session: Add MistakePracticeResult
Session -> SessionDB: Update session record
SessionDB --> Session: Confirm update

MistakeSvc -> MistakeDB: Get updated mistake
MistakeDB --> MistakeSvc: Return updated mistake

MistakeSvc --> MistakeAPI: Return updated mistake with feedback
deactivate MistakeSvc

MistakeAPI --> App: Return practice result
deactivate MistakeAPI

App -> User: Display feedback and progress

== Get Statistics ==

User -> App: View mistake statistics
App -> MistakeAPI: GET /api/mistakes/statistics
activate MistakeAPI

MistakeAPI -> MistakeSvc: getMistakeStatistics(userId)
activate MistakeSvc

MistakeSvc -> MistakeDB: Query for statistics
MistakeDB --> MistakeSvc: Return aggregated data

MistakeSvc --> MistakeAPI: Return statistics
deactivate MistakeSvc

MistakeAPI --> App: Return statistics
deactivate MistakeAPI

App -> User: Display mistake statistics

@enduml
```

This diagram shows the three main processes related to mistake practice:

1. **Getting Practice Items** - Retrieves mistakes due for practice based on spaced repetition scheduling
2. **Submitting Practice Results** - Records practice results and updates mistake status and scheduling
3. **Getting Statistics** - Provides an overview of the user's progress with mistakes

Key components in these processes:
1. **Mistake Endpoint** - Handles the API requests for practice and statistics
2. **MistakeService** - Implements the business logic for mistake practice
3. **MongoDB** - Stores and retrieves mistake records 