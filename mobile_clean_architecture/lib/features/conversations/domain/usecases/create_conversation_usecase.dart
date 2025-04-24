import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Input parameters for creating a new conversation
class CreateConversationParams {
  final String userRole;
  final String aiRole;
  final String situation;

  CreateConversationParams({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });
}

/// Use case to create a new conversation
///
/// This class implements the [UseCase] interface, taking [CreateConversationParams]
/// and returning a [Conversation] wrapped in an [Either] to handle potential failures.
class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  final ConversationRepository repository;

  CreateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(CreateConversationParams params) {
    return repository.createConversation(
      userRole: params.userRole,
      aiRole: params.aiRole,
      situation: _enhanceContextIfNeeded(params.situation),
    );
  }

  /// Helper method to enhance a situation context if it's too brief
  ///
  /// If the situation provided by the user is very brief, this adds more
  /// detail to make the role-play more immersive and effective.
  String _enhanceContextIfNeeded(String situation) {
    // If the situation is already detailed (over 50 characters), use it as-is
    if (situation.length > 50) {
      return situation;
    }

    // Otherwise, enhance it with more details
    // In a real implementation, this might call an AI service to expand the context
    return '$situation. This conversation is taking place in a professional setting. '
        'The atmosphere is friendly yet formal, and both participants are focused '
        'on having a productive exchange.';
  }
}
