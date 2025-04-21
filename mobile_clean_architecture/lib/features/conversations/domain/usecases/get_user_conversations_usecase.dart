import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Use case to get all conversations for the current user
///
/// This class implements the [UseCase] interface, taking [NoParams]
/// and returning a List of [Conversation] wrapped in an [Either].
class GetUserConversationsUseCase implements UseCase<List<Conversation>, NoParams> {
  final ConversationRepository repository;

  GetUserConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Conversation>>> call(NoParams params) {
    return repository.getUserConversations();
  }
}
