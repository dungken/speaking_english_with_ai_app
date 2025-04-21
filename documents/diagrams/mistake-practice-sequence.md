# Mistake Practice Sequence Diagram

The following sequence diagram illustrates the process flow for mistake practice in the backend.

```plantuml
@startuml Mistake Practice Process

actor User
participant "Mobile App" as App
participant "Mistake Endpoint" as MistakeAPI
participant "MistakeService" as MistakeSvc
database MongoDB as DB

== Get Practice Items ==

User -> App: Open practice screen
App -> MistakeAPI: GET /api/mistakes/practice?limit=5
activate MistakeAPI

MistakeAPI -> MistakeSvc: get_practice_items(user_id, limit)
activate MistakeSvc

MistakeSvc -> DB: Find mistakes due for practice
note right: Query mistakes where:\n- next_practice_date <= now\n- status != "MASTERED"\n- in_drill_queue = true\n\nSorted by frequency and severity

DB --> MistakeSvc: Return matching mistakes

MistakeSvc -> MistakeSvc: Transform into practice exercises
MistakeSvc -> MistakeSvc: Generate practice prompts
MistakeSvc --> MistakeAPI: Return practice items
deactivate MistakeSvc

MistakeAPI --> App: Return practice exercises
deactivate MistakeAPI

App -> User: Display practice exercises

== Submit Practice Result ==

User -> App: Submit practice answer
App -> MistakeAPI: POST /api/mistakes/practice/{mistake_id}/result
activate MistakeAPI
note right: With was_successful and user_answer

MistakeAPI -> MistakeSvc: record_practice_result(mistake_id, user_id, was_successful, user_answer)
activate MistakeSvc

MistakeSvc -> DB: Get the mistake
DB --> MistakeSvc: Return mistake details

MistakeSvc -> MistakeSvc: Update practice stats
MistakeSvc -> MistakeSvc: Calculate mastery level
MistakeSvc -> MistakeSvc: Determine status (NEW/LEARNING/MASTERED)
MistakeSvc -> MistakeSvc: Calculate next practice date

MistakeSvc -> DB: Update mistake record
DB --> MistakeSvc: Confirm update

MistakeSvc -> DB: Get updated mistake
DB --> MistakeSvc: Return updated mistake

MistakeSvc -> MistakeSvc: Generate practice feedback
MistakeSvc --> MistakeAPI: Return updated mistake with feedback
deactivate MistakeSvc

MistakeAPI --> App: Return practice result
deactivate MistakeAPI

App -> User: Display feedback and progress

== Get Statistics ==

User -> App: View mistake statistics
App -> MistakeAPI: GET /api/mistakes/statistics
activate MistakeAPI

MistakeAPI -> DB: Count total mistakes
DB --> MistakeAPI: Return total count

MistakeAPI -> DB: Count mastered mistakes
DB --> MistakeAPI: Return mastered count

MistakeAPI -> DB: Count learning mistakes
DB --> MistakeAPI: Return learning count

MistakeAPI -> DB: Count new mistakes
DB --> MistakeAPI: Return new count

MistakeAPI -> DB: Count by type (grammar, vocabulary)
DB --> MistakeAPI: Return type counts

MistakeAPI -> DB: Count mistakes due for practice
DB --> MistakeAPI: Return due count

MistakeAPI -> MistakeAPI: Calculate mastery percentage

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