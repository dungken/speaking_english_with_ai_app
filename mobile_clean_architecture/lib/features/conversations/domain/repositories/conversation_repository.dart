import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/feedback.dart';
import '../entities/message.dart';

/// Represents a successful message exchange with user and AI messages
class ConversationMessages {
  final Message userMessage;
  final Message aiMessage;

  ConversationMessages({
    required this.userMessage,
    required this.aiMessage,
  });
}

/// Repository interface for handling conversations
///
/// Defines methods for creating and retrieving conversations,
/// sending speech messages, and getting feedback
abstract class ConversationRepository {
  /// Creates a new conversation with the given parameters
  ///
  /// Returns a [Conversation] wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, Conversation>> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  });

  /// Gets all conversations for the current user
  ///
  /// Returns a list of [Conversation] objects wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, List<Conversation>>> getUserConversations({
    int page = 1,
    int limit = 10,
  });

  /// Sends a speech message and receives the AI response
  ///
  /// Takes an audio ID from the previously uploaded speech recording
  /// and returns both the user's transcribed message and the AI's response
  ///
  /// Returns [ConversationMessages] wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, ConversationMessages>> sendSpeechMessage({
    required String conversationId,
    required String audioId,
  });

  /// Gets feedback for a specific message
  ///
  /// Returns [Feedback] wrapped in [Either] if successful and ready,
  /// or a [Failure] if something goes wrong or feedback is still processing
  Future<Either<Failure, Feedback>> getMessageFeedback(String messageId);

  /// Adds a message to a specific conversation
  Future<Either<Failure, Conversation>> addMessage({
    required String conversationId,
    required SenderType sender,
    required String content,
    String? audioPath,
    String? transcription,
  });

  /// Retrieves a specific conversation by its ID
  Future<Either<Failure, Conversation>> getConversation(String id);
}
