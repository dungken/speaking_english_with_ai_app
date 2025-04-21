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

/// Event to load an existing conversation by ID
class LoadConversationEvent extends ConversationEvent {
  final String conversationId;

  const LoadConversationEvent({
    required this.conversationId,
  });

  @override
  List<Object?> get props => [conversationId];
}

/// Event to send a user message in the conversation
class SendUserMessageEvent extends ConversationEvent {
  final String content;
  final String? audioPath;
  final String? transcription;

  const SendUserMessageEvent({
    required this.content,
    this.audioPath,
    this.transcription,
  });

  @override
  List<Object?> get props => [content, audioPath, transcription];
}

/// Event to request feedback on a user message
class RequestFeedbackEvent extends ConversationEvent {
  final String messageId;
  final String audioPath;
  final String transcription;

  const RequestFeedbackEvent({
    required this.messageId,
    required this.audioPath,
    required this.transcription,
  });

  @override
  List<Object?> get props => [messageId, audioPath, transcription];
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
  final String transcription;

  const StopRecordingEvent({
    required this.filePath,
    required this.transcription,
  });

  @override
  List<Object?> get props => [filePath, transcription];
}

/// Event to cancel recording audio
class CancelRecordingEvent extends ConversationEvent {}
