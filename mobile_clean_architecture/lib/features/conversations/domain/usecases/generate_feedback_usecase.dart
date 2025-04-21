import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback.dart';
import '../repositories/conversation_repository.dart';

/// Parameters for generating feedback on a user's message
class GenerateFeedbackParams {
  final String conversationId;
  final String messageId;
  final String audioPath;
  final String transcription;

  GenerateFeedbackParams({
    required this.conversationId,
    required this.messageId,
    required this.audioPath,
    required this.transcription,
  });
}

/// Use case to generate feedback on a user's message
///
/// This class implements the [UseCase] interface, taking [GenerateFeedbackParams]
/// and returning a [FeedbackResult] wrapped in an [Either].
class GenerateFeedbackUseCase implements UseCase<FeedbackResult, GenerateFeedbackParams> {
  final ConversationRepository repository;

  GenerateFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackResult>> call(GenerateFeedbackParams params) {
    return repository.generateFeedback(
      conversationId: params.conversationId,
      messageId: params.messageId,
      audioPath: params.audioPath,
      transcription: params.transcription,
    );
  }
}
