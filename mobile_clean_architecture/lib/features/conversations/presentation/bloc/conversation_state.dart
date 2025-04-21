import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/message.dart';

/// Recording state for the conversation
enum RecordingState {
  /// Not recording
  idle,
  
  /// Currently recording audio
  recording,
  
  /// Processing the recorded audio
  processing
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
  final FeedbackResult? activeFeedback;
  
  /// Path to the last recorded audio file
  final String? lastRecordingPath;
  
  /// Transcription of the last recording
  final String? lastTranscription;

  const ConversationState({
    this.conversation,
    this.isLoading = false,
    this.errorMessage,
    this.recordingState = RecordingState.idle,
    this.activeFeedback,
    this.lastRecordingPath,
    this.lastTranscription,
  });

  @override
  List<Object?> get props => [
    conversation, 
    isLoading, 
    errorMessage, 
    recordingState, 
    activeFeedback,
    lastRecordingPath,
    lastTranscription,
  ];

  /// Creates a copy of this state with specified fields replaced
  ConversationState copyWith({
    Conversation? conversation,
    bool? isLoading,
    String? errorMessage,
    RecordingState? recordingState,
    FeedbackResult? activeFeedback,
    String? lastRecordingPath,
    String? lastTranscription,
    bool clearError = false,
    bool clearActiveFeedback = false,
    bool clearLastRecording = false,
  }) {
    return ConversationState(
      conversation: conversation ?? this.conversation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recordingState: recordingState ?? this.recordingState,
      activeFeedback: clearActiveFeedback ? null : (activeFeedback ?? this.activeFeedback),
      lastRecordingPath: clearLastRecording ? null : (lastRecordingPath ?? this.lastRecordingPath),
      lastTranscription: clearLastRecording ? null : (lastTranscription ?? this.lastTranscription),
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
    FeedbackResult? activeFeedback,
    String? lastRecordingPath,
    String? lastTranscription,
    bool clearLastRecording = false,
  }) : super(
    conversation: conversation,
    recordingState: recordingState,
    activeFeedback: activeFeedback,
    lastRecordingPath: clearLastRecording ? null : lastRecordingPath,
    lastTranscription: clearLastRecording ? null : lastTranscription,
  );
}

/// State when showing feedback for a message
class ConversationFeedbackVisible extends ConversationState {
  const ConversationFeedbackVisible({
    required Conversation conversation,
    required FeedbackResult feedback,
  }) : super(
    conversation: conversation,
    activeFeedback: feedback,
  );
}

/// State when conversation is completed
class ConversationCompleted extends ConversationState {
  const ConversationCompleted({
    required Conversation conversation,
  }) : super(conversation: conversation);
}
