import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_clean_architecture/core/error/failures.dart';
import 'package:mobile_clean_architecture/core/usecases/usecase.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/feedback_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_image_feedback.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_image_url.dart';
import 'package:mobile_clean_architecture/features/image_description/domain/usecases/get_practice_images.dart';
import '../../data/services/audio_recording_service.dart';

part 'image_description_state.dart';

/// Cubit for managing image description feature state
class ImageDescriptionCubit extends Cubit<ImageDescriptionState> {
  final GetPracticeImages getPracticeImages;
  final GetImageUrl getImageUrl;
  final GetImageFeedback getImageFeedback;
  final AudioRecordingService _audioService;

  /// Creates an ImageDescriptionCubit instance
  ImageDescriptionCubit({
    required this.getPracticeImages,
    required this.getImageUrl,
    required this.getImageFeedback,
    AudioRecordingService? audioService,
  })  : _audioService = audioService ?? AudioRecordingService(),
        super(const ImageDescriptionInitial());

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

  /// Starts audio recording for image description
  Future<void> startRecording() async {
    try {
      // Check permissions first
      if (!await _audioService.hasPermission()) {
        emit(const ImageDescriptionError('Microphone permission is required'));
        return;
      }

      // Update state to recording
      if (state is ImageDescriptionLoaded) {
        final currentState = state as ImageDescriptionLoaded;
        emit(ImageRecordingStarted(currentState.images));
      } else {
        emit(const ImageRecordingStarted([]));
      }

      // Start recording
      final success = await _audioService.startRecording();
      if (!success) {
        emit(const ImageDescriptionError('Failed to start recording'));
      }
    } catch (e) {
      emit(ImageDescriptionError('Recording error: ${e.toString()}'));
    }
  }

  /// Stops recording and processes transcription
  Future<void> stopRecording(String imageId) async {
    try {
      // Update state to processing
      if (state is ImageRecordingStarted) {
        final currentState = state as ImageRecordingStarted;
        emit(ImageTranscriptionProcessing(currentState.images));
      }

      // Stop recording and get file path
      final audioFilePath = await _audioService.stopRecording();
      if (audioFilePath == null) {
        emit(const ImageDescriptionError('Failed to stop recording'));
        return;
      }

      // Transcribe audio
      final transcriptionResult =
          await _audioService.transcribeAudio(audioFilePath);

      if (transcriptionResult.success &&
          transcriptionResult.transcription.isNotEmpty) {
        // Get images from current state
        List<ImageEntity> images = [];
        if (state is ImageTranscriptionProcessing) {
          images = (state as ImageTranscriptionProcessing).images;
        }

        // Emit transcription completed state
        emit(ImageTranscriptionCompleted(
          images: images,
          transcription: transcriptionResult.transcription,
          imageId: imageId,
        ));

        // Automatically request feedback
        await _requestFeedbackForTranscription(
          imageId: imageId,
          transcription: transcriptionResult.transcription,
          images: images,
        );
      } else {
        emit(ImageDescriptionError(transcriptionResult.transcription.isNotEmpty
            ? transcriptionResult.transcription
            : 'Failed to transcribe audio'));
      }
    } catch (e) {
      emit(ImageDescriptionError('Transcription error: ${e.toString()}'));
    }
  }

  /// Cancels current recording
  Future<void> cancelRecording() async {
    try {
      await _audioService.cancelRecording();

      // Return to loaded state if we have images
      if (state is ImageRecordingStarted) {
        final currentState = state as ImageRecordingStarted;
        emit(ImageDescriptionLoaded(currentState.images));
      } else {
        emit(const ImageDescriptionInitial());
      }
    } catch (e) {
      emit(
          ImageDescriptionError('Error cancelling recording: ${e.toString()}'));
    }
  }

  /// Private method to request feedback after transcription
  Future<void> _requestFeedbackForTranscription({
    required String imageId,
    required String transcription,
    required List<ImageEntity> images,
  }) async {
    try {
      final result = await getImageFeedback(
        FeedbackParams(
          userId: 'current-user-id', // This should come from auth state
          imageId: imageId,
          userTranscription: transcription,
        ),
      );

      result.fold(
        (failure) => emit(ImageDescriptionError(_mapFailureToMessage(failure))),
        (feedback) => emit(ImageFeedbackReceived(
          images: images,
          transcription: transcription,
          feedback: feedback,
          imageId: imageId,
        )),
      );
    } catch (e) {
      emit(ImageDescriptionError('Error getting feedback: ${e.toString()}'));
    }
  }

  /// Manually request feedback (for retry scenarios)
  Future<void> requestFeedback({
    required String imageId,
    required String transcription,
  }) async {
    // Get current images
    List<ImageEntity> images = [];
    if (state is ImageTranscriptionCompleted) {
      images = (state as ImageTranscriptionCompleted).images;
    } else if (state is ImageDescriptionLoaded) {
      images = (state as ImageDescriptionLoaded).images;
    }

    emit(const ImageFeedbackLoading());

    await _requestFeedbackForTranscription(
      imageId: imageId,
      transcription: transcription,
      images: images,
    );
  }

  /// Reset to initial state
  void reset() {
    emit(const ImageDescriptionInitial());
  }

  /// Get recording status
  bool get isRecording => _audioService.isRecording;

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

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}
