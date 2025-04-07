import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/image_description.dart';
import '../../domain/repositories/image_description_repository.dart';

// Events
abstract class ImageDescriptionEvent {}

class LoadImageDescriptions extends ImageDescriptionEvent {}

class LoadImageDescription extends ImageDescriptionEvent {
  final String id;
  LoadImageDescription(this.id);
}

class CreateImageDescription extends ImageDescriptionEvent {
  final ImageDescription imageDescription;
  CreateImageDescription(this.imageDescription);
}

class UpdateImageDescription extends ImageDescriptionEvent {
  final ImageDescription imageDescription;
  UpdateImageDescription(this.imageDescription);
}

class DeleteImageDescription extends ImageDescriptionEvent {
  final String id;
  DeleteImageDescription(this.id);
}

class GetAiScore extends ImageDescriptionEvent {
  final String description;
  GetAiScore(this.description);
}

class GetAiFeedback extends ImageDescriptionEvent {
  final String description;
  GetAiFeedback(this.description);
}

class GenerateImage extends ImageDescriptionEvent {
  final String prompt;
  GenerateImage(this.prompt);
}

// States
abstract class ImageDescriptionState {}

class ImageDescriptionInitial extends ImageDescriptionState {}

class ImageDescriptionLoading extends ImageDescriptionState {}

class ImageDescriptionLoaded extends ImageDescriptionState {
  final List<ImageDescription> imageDescriptions;
  ImageDescriptionLoaded(this.imageDescriptions);
}

class SingleImageDescriptionLoaded extends ImageDescriptionState {
  final ImageDescription imageDescription;
  SingleImageDescriptionLoaded(this.imageDescription);
}

class AiScoreLoaded extends ImageDescriptionState {
  final double score;
  AiScoreLoaded(this.score);
}

class AiFeedbackLoaded extends ImageDescriptionState {
  final String feedback;
  AiFeedbackLoaded(this.feedback);
}

class ImageGenerated extends ImageDescriptionState {
  final String imageUrl;
  ImageGenerated(this.imageUrl);
}

class ImageDescriptionError extends ImageDescriptionState {
  final String message;
  ImageDescriptionError(this.message);
}

// Bloc
class ImageDescriptionBloc
    extends Bloc<ImageDescriptionEvent, ImageDescriptionState> {
  final ImageDescriptionRepository repository;

  ImageDescriptionBloc({required this.repository})
      : super(ImageDescriptionInitial()) {
    on<LoadImageDescriptions>(_onLoadImageDescriptions);
    on<LoadImageDescription>(_onLoadImageDescription);
    on<CreateImageDescription>(_onCreateImageDescription);
    on<UpdateImageDescription>(_onUpdateImageDescription);
    on<DeleteImageDescription>(_onDeleteImageDescription);
    on<GetAiScore>(_onGetAiScore);
    on<GetAiFeedback>(_onGetAiFeedback);
    on<GenerateImage>(_onGenerateImage);
  }

  Future<void> _onLoadImageDescriptions(
    LoadImageDescriptions event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final imageDescriptions = await repository.getImageDescriptions();
      emit(ImageDescriptionLoaded(imageDescriptions));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onLoadImageDescription(
    LoadImageDescription event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final imageDescription = await repository.getImageDescription(event.id);
      emit(SingleImageDescriptionLoaded(imageDescription));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onCreateImageDescription(
    CreateImageDescription event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final imageDescription =
          await repository.createImageDescription(event.imageDescription);
      emit(SingleImageDescriptionLoaded(imageDescription));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onUpdateImageDescription(
    UpdateImageDescription event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final imageDescription =
          await repository.updateImageDescription(event.imageDescription);
      emit(SingleImageDescriptionLoaded(imageDescription));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onDeleteImageDescription(
    DeleteImageDescription event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      await repository.deleteImageDescription(event.id);
      final imageDescriptions = await repository.getImageDescriptions();
      emit(ImageDescriptionLoaded(imageDescriptions));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onGetAiScore(
    GetAiScore event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final score = await repository.getAiScore(event.description);
      emit(AiScoreLoaded(score));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onGetAiFeedback(
    GetAiFeedback event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final feedback = await repository.getAiFeedback(event.description);
      emit(AiFeedbackLoaded(feedback));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }

  Future<void> _onGenerateImage(
    GenerateImage event,
    Emitter<ImageDescriptionState> emit,
  ) async {
    try {
      emit(ImageDescriptionLoading());
      final imageUrl = await repository.generateImage(event.prompt);
      emit(ImageGenerated(imageUrl));
    } catch (e) {
      emit(ImageDescriptionError(e.toString()));
    }
  }
}
