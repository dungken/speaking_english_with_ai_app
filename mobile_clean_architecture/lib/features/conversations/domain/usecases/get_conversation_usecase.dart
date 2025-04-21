import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Parameters for getting a conversation
class GetConversationParams {
  final String id;

  GetConversationParams({required this.id});
}

/// Use case to get a specific conversation by ID
///
/// This class implements the [UseCase] interface, taking [GetConversationParams]
/// and returning a [Conversation] wrapped in an [Either].
class GetConversationUseCase implements UseCase<Conversation, GetConversationParams> {
  final ConversationRepository repository;

  GetConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(GetConversationParams params) {
    return repository.getConversation(params.id);
  }
}
