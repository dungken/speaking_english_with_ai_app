import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/audio_services.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/usecases/upload_audio_usecase.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import 'conversation_state_adapter.dart';

/// BLoC that manages conversation state and handles conversation events
///
/// This class coordinates the conversation workflow, including creating
/// conversations, sending messages, and providing language feedback.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository repository;
  final AudioService audioService;
  final UploadAudioUseCase uploadAudioUseCase;

  ConversationBloc({
    required this.repository,
    required this.audioService,
    required this.uploadAudioUseCase,
  }) : super(const ConversationInitial()) {
    on<CreateConversationEvent>(_onCreateConversation);
    on<GetUserConversationsEvent>(_onGetUserConversations);
    on<SendSpeechMessageEvent>(_onSendSpeechMessage);
    on<GetMessageFeedbackEvent>(_onGetMessageFeedback);
    on<CloseFeedbackEvent>(_onCloseFeedback);
    on<CompleteConversationEvent>(_onCompleteConversation);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
    on<UploadAudioEvent>(_onUploadAudio);
    on<LoadConversationEvent>(_onLoadConversation);
    on<EditTranscriptionEvent>(_onEditTranscription);
    on<AudioUploadedEvent>(_onAudioUploaded);
  }

  /// Handles the CreateConversationEvent
  Future<void> _onCreateConversation(
      CreateConversationEvent event, Emitter<ConversationState> emit) async {
    emit(const ConversationCreating());

    final result = await repository.createConversation(
      userRole: event.userRole,
      aiRole: event.aiRole,
      situation: event.situation,
    );

    emit(result.fold(
      (failure) => ConversationCreationFailed(
        errorMessage: _mapFailureToMessage(failure),
      ),
      (conversation) => ConversationActive(conversation: conversation),
    ));
  }

  /// Handles the GetUserConversationsEvent
  Future<void> _onGetUserConversations(
      GetUserConversationsEvent event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await repository.getUserConversations(
      page: event.page,
      limit: event.limit,
    );

    emit(result.fold(
      (failure) => ConversationError(message: _mapFailureToMessage(failure)),
      (conversations) => ConversationsLoaded(
        conversations: conversations,
        totalPages: 1, // Replace with actual total pages from API
        currentPage: event.page,
      ),
    ));
  }

  /// Handles loading a specific conversation
  Future<void> _onLoadConversation(
      LoadConversationEvent event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await repository.getConversation(event.conversationId);

    emit(result.fold(
      (failure) => ConversationError(message: _mapFailureToMessage(failure)),
      (conversation) => ConversationActive(conversation: conversation),
    ));
  }

  /// Handles the SendSpeechMessageEvent (sending a message with audio)
  Future<void> _onSendSpeechMessage(
      SendSpeechMessageEvent event, Emitter<ConversationState> emit) async {
    if (state.conversation == null) {
      emit(const ConversationError(message: 'No active conversation'));
      return;
    }

    emit(MessageSending(
      conversation: state.conversation!,
      audioId: event.audioId,
      transcription: state.transcription ?? '',
    ));

    final result = await repository.sendSpeechMessage(
      conversationId: event.conversationId,
      audioId: event.audioId,
    );

    emit(result.fold(
      (failure) => state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (messages) {
        final updatedConversation = state.conversation!.copyWith(
          messages: [
            ...state.conversation!.messages,
            messages.userMessage,
            messages.aiMessage,
          ],
        );

        return MessagesSent(
          conversation: updatedConversation,
          messages: messages,
        );
      },
    ));
  }

  /// Handles the GetMessageFeedbackEvent
  Future<void> _onGetMessageFeedback(
      GetMessageFeedbackEvent event, Emitter<ConversationState> emit) async {
    if (state.conversation == null) {
      emit(const ConversationError(message: 'No active conversation'));
      return;
    }

    // Emit FeedbackLoading state to show loading indicator
    emit(FeedbackLoading(conversation: state.conversation!));

    final result = await repository.getMessageFeedback(event.messageId);

    emit(result.fold(
      (failure) {
        if (failure is ProcessingFailure) {
          return FeedbackProcessing(
            conversation: state.conversation!,
            processingMessage: failure.message ??
                'Feedback is still being generated. Please try again in a moment.',
          );
        }
        return FeedbackError(
          conversation: state.conversation!,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (feedback) => FeedbackLoaded(
        conversation: state.conversation!,
        feedback: feedback,
      ),
    ));
  }

  /// Handles the CloseFeedbackEvent
  void _onCloseFeedback(
      CloseFeedbackEvent event, Emitter<ConversationState> emit) {
    if (state.conversation == null) return;

    emit(ConversationActive(
      conversation: state.conversation!,
      recordingState: state.recordingState,
      lastRecordingPath: state.lastRecordingPath,
      lastMessages: state.lastMessages,
      transcription: state.transcription,
      audioId: state.audioId,
    ));
  }

  /// Handles the CompleteConversationEvent
  void _onCompleteConversation(
      CompleteConversationEvent event, Emitter<ConversationState> emit) {
    if (state.conversation == null) return;

    // In a real implementation, you would update the conversation in the backend
    // Here we just update the local state
    final completedConversation = state.conversation!.copyWith(
      endedAt: DateTime.now(),
    );

    emit(ConversationCompleted(conversation: completedConversation));
  }

  /// Handles the StartRecordingEvent
  Future<void> _onStartRecording(
      StartRecordingEvent event, Emitter<ConversationState> emit) async {
    emit(state.copyWith(
      recordingState: RecordingState.recording,
      clearLastRecording: true,
      clearTranscription: true,
      clearAudioId: true,
    ));

    try {
      await audioService.startRecording();
    } catch (e) {
      emit(state.copyWith(
        recordingState: RecordingState.idle,
        errorMessage: 'Failed to start recording: $e',
      ));
    }
  }

  /// Handles the StopRecordingEvent
  Future<void> _onStopRecording(
      StopRecordingEvent event, Emitter<ConversationState> emit) async {
    if (state.conversation == null) {
      emit(const ConversationError(message: 'No active conversation'));
      return;
    }

    emit(state.copyWith(recordingState: RecordingState.processing));

    try {
      final filePath = await audioService.stopRecording();
      
      if (filePath != null) {
        // After stopping recording, trigger audio upload
        add(UploadAudioEvent(filePath: filePath));
      } else {
        emit(state.copyWith(
          recordingState: RecordingState.idle,
          errorMessage: 'Failed to save recording',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        recordingState: RecordingState.idle,
        errorMessage: 'Failed to stop recording: $e',
      ));
    }
  }

  /// Handles the CancelRecordingEvent
  Future<void> _onCancelRecording(
      CancelRecordingEvent event, Emitter<ConversationState> emit) async {
    try {
      await audioService.cancelRecording();
      emit(state.copyWith(
        recordingState: RecordingState.idle,
        clearLastRecording: true,
        clearTranscription: true,
        clearAudioId: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        recordingState: RecordingState.idle,
        errorMessage: 'Failed to cancel recording: $e',
      ));
    }
  }

  /// Handles the UploadAudioEvent
  Future<void> _onUploadAudio(
      UploadAudioEvent event, Emitter<ConversationState> emit) async {
    if (state.conversation == null) {
      emit(const ConversationError(message: 'No active conversation'));
      return;
    }

    emit(AudioUploading(
      conversation: state.conversation!,
      lastRecordingPath: event.filePath,
    ));

    final result = await uploadAudioUseCase(
      UploadAudioParams(audioFilePath: event.filePath),
    );

    emit(result.fold(
      (failure) => AudioUploadFailed(
        conversation: state.conversation!,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (response) => AudioUploaded(
        conversation: state.conversation!,
        lastRecordingPath: event.filePath,
        transcription: response.transcription,
        audioId: response.audioId,
      ),
    ));
  }

  /// Handles the AudioUploadedEvent
  void _onAudioUploaded(
      AudioUploadedEvent event, Emitter<ConversationState> emit) {
    if (state.conversation == null) return;

    emit(AudioUploaded(
      conversation: state.conversation!,
      lastRecordingPath: state.lastRecordingPath ?? '',
      transcription: event.transcription,
      audioId: event.audioId,
    ));
  }

  /// Handles editing the transcription before sending
  void _onEditTranscription(
      EditTranscriptionEvent event, Emitter<ConversationState> emit) {
    if (state.conversation == null) return;

    emit(TranscriptionEdited(
      conversation: state.conversation!,
      transcription: event.transcription,
      audioId: state.audioId ?? '',
      lastRecordingPath: state.lastRecordingPath ?? '',
    ));
  }

  /// Maps failure types to user-friendly error messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message ?? 'Server error occurred';
      case NetworkFailure:
        return failure.message ?? 'Network error occurred';
      case ProcessingFailure:
        return failure.message ?? 'Processing in progress';
      case CacheFailure:
        return failure.message ?? 'Cache error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}
