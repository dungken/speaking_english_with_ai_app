import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

/// Base class for all conversation events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new conversation
class CreateConversationEvent extends ConversationEvent {
  final String userRole;
  final String aiRole;
  final String situation;

  const CreateConversationEvent({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });

  @override
  List<Object?> get props => [userRole, aiRole, situation];
}

/// Event to get user conversations
class GetUserConversationsEvent extends ConversationEvent {
  final int page;
  final int limit;

  const GetUserConversationsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

/// Event to send a speech message in the conversation
class SendSpeechMessageEvent extends ConversationEvent {
  final String conversationId;
  final String audioId;

  const SendSpeechMessageEvent({
    required this.conversationId,
    required this.audioId,
  });

  @override
  List<Object?> get props => [conversationId, audioId];
}

/// Event to get feedback for a message
class GetMessageFeedbackEvent extends ConversationEvent {
  final String messageId;

  const GetMessageFeedbackEvent({
    required this.messageId,
  });

  @override
  List<Object?> get props => [messageId];
}

/// Event to close the active feedback panel
class CloseFeedbackEvent extends ConversationEvent {}

/// Event to mark a conversation as completed
class CompleteConversationEvent extends ConversationEvent {}

/// Event to start recording audio
class StartRecordingEvent extends ConversationEvent {}

/// Event to stop recording audio
class StopRecordingEvent extends ConversationEvent {
  final String filePath;
  // Adding transcription parameter to match with adapter
  final String? transcription;

  const StopRecordingEvent({
    required this.filePath,
    this.transcription,
  });

  @override
  List<Object?> get props => [filePath, transcription];
}

/// Event to cancel recording audio
class CancelRecordingEvent extends ConversationEvent {}

/// Event to load a specific conversation
class LoadConversationEvent extends ConversationEvent {
  final String conversationId;

  const LoadConversationEvent({
    required this.conversationId,
  });

  @override
  List<Object?> get props => [conversationId];
}

/// Event to upload audio file and get transcription
class UploadAudioEvent extends ConversationEvent {
  final String filePath;

  const UploadAudioEvent({
    required this.filePath,
  });

  @override
  List<Object?> get props => [filePath];
}

/// Event to handle successful audio upload
class AudioUploadedEvent extends ConversationEvent {
  final String audioId;
  final String transcription;

  const AudioUploadedEvent({
    required this.audioId,
    required this.transcription,
  });

  @override
  List<Object?> get props => [audioId, transcription];
}

/// Event to edit transcription before sending
class EditTranscriptionEvent extends ConversationEvent {
  final String transcription;

  const EditTranscriptionEvent({
    required this.transcription,
  });

  @override
  List<Object?> get props => [transcription];
}
