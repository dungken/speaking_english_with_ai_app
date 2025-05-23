import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/usecases/usecase.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_image_feedback.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_image_url.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_practice_images.dart';

part 'image_description_state.dart';

/// Cubit for managing image description feature state
class ImageDescriptionCubit extends Cubit<ImageDescriptionState> {
  final GetPracticeImages getPracticeImages;
  final GetImageUrl getImageUrl;
  final GetImageFeedback getImageFeedback;

  /// Creates an ImageDescriptionCubit instance
  ImageDescriptionCubit({
    required this.getPracticeImages,
    required this.getImageUrl,
    required this.getImageFeedback,
  }) : super(const ImageDescriptionInitial());

  /// Fetches all practice images from the server
  Future<void> loadPracticeImages() async {
    emit(const ImageDescriptionLoading());

    final result = await getPracticeImages(NoParams());

    result.fold(
      (failure) => emit(ImageDescriptionError(_mapFailureToMessage(failure))),
      (images) => emit(ImageDescriptionLoaded(images)),
    );
  }

  /// Gets image URL for a specific image ID
  Future<String?> getImageUrlById(String imageId) async {
    final result = await getImageUrl(ImageParams(imageId: imageId));

    return result.fold(
      (failure) {
        emit(ImageDescriptionError(_mapFailureToMessage(failure)));
        return null;
      },
      (imageUrl) => imageUrl,
    );
  }

  /// Gets feedback for user's image description
  Future<void> submitImageDescription({
    required String userId,
    required String imageId,
    required String description,
  }) async {
    emit(const ImageFeedbackLoading());

    final result = await getImageFeedback(
      FeedbackParams(
        userId: userId,
        imageId: imageId,
        userTranscription: description,
      ),
    );

    result.fold(
      (failure) => emit(ImageDescriptionError(_mapFailureToMessage(failure))),
      (feedback) => emit(ImageFeedbackLoaded(feedback)),
    );
  }

  // Helper method to map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message ?? 'Server error occurred';
      case NetworkFailure:
        return failure.message ?? 'Network error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}
