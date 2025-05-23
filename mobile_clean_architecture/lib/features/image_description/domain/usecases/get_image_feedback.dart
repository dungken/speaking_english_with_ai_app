import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/usecases/usecase.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/repositories/image_repository.dart';

/// UseCase for getting feedback on an image description
class GetImageFeedback extends UseCase<ImageFeedbackEntity, FeedbackParams> {
  final ImageRepository repository;

  /// Creates a GetImageFeedback use case
  GetImageFeedback(this.repository);

  @override
  Future<Either<Failure, ImageFeedbackEntity>> call(FeedbackParams params) {
    return repository.getImageFeedback(
      userId: params.userId,
      imageId: params.imageId,
      userTranscription: params.userTranscription,
    );
  }
}

/// Parameters for GetImageFeedback use case
class FeedbackParams extends Equatable {
  /// ID of the user
  final String userId;

  /// ID of the image
  final String imageId;

  /// User's transcription or description of the image
  final String userTranscription;

  /// Creates FeedbackParams instance
  const FeedbackParams({
    required this.userId,
    required this.imageId,
    required this.userTranscription,
  });

  @override
  List<Object?> get props => [userId, imageId, userTranscription];
}
