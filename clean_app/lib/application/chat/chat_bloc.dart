import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';

// Events
abstract class ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage(this.message);
}

class TranslateMessage extends ChatEvent {
  final String message;
  final String targetLanguage;

  TranslateMessage(this.message, this.targetLanguage);
}

class GenerateImage extends ChatEvent {
  final String prompt;

  GenerateImage(this.prompt);
}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {
  final List<ChatMessage> messages;

  ChatSuccess(this.messages);
}

class ChatFailure extends ChatState {
  final String error;

  ChatFailure(this.error);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AiRepository _aiRepository;
  final List<ChatMessage> _messages = [];

  ChatBloc({required AiRepository aiRepository})
      : _aiRepository = aiRepository,
        super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<TranslateMessage>(_onTranslateMessage);
    on<GenerateImage>(_onGenerateImage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // Add user message
      _messages.add(ChatMessage.user(event.message));
      emit(ChatSuccess(List.from(_messages)));

      // Get AI response
      final aiResponse = await _aiRepository.sendMessage(event.message);
      _messages.add(aiResponse);
      emit(ChatSuccess(List.from(_messages)));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onTranslateMessage(
    TranslateMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final translatedText = await _aiRepository.translateText(
        event.message,
        event.targetLanguage,
      );
      _messages.add(ChatMessage.ai(translatedText));
      emit(ChatSuccess(List.from(_messages)));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onGenerateImage(
    GenerateImage event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final imageUrl = await _aiRepository.generateImage(event.prompt);
      _messages.add(ChatMessage.ai('Generated image: $imageUrl'));
      emit(ChatSuccess(List.from(_messages)));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }
}
