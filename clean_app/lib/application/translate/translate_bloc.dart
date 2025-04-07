import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/ai_repository.dart';
import 'translate_event.dart';
import 'translate_state.dart';

class TranslateBloc extends Bloc<TranslateEvent, TranslateState> {
  final AiRepository aiRepository;

  TranslateBloc({required this.aiRepository}) : super(TranslateInitial()) {
    on<TranslateText>(_onTranslateText);
  }

  Future<void> _onTranslateText(
    TranslateText event,
    Emitter<TranslateState> emit,
  ) async {
    try {
      emit(TranslateLoading());
      final translatedText = await aiRepository.translateText(
        event.text,
        event.targetLanguage,
      );
      emit(TranslateSuccess(translatedText));
    } catch (e) {
      emit(TranslateError(e.toString()));
    }
  }
}
