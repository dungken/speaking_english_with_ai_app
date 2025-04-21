@startuml English Learning App - Focused Feedback System

skinparam classAttributeIconSize 0
skinparam classFontStyle bold
skinparam classFontSize 14
skinparam linetype ortho
skinparam packageStyle rectangle

package "User Management" {
  class User {
    + id: String
    + username: String
    + email: String
    + password: String
    + createdAt: DateTime
    + lastLogin: DateTime
    + authenticate(): Result<bool, AuthError>
    + updateProfile(): Result<void, UserError>
  }

  class UserProgress {
    + id: String
    + userId: String
    + totalStudyTime: Number
    + currentStreak: Number
    + longestStreak: Number
    + overallScore: Map<String, Number>
    + lastUpdated: DateTime
    + updateProgress(): Result<void, ProgressError>
  }
}

package "Core Services" #DDDDFF {
  class SpeechService {
    + transcribeAudio(audioFile: File): Result<String, TranscriptionError>
    + saveAudioFile(audioFile: File, userId: String): Result<String, StorageError>
  }

  class FeedbackService {
    + generateDualFeedback(transcription: String, context: Object): Result<FeedbackResult, FeedbackError>
    + storeFeedback(userId: String, feedbackData: Object): Result<String, StorageError>
    - buildDualFeedbackPrompt(transcription: String, context: Object): String
  }

  class GeminiClient {
    + generateContent(prompt: String): Result<String, ApiError>
    + handleApiError(error: ApiError): FallbackResponse
  }

  class MistakeService {
    + processFeedbackForMistakes(userId: String, transcription: String, feedback: Object, context: Object): Result<void, MistakeError>
    + getUnmasteredMistakes(userId: String): Result<List<Mistake>, QueryError>
    + getMistakesForPractice(userId: String, limit: Number): Result<List<Mistake>, QueryError>
    + getMistakeStatistics(userId: String): Result<MistakeStatistics, QueryError>
    + updateAfterPractice(mistakeId: String, result: PracticeResult): Result<Mistake, UpdateError>
    + createPracticeSession(userId: String, mistakes: List<Mistake>): Result<PracticeSession, StorageError>
    - storeUniqueMistakes(userId: String, mistakes: List<Mistake>): Result<List<String>, StorageError>
    - calculateNextPracticeDate(practiceCount: Number, wasSuccessful: Boolean): DateTime
    - extractContext(transcription: String, text: String): String
  }
}

package "Conversation System" {
  class ConversationService {
    + createConversation(userId: String, data: ConversationRequest): Result<Conversation, ServiceError>
    + getConversation(conversationId: String): Result<Conversation, ServiceError>
    + addMessage(conversationId: String, message: MessageRequest): Result<Message, ServiceError>
  }

  class Conversation {
    + id: String
    + userId: String
    + userRole: String
    + aiRole: String
    + situation: String
    + startedAt: DateTime
    + endedAt: DateTime
    + getContext(): ConversationContext
    + addMessage(message: Message): Result<void, StorageError>
    + getMessages(): Result<List<Message>, QueryError>
  }

  class Message {
    + id: String
    + conversationId: String
    + sender: SenderType
    + content: String
    + audioPath: String
    + transcription: String
    + timestamp: DateTime
    + feedbackId: String
  }

  class ConversationContext {
    + userRole: String
    + aiRole: String
    + situation: String
    + previousExchanges: List<Exchange>
    + getFormattedContext(): String
  }
  
  class ConversationGenerator {
    + generateAIResponse(context: ConversationContext): Result<String, GenerationError>
    + enhanceScenario(basicScenario: String): Result<String, GenerationError>
  }
}

package "Feedback Models" {
  class FeedbackResult {
    + userFeedback: String
    + detailedFeedback: DetailedFeedback
    + timestamp: DateTime
    + generateUserFriendlyText(): String
  }

  class DetailedFeedback {
    + grammarIssues: List<GrammarIssue>
    + vocabularyIssues: List<VocabularyIssue>
    + extractMistakes(): List<Mistake>
  }

  class GrammarIssue {
    + issue: String
    + correction: String
    + explanation: String
    + severity: Number
  }

  class VocabularyIssue {
    + original: String
    + betterAlternative: String
    + reason: String
    + exampleUsage: String
  }
}

package "Mistake Tracking" {
  enum MistakeType {
    GRAMMAR
    VOCABULARY
  }

  enum MistakeStatus {
    NEW
    LEARNING
    MASTERED
  }

  class Mistake {
    + id: String
    + userId: String
    + type: MistakeType
    + originalText: String
    + correction: String
    + explanation: String
    + context: String
    + situationContext: Object
    + severity: Number
    + created: DateTime
    + lastPracticed: DateTime
    + practiceCount: Number
    + successCount: Number
    + frequency: Number
    + nextPracticeDate: DateTime
    + status: MistakeStatus
    + generatePracticePrompt(): String
    + calculateMasteryLevel(): Number
  }

  class PracticeSession {
    + id: String
    + userId: String
    + startedAt: DateTime
    + completedAt: DateTime
    + mistakesPracticed: List<MistakePracticeResult>
    + initialize(): void
    + addPracticeResult(mistakeId: String, userAnswer: String, wasSuccessful: Boolean): Result<void, StorageError>
    + calculateSuccess(): Number
    + save(): Result<String, StorageError>
  }

  class MistakePracticeResult {
    + mistakeId: String
    + userAnswer: String
    + wasSuccessful: Boolean
    + feedback: String
    + timestamp: DateTime
  }
  
  class MistakeStatistics {
    + totalCount: Number
    + masteredCount: Number
    + learningCount: Number
    + newCount: Number
    + typeDistribution: Map<MistakeType, Number>
    + dueForPractice: Number
    + masteryPercentage: Number
  }
}

package "Background Processing" {
  class EventHandler {
    + onNewFeedback(feedbackId: String): void
    + processQueuedTasks(): void
    + scheduleTask(taskName: String, data: Object, delayInSeconds: Number): Result<String, SchedulingError>
  }
}

package "API Controllers" #DDFFDD {
  class SpeechController {
    + analyzeSpeech(audioFile: File, conversationId: String): Result<AnalysisResponse, ApiError>
  }

  class MistakeController {
    + getPracticeItems(userId: String, limit: Number): Result<List<PracticeItem>, ApiError>
    + recordPracticeResult(mistakeId: String, result: PracticeResult): Result<PracticeResultResponse, ApiError>
    + getMistakeStatistics(userId: String): Result<MistakeStatistics, ApiError>
  }

  class ConversationController {
    + createConversation(userId: String, data: ConversationRequest): Result<Conversation, ApiError>
    + getConversation(conversationId: String): Result<Conversation, ApiError>
    + addMessage(conversationId: String, message: MessageRequest): Result<Message, ApiError>
  }
}

package "Database" {
  class DatabaseClient {
    + connect(): Result<void, DbError>
    + getCollection(name: String): Collection
    + executeTransaction(actions: List<DbAction>): Result<void, DbError>
  }

  class Collection {
    + findOne(filter: Object): Result<Object, QueryError>
    + find(filter: Object): Cursor
    + insertOne(document: Object): Result<InsertResult, StorageError>
    + updateOne(filter: Object, update: Object): Result<UpdateResult, StorageError>
    + deleteOne(filter: Object): Result<DeleteResult, StorageError>
  }
}

' Relationships
User "1" -- "1" UserProgress
User "1" -- "*" Conversation
User "1" -- "*" Mistake
User "1" -- "*" PracticeSession

SpeechService -- SpeechController : uses >
FeedbackService -- GeminiClient : uses >
FeedbackService -- SpeechController : uses >
MistakeService -- MistakeController : uses >
MistakeService -- FeedbackService : uses >

ConversationService -- ConversationController : manages >
ConversationService -- Conversation : manages >
ConversationService -- ConversationGenerator : uses >
ConversationGenerator -- GeminiClient : uses >

Conversation "1" -- "*" Message
Conversation -- ConversationContext : provides >

FeedbackResult -- DetailedFeedback : contains >
DetailedFeedback "1" -- "*" GrammarIssue
DetailedFeedback "1" -- "*" VocabularyIssue
DetailedFeedback -- Mistake : creates >

Message -- FeedbackResult : may have >

PracticeSession "1" -- "*" MistakePracticeResult
MistakePracticeResult -- Mistake : references >
MistakeService -- PracticeSession : creates >
MistakeService -- MistakeStatistics : generates >

FeedbackService -- EventHandler : triggers >
EventHandler -- MistakeService : calls >

DatabaseClient -- Collection : provides >
MistakeService -- DatabaseClient : uses >
FeedbackService -- DatabaseClient : uses >
ConversationController -- DatabaseClient : uses >
ConversationService -- DatabaseClient : uses >

FeedbackResult -- MistakeService : extracts mistakes from >

@enduml