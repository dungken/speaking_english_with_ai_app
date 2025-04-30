import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';

/// Recording state for the conversation
enum RecordingState {
  /// Not recording
  idle,

  /// Currently recording audio
  recording,

  /// Processing the recorded audio
  processing,

  /// Audio has been processed and transcription is ready
  transcribed
}

/// Base class for all conversation states
class ConversationState extends Equatable {
  /// The current conversation, if any
  final Conversation? conversation;

  /// Whether the conversation is loading
  final bool isLoading;

  /// Error message, if any
  final String? errorMessage;

  /// Current recording state
  final RecordingState recordingState;

  /// Currently active feedback, if any
  final Feedback? activeFeedback;

  /// Path to the last recorded audio file
  final String? lastRecordingPath;

  /// Messages from the latest exchange
  final ConversationMessages? lastMessages;

  /// Transcription from the latest audio recording
  final String? transcription;

  /// Audio ID from the latest audio upload
  final String? audioId;

  /// Flag indicating if the transcription was successful
  final bool? transcriptionSuccess;

  /// Cache of feedback results by message ID to prevent redundant API calls
  final Map<String, Feedback> feedbackCache;

  const ConversationState({
    this.conversation,
    this.isLoading = false,
    this.errorMessage,
    this.recordingState = RecordingState.idle,
    this.activeFeedback,
    this.lastRecordingPath,
    this.lastMessages,
    this.transcription,
    this.audioId,
    this.transcriptionSuccess,
    this.feedbackCache = const {},
  });

  @override
  List<Object?> get props => [
        conversation,
        isLoading,
        errorMessage,
        recordingState,
        activeFeedback,
        lastRecordingPath,
        lastMessages,
        transcription,
        audioId,
        transcriptionSuccess,
        feedbackCache,
      ];

  /// Creates a copy of this state with specified fields replaced
  ConversationState copyWith({
    Conversation? conversation,
    bool? isLoading,
    String? errorMessage,
    RecordingState? recordingState,
    Feedback? activeFeedback,
    String? lastRecordingPath,
    ConversationMessages? lastMessages,
    String? transcription,
    String? audioId,
    bool? transcriptionSuccess,
    Map<String, Feedback>? feedbackCache,
    bool clearError = false,
    bool clearActiveFeedback = false,
    bool clearLastRecording = false,
    bool clearLastMessages = false,
    bool clearTranscription = false,
    bool clearAudioId = false,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recordingState: recordingState ?? this.recordingState,
      activeFeedback:
          clearActiveFeedback ? null : (activeFeedback ?? this.activeFeedback),
      lastRecordingPath: clearLastRecording
          ? null
          : (lastRecordingPath ?? this.lastRecordingPath),
      lastMessages:
          clearLastMessages ? null : (lastMessages ?? this.lastMessages),
      transcription:
          clearTranscription ? null : (transcription ?? this.transcription),
      audioId: clearAudioId ? null : (audioId ?? this.audioId),
      transcriptionSuccess: transcriptionSuccess ?? this.transcriptionSuccess,
      feedbackCache: feedbackCache ?? this.feedbackCache,
    );
  }
}

/// Initial state when creating a new conversation
class ConversationInitial extends ConversationState {
  const ConversationInitial() : super();
}

/// State when creating a conversation
class ConversationCreating extends ConversationState {
  const ConversationCreating() : super(isLoading: true);
}

/// State when conversation creation failed
class ConversationCreationFailed extends ConversationState {
  const ConversationCreationFailed({required String errorMessage})
      : super(errorMessage: errorMessage);
}

/// State when a conversation is loaded and active
class ConversationActive extends ConversationState {
  const ConversationActive({
    required Conversation conversation,
    RecordingState recordingState = RecordingState.idle,
    Feedback? activeFeedback,
    String? lastRecordingPath,
    ConversationMessages? lastMessages,
    String? transcription,
    String? audioId,
    bool? transcriptionSuccess,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          recordingState: recordingState,
          activeFeedback: activeFeedback,
          lastRecordingPath: lastRecordingPath,
          lastMessages: lastMessages,
          transcription: transcription,
          audioId: audioId,
          transcriptionSuccess: transcriptionSuccess,
          feedbackCache: feedbackCache,
        );
}

/// State when audio has been recorded and uploaded
class AudioUploaded extends ConversationState {
  const AudioUploaded({
    required Conversation conversation,
    required String lastRecordingPath,
    required String transcription,
    required String audioId,
    bool? transcriptionSuccess,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          recordingState: RecordingState.transcribed,
          lastRecordingPath: lastRecordingPath,
          transcription: transcription,
          audioId: audioId,
          transcriptionSuccess: transcriptionSuccess,
          feedbackCache: feedbackCache,
        );
}

/// State when audio is being uploaded and processed
class AudioUploading extends ConversationState {
  const AudioUploading({
    required Conversation conversation,
    required String lastRecordingPath,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          recordingState: RecordingState.processing,
          lastRecordingPath: lastRecordingPath,
          isLoading: true,
          feedbackCache: feedbackCache,
        );
}

/// State when audio upload has failed
class AudioUploadFailed extends ConversationState {
  const AudioUploadFailed({
    required Conversation conversation,
    required String errorMessage,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          recordingState: RecordingState.idle,
          errorMessage: errorMessage,
          feedbackCache: feedbackCache,
        );
}

/// State when showing feedback for a message
class ConversationFeedbackVisible extends ConversationState {
  const ConversationFeedbackVisible({
    required Conversation conversation,
    required Feedback feedback,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          activeFeedback: feedback,
          feedbackCache: feedbackCache,
        );
}

/// State when conversation is completed
class ConversationCompleted extends ConversationState {
  const ConversationCompleted({
    required Conversation conversation,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(conversation: conversation, feedbackCache: feedbackCache);
}

/// State when conversations have been loaded
class ConversationsLoaded extends ConversationState {
  final List<Conversation> conversations;
  final int totalPages;
  final int currentPage;

  const ConversationsLoaded({
    required this.conversations,
    required this.totalPages,
    required this.currentPage,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(feedbackCache: feedbackCache);

  @override
  List<Object?> get props =>
      [...super.props, conversations, totalPages, currentPage];
}

/// State when message is being sent
class MessageSending extends ConversationState {
  const MessageSending({
    required Conversation conversation,
    required String audioId,
    required String transcription,
    bool? transcriptionSuccess,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          audioId: audioId,
          transcription: transcription,
          transcriptionSuccess: transcriptionSuccess,
          isLoading: true,
          feedbackCache: feedbackCache,
        );
}

/// State when messages have been sent successfully
class MessagesSent extends ConversationState {
  const MessagesSent({
    required Conversation conversation,
    required ConversationMessages messages,
    bool? transcriptionSuccess,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          lastMessages: messages,
          recordingState: RecordingState.idle,
          transcriptionSuccess: transcriptionSuccess,
          feedbackCache: feedbackCache,
        );
}

/// State when feedback is loading from the API
class FeedbackLoading extends ConversationState {
  const FeedbackLoading({
    required Conversation conversation,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          isLoading: true,
          feedbackCache: feedbackCache,
        );
}

/// State when feedback is still being processed
class FeedbackProcessing extends ConversationState {
  final String processingMessage;

  const FeedbackProcessing({
    required Conversation conversation,
    required this.processingMessage,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          feedbackCache: feedbackCache,
        );

  @override
  List<Object?> get props => [...super.props, processingMessage];
}

/// State when feedback has loaded successfully
class FeedbackLoaded extends ConversationState {
  const FeedbackLoaded({
    required Conversation conversation,
    required Feedback feedback,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          activeFeedback: feedback,
          feedbackCache: feedbackCache,
        );
}

/// State when feedback has failed to load
class FeedbackError extends ConversationState {
  const FeedbackError({
    required Conversation conversation,
    required String errorMessage,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          errorMessage: errorMessage,
          feedbackCache: feedbackCache,
        );
}

/// State when transcription has been edited
class TranscriptionEdited extends ConversationState {
  const TranscriptionEdited({
    required Conversation conversation,
    required String transcription,
    required String audioId,
    required String lastRecordingPath,
    bool? transcriptionSuccess,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          conversation: conversation,
          transcription: transcription,
          audioId: audioId,
          lastRecordingPath: lastRecordingPath,
          transcriptionSuccess: transcriptionSuccess,
          recordingState: RecordingState.transcribed,
          feedbackCache: feedbackCache,
        );
}

/// State when an error occurs
class ConversationError extends ConversationState {
  const ConversationError({
    required String message,
    Map<String, Feedback> feedbackCache = const {},
  }) : super(
          errorMessage: message,
          feedbackCache: feedbackCache,
        );
}
