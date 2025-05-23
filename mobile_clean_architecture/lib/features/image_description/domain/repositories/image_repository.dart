import 'package:dartz/dartz.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';

/// Repository interface for image-related operations
abstract class ImageRepository {
  /// Get a list of practice images from the server
  Future<Either<Failure, List<ImageEntity>>> getPracticeImages();

  /// Get image URL by its ID
  Future<Either<Failure, String>> getImageUrl(String imageId);

  /// Submit user's description of an image and get feedback
  Future<Either<Failure, ImageFeedbackEntity>> getImageFeedback({
    required String userId,
    required String imageId,
    required String userTranscription,
  });
}
