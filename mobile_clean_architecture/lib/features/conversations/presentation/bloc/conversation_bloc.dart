import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/add_message_usecase.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/generate_feedback_usecase.dart';
import '../../domain/usecases/get_ai_response_usecase.dart';
import '../../domain/usecases/get_conversation_usecase.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

/// BLoC that manages conversation state and handles conversation events
///
/// This class coordinates the conversation workflow, including creating
/// conversations, sending messages, generating AI responses, and providing
/// language feedback.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final CreateConversationUseCase createConversation;
  final GetConversationUseCase getConversation;
  final AddMessageUseCase addMessage;
  final GetAiResponseUseCase getAiResponse;
  final GenerateFeedbackUseCase generateFeedback;
  
  // Audio service would be injected here in a real implementation

  ConversationBloc({
    required this.createConversation,
    required this.getConversation,
    required this.addMessage,
    required this.getAiResponse,
    required this.generateFeedback,
  }) : super(const ConversationInitial()) {
    on<CreateConversationEvent>(_onCreateConversation);
    on<LoadConversationEvent>(_onLoadConversation);
    on<SendUserMessageEvent>(_onSendUserMessage);
    on<RequestFeedbackEvent>(_onRequestFeedback);
    on<CloseFeedbackEvent>(_onCloseFeedback);
    on<CompleteConversationEvent>(_onCompleteConversation);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
  }

  /// Handles the CreateConversationEvent
  Future<void> _onCreateConversation(
    CreateConversationEvent event, 
    Emitter<ConversationState> emit
  ) async {
    emit(const ConversationCreating());
    
    final result = await createConversation(CreateConversationParams(
      userRole: event.userRole,
      aiRole: event.aiRole,
      situation: event.situation,
    ));
    
    result.fold(
      (failure) => emit(ConversationCreationFailed(
        errorMessage: failure.message,
      )),
      (conversation) async {
        // Get initial AI message
        final aiResponse = await getAiResponse(GetAiResponseParams(
          conversation: conversation,
        ));
        
        aiResponse.fold(
          (failure) => emit(ConversationActive(conversation: conversation)),
          (message) {
            // Add AI message to conversation
            final updatedConversation = conversation.copyWith(
              messages: [...conversation.messages, message],
            );
            emit(ConversationActive(conversation: updatedConversation));
          },
        );
      },
    );
  }

  /// Handles the LoadConversationEvent
  Future<void> _onLoadConversation(
    LoadConversationEvent event, 
    Emitter<ConversationState> emit
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    
    final result = await getConversation(GetConversationParams(
      id: event.conversationId,
    ));
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (conversation) => emit(ConversationActive(conversation: conversation)),
    );
  }

  /// Handles the SendUserMessageEvent
  Future<void> _onSendUserMessage(
    SendUserMessageEvent event, 
    Emitter<ConversationState> emit
  ) async {
    if (state.conversation == null) {
      emit(state.copyWith(
        errorMessage: 'No active conversation',
      ));
      return;
    }
    
    final conversationId = state.conversation!.id;
    
    // Add user message
    final userMessageResult = await addMessage(AddMessageParams(
      conversationId: conversationId,
      sender: SenderType.user,
      content: event.content,
      audioPath: event.audioPath,
      transcription: event.transcription,
    ));
    
    userMessageResult.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (updatedConversation) async {
        // Set conversation with user message
        emit(ConversationActive(
          conversation: updatedConversation,
          recordingState: RecordingState.idle,
          lastRecordingPath: null,
          lastTranscription: null,
          clearLastRecording: true,
        ));
        
        // Get AI response
        final aiResponse = await getAiResponse(GetAiResponseParams(
          conversation: updatedConversation,
        ));
        
        aiResponse.fold(
          (failure) => emit(state.copyWith(
            errorMessage: failure.message,
          )),
          (message) async {
            // Add the AI message
            final aiMessageResult = await addMessage(AddMessageParams(
              conversationId: conversationId,
              sender: SenderType.ai,
              content: message.content,
            ));
            
            aiMessageResult.fold(
              (failure) => emit(state.copyWith(
                errorMessage: failure.message,
              )),
              (finalConversation) => emit(ConversationActive(
                conversation: finalConversation,
              )),
            );
          },
        );
      },
    );
  }

  /// Handles the RequestFeedbackEvent
  Future<void> _onRequestFeedback(
    RequestFeedbackEvent event, 
    Emitter<ConversationState> emit
  ) async {
    if (state.conversation == null) {
      emit(state.copyWith(
        errorMessage: 'No active conversation',
      ));
      return;
    }
    
    emit(state.copyWith(isLoading: true));
    
    final result = await generateFeedback(GenerateFeedbackParams(
      conversationId: state.conversation!.id,
      messageId: event.messageId,
      audioPath: event.audioPath,
      transcription: event.transcription,
    ));
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (feedback) => emit(ConversationFeedbackVisible(
        conversation: state.conversation!,
        feedback: feedback,
      )),
    );
  }

  /// Handles the CloseFeedbackEvent
  void _onCloseFeedback(
    CloseFeedbackEvent event, 
    Emitter<ConversationState> emit
  ) {
    if (state.conversation == null) return;
    
    emit(ConversationActive(
      conversation: state.conversation!,
      recordingState: state.recordingState,
      lastRecordingPath: state.lastRecordingPath,
      lastTranscription: state.lastTranscription,
    ));
  }

  /// Handles the CompleteConversationEvent
  void _onCompleteConversation(
    CompleteConversationEvent event, 
    Emitter<ConversationState> emit
  ) {
    if (state.conversation == null) return;
    
    // In a real implementation, you would update the conversation in the backend
    // Here we just update the local state
    final completedConversation = state.conversation!.copyWith(
      endedAt: DateTime.now(),
    );
    
    emit(ConversationCompleted(conversation: completedConversation));
  }

  /// Handles the StartRecordingEvent
  void _onStartRecording(
    StartRecordingEvent event, 
    Emitter<ConversationState> emit
  ) {
    // In a real implementation, you would start the actual recording
    // Here we just update the state
    emit(state.copyWith(
      recordingState: RecordingState.recording,
      clearLastRecording: true,
    ));
  }

  /// Handles the StopRecordingEvent
  void _onStopRecording(
    StopRecordingEvent event, 
    Emitter<ConversationState> emit
  ) {
    // In a real implementation, you would process the recording
    // Here we just update the state with the transcription
    emit(state.copyWith(
      recordingState: RecordingState.idle,
      lastRecordingPath: event.filePath,
      lastTranscription: event.transcription,
    ));
  }

  /// Handles the CancelRecordingEvent
  void _onCancelRecording(
    CancelRecordingEvent event, 
    Emitter<ConversationState> emit
  ) {
    // In a real implementation, you would cancel and delete the recording
    // Here we just reset the state
    emit(state.copyWith(
      recordingState: RecordingState.idle,
      clearLastRecording: true,
    ));
  }
}
