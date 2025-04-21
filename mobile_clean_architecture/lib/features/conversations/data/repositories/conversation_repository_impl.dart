import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/feedback.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_remote_datasource.dart';
import '../models/conversation_model.dart';

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
        final conversation = await remoteDataSource.createConversation(
          userRole: userRole,
          aiRole: aiRole,
          situation: situation,
        );
        return Right(conversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final conversation = await remoteDataSource.getConversation(id);
        return Right(conversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getUserConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final conversations = await remoteDataSource.getUserConversations();
        return Right(conversations);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
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
    if (await networkInfo.isConnected) {
      try {
        final updatedConversation = await remoteDataSource.addMessage(
          conversationId: conversationId,
          sender: sender,
          content: content,
          audioPath: audioPath,
          transcription: transcription,
        );
        return Right(updatedConversation);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, Message>> getAiResponse({
    required Conversation conversation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert to model if it's not already a ConversationModel
        final ConversationModel model = conversation is ConversationModel
            ? conversation
            : ConversationModel(
                id: conversation.id,
                userRole: conversation.userRole,
                aiRole: conversation.aiRole,
                situation: conversation.situation,
                messages: conversation.messages,
                startedAt: conversation.startedAt,
                endedAt: conversation.endedAt,
              );
        
        final response = await remoteDataSource.getAiResponse(
          conversation: model,
        );
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
    }
  }

  @override
  Future<Either<Failure, FeedbackResult>> generateFeedback({
    required String conversationId,
    required String messageId,
    required String audioPath,
    required String transcription,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final feedback = await remoteDataSource.generateFeedback(
          conversationId: conversationId,
          messageId: messageId,
          audioPath: audioPath,
          transcription: transcription,
        );
        return Right(feedback);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection. Please check your connection and try again.'));
    }
  }
}
