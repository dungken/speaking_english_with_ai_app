abstract class TranslateState {}

class TranslateInitial extends TranslateState {}

class TranslateLoading extends TranslateState {}

class TranslateSuccess extends TranslateState {
  final String translatedText;

  TranslateSuccess(this.translatedText);
}

class TranslateError extends TranslateState {
  final String message;

  TranslateError(this.message);
}
