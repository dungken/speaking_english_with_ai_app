import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/conversation_repository.dart';

/// Parameters for getting an AI response in a conversation
class GetAiResponseParams {
  final Conversation conversation;

  GetAiResponseParams({
    required this.conversation,
  });
}

/// Use case to get an AI response for a conversation
///
/// This class implements the [UseCase] interface, taking [GetAiResponseParams]
/// and returning a [Message] wrapped in an [Either].
class GetAiResponseUseCase implements UseCase<Message, GetAiResponseParams> {
  final ConversationRepository repository;

  GetAiResponseUseCase(this.repository);

  @override
  Future<Either<Failure, Message>> call(GetAiResponseParams params) {
    return repository.getAiResponse(
      conversation: params.conversation,
    );
  }
}
