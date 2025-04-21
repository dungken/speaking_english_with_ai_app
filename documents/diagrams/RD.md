@startuml English Learning App - ERD

!define Table(name) class name as "name" << (T,#FFAAAA) >>
!define PK(x) <b><u>x</u></b>
!define FK(x) <i>x</i>

' Primary entities
Table(users) {
  PK(id)
  username
  email
  password_hash
  created_at
  last_login
}

Table(user_progress) {
  PK(id)
  FK(user_id)
  total_study_time
  current_streak
  longest_streak
  last_updated
}

Table(conversations) {
  PK(id)
  FK(user_id)
  user_role
  ai_role
  situation
  started_at
  ended_at
}

Table(messages) {
  PK(id)
  FK(conversation_id)
  sender_type
  content
  audio_path
  transcription
  timestamp
  FK(feedback_id)
}

Table(audio_records) {
  PK(id)
  FK(user_id)
  file_path
  duration
  recorded_at
  transcription
}

Table(feedback) {
  PK(id)
  FK(user_id)
  FK(audio_id)
  FK(message_id)
  user_feedback
  timestamp
}

Table(detailed_feedback) {
  PK(id)
  FK(feedback_id)
  feedback_json
  processed_for_mistakes
}

Table(grammar_issues) {
  PK(id)
  FK(detailed_feedback_id)
  issue
  correction
  explanation
  severity
}

Table(vocabulary_issues) {
  PK(id)
  FK(detailed_feedback_id)
  original
  better_alternative
  reason
  example_usage
}

Table(mistakes) {
  PK(id)
  FK(user_id)
  mistake_type
  original_text
  correction
  explanation
  context
  situation_context
  severity
  created_at
  last_practiced
  practice_count
  success_count
  frequency
  next_practice_date
  status
}

Table(practice_sessions) {
  PK(id)
  FK(user_id)
  started_at
  completed_at
  success_rate
}

Table(mistake_practice_results) {
  PK(id)
  FK(practice_session_id)
  FK(mistake_id)
  user_answer
  was_successful
  feedback
  timestamp
}

Table(background_tasks) {
  PK(id)
  task_name
  task_data
  status
  created_at
  scheduled_for
  completed_at
}

' User to other entities
users ||--o{ user_progress
users ||--o{ conversations
users ||--o{ audio_records
users ||--o{ feedback
users ||--o{ mistakes
users ||--o{ practice_sessions

' Conversation relationships
conversations ||--o{ messages

' Audio and feedback relationships
audio_records ||--o{ feedback
messages ||--o| feedback
feedback ||--|| detailed_feedback
detailed_feedback ||--o{ grammar_issues
detailed_feedback ||--o{ vocabulary_issues

' Practice relationships
practice_sessions ||--o{ mistake_practice_results
mistakes ||--o{ mistake_practice_results

@enduml