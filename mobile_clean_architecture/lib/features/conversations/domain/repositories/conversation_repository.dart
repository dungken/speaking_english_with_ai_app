import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/feedback.dart';
import '../entities/message.dart';

/// Repository interface for handling conversations
///
/// Defines methods for creating and retrieving conversations,
/// adding messages, and generating feedback
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

  /// Gets a specific conversation by ID
  ///
  /// Returns a [Conversation] wrapped in [Either] if found,
  /// or a [Failure] if not found or another error occurs
  Future<Either<Failure, Conversation>> getConversation(String id);

  /// Gets all conversations for the current user
  ///
  /// Returns a list of [Conversation] objects wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, List<Conversation>>> getUserConversations();

  /// Adds a message to a conversation
  ///
  /// Returns the updated [Conversation] wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, Conversation>> addMessage({
    required String conversationId,
    required SenderType sender,
    required String content,
    String? audioPath,
    String? transcription,
  });

  /// Gets the AI response for a conversation
  /// 
  /// Given the conversation context and previous messages,
  /// this gets the next AI response to continue the conversation
  ///
  /// Returns a [Message] wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, Message>> getAiResponse({
    required Conversation conversation,
  });

  /// Generates feedback on a user's message
  ///
  /// Takes the audio recording, transcription, and conversation context
  /// to provide detailed language feedback on the user's response
  ///
  /// Returns a [FeedbackResult] wrapped in [Either] if successful,
  /// or a [Failure] if something goes wrong
  Future<Either<Failure, FeedbackResult>> generateFeedback({
    required String conversationId,
    required String messageId,
    required String audioPath,
    required String transcription,
  });
}
