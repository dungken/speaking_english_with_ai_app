import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

// Events
abstract class ConversationEvent {}

class CreateConversation extends ConversationEvent {
  final String userRole;
  final String aiRole;
  final String situation;

  CreateConversation({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });
}

class SendMessage extends ConversationEvent {
  final String conversationId;
  final String message;

  SendMessage({
    required this.conversationId,
    required this.message,
  });
}

class LoadConversationHistory extends ConversationEvent {
  final String conversationId;

  LoadConversationHistory(this.conversationId);
}

class EndConversation extends ConversationEvent {
  final String conversationId;

  EndConversation(this.conversationId);
}

// States
abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationSuccess extends ConversationState {
  final List<ChatMessage> messages;
  final String? conversationId;

  ConversationSuccess({
    required this.messages,
    this.conversationId,
  });
}

class ConversationFailure extends ConversationState {
  final String error;

  ConversationFailure(this.error);
}

class ConversationHistoryLoaded extends ConversationState {
  final List<ChatMessage> messages;

  ConversationHistoryLoaded(this.messages);
}

class ConversationEnded extends ConversationState {
  final Map<String, dynamic> feedback;

  ConversationEnded(this.feedback);
}

// Bloc
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _repository;
  List<ChatMessage> _messages = [];

  ConversationBloc({required ConversationRepository repository})
      : _repository = repository,
        super(ConversationInitial()) {
    on<CreateConversation>(_onCreateConversation);
    on<SendMessage>(_onSendMessage);
    on<LoadConversationHistory>(_onLoadConversationHistory);
    on<EndConversation>(_onEndConversation);
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final conversation = Conversation(
        userRole: event.userRole,
        aiRole: event.aiRole,
        situation: event.situation,
      );

      final result = await _repository.createConversation(conversation);

      // Handle the initial AI message
      if (result['initial_message'] != null) {
        _messages.add(ChatMessage.ai(result['initial_message']['text']));
      }

      emit(ConversationSuccess(
        messages: List.from(_messages),
        conversationId: result['conversation']['id'],
      ));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      // Add user message immediately
      _messages.add(ChatMessage.user(event.message));
      emit(ConversationSuccess(
        messages: List.from(_messages),
        conversationId: event.conversationId,
      ));

      final result = await _repository.sendMessage(
        event.conversationId,
        event.message,
      );

      // Add AI response
      _messages.add(ChatMessage.ai(result['text']));
      emit(ConversationSuccess(
        messages: List.from(_messages),
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }

  Future<void> _onLoadConversationHistory(
    LoadConversationHistory event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      _messages =
          await _repository.getConversationHistory(event.conversationId);
      emit(ConversationHistoryLoaded(_messages));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }

  Future<void> _onEndConversation(
    EndConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final feedback = await _repository.endConversation(event.conversationId);
      emit(ConversationEnded(feedback));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }
}
