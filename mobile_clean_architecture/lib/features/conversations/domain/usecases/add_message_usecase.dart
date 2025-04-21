import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/conversation_repository.dart';

/// Parameters for adding a message to a conversation
class AddMessageParams {
  final String conversationId;
  final SenderType sender;
  final String content;
  final String? audioPath;
  final String? transcription;

  AddMessageParams({
    required this.conversationId,
    required this.sender,
    required this.content,
    this.audioPath,
    this.transcription,
  });
}

/// Use case to add a message to a conversation
///
/// This class implements the [UseCase] interface, taking [AddMessageParams]
/// and returning the updated [Conversation] wrapped in an [Either].
class AddMessageUseCase implements UseCase<Conversation, AddMessageParams> {
  final ConversationRepository repository;

  AddMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(AddMessageParams params) {
    return repository.addMessage(
      conversationId: params.conversationId,
      sender: params.sender,
      content: params.content,
      audioPath: params.audioPath,
      transcription: params.transcription,
    );
  }
}
