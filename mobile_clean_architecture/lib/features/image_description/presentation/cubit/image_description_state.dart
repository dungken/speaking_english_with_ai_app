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

/// State when user is recording audio description
class ImageRecordingStarted extends ImageDescriptionState {
  final List<ImageEntity> images;

  const ImageRecordingStarted(this.images);

  @override
  List<Object?> get props => [images];
}

/// State when processing transcription
class ImageTranscriptionProcessing extends ImageDescriptionState {
  final List<ImageEntity> images;

  const ImageTranscriptionProcessing(this.images);

  @override
  List<Object?> get props => [images];
}

/// State when transcription is completed
class ImageTranscriptionCompleted extends ImageDescriptionState {
  final List<ImageEntity> images;
  final String transcription;
  final String imageId;

  const ImageTranscriptionCompleted({
    required this.images,
    required this.transcription,
    required this.imageId,
  });

  @override
  List<Object?> get props => [images, transcription, imageId];
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

/// State when feedback is received with full context
class ImageFeedbackReceived extends ImageDescriptionState {
  final List<ImageEntity> images;
  final String transcription;
  final ImageFeedbackEntity feedback;
  final String imageId;

  const ImageFeedbackReceived({
    required this.images,
    required this.transcription,
    required this.feedback,
    required this.imageId,
  });

  @override
  List<Object?> get props => [images, transcription, feedback, imageId];
}

/// Error state when an operation fails
class ImageDescriptionError extends ImageDescriptionState {
  final String message;

  const ImageDescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
