import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/conversation_repository.dart';

/// Parameters for [SendSpeechMessageUseCase]
class SendSpeechMessageParams {
  final String conversationId;
  final String audioId;

  SendSpeechMessageParams({
    required this.conversationId,
    required this.audioId,
  });
}

/// Use case for sending a speech message in a conversation
class SendSpeechMessageUseCase implements UseCase<ConversationMessages, SendSpeechMessageParams> {
  final ConversationRepository repository;

  SendSpeechMessageUseCase({required this.repository});

  @override
  Future<Either<Failure, ConversationMessages>> call(SendSpeechMessageParams params) {
    return repository.sendSpeechMessage(
      conversationId: params.conversationId,
      audioId: params.audioId,
    );
  }
}
