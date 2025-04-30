import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_remote_datasource.dart';

/// Implementation of [ConversationRepository]
///
/// Handles conversation operations using remote data source
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ConversationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createConversation(
          userRole: userRole,
          aiRole: aiRole,
          situation: situation,
        );

        // Extract conversation and initial message
        final conversation = result['conversation'] as Conversation;
        final initialMessage = result['initial_message'] as Message;

        // Add the initial message to the conversation
        final updatedMessages = [initialMessage];
        final updatedConversation = conversation.copyWith(
          messages: updatedMessages,
        );

        return Right(updatedConversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Add generic exception handling
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getUserConversations({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final conversations = await remoteDataSource.getUserConversations(
          page: page,
          limit: limit,
        );
        return Right(conversations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, ConversationMessages>> sendSpeechMessage({
    required String conversationId,
    required String audioId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.sendSpeechMessage(
          conversationId: conversationId,
          audioId: audioId,
        );

        final userMessage = result['user_message'] as Message;
        final aiMessage = result['ai_message'] as Message;

        return Right(
          ConversationMessages(
            userMessage: userMessage,
            aiMessage: aiMessage,
          ),
        );
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, Feedback>> getMessageFeedback(String messageId) async {
    if (await networkInfo.isConnected) {
      try {
        final feedback = await remoteDataSource.getMessageFeedback(messageId);
        return Right(feedback);
      } on FeedbackProcessingException catch (e) {
        return Left(ProcessingFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> addMessage({
    required String conversationId,
    required SenderType sender,
    required String content,
    String? audioPath,
    String? transcription,
  }) async {
    // Since we're using the sendSpeechMessage with audioId pattern,
    // we don't implement this method directly anymore
    return Left(
      const ServerFailure(
        message:
            'This method is no longer in use. Use sendSpeechMessage instead.',
      ),
    );
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await remoteDataSource.getConversation(id);
        return Right(conversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Please check your connection and try again.'));
    }
  }
}
