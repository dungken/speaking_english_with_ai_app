part of 'image_description_cubit.dart';

/// Base state for image description feature
abstract class ImageDescriptionState extends Equatable {
  const ImageDescriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no data is loaded yet
class ImageDescriptionInitial extends ImageDescriptionState {
  const ImageDescriptionInitial();
}

/// Loading state when fetching images
class ImageDescriptionLoading extends ImageDescriptionState {
  const ImageDescriptionLoading();
}

/// Successful state when images are loaded
class ImageDescriptionLoaded extends ImageDescriptionState {
  final List<ImageEntity> images;

  const ImageDescriptionLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

/// Loading state when submitting feedback
class ImageFeedbackLoading extends ImageDescriptionState {
  const ImageFeedbackLoading();
}

/// Successful state when feedback is loaded
class ImageFeedbackLoaded extends ImageDescriptionState {
  final ImageFeedbackEntity feedback;

  const ImageFeedbackLoaded(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

/// Error state when an operation fails
class ImageDescriptionError extends ImageDescriptionState {
  final String message;

  const ImageDescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
