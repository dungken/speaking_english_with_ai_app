abstract class TranslateEvent {}

class TranslateText extends TranslateEvent {
  final String text;
  final String targetLanguage;

  TranslateText({
    required this.text,
    required this.targetLanguage,
  });
}
