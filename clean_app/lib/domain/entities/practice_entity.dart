class PracticeEntity {
  final String question;
  final String questionTranslation;
  final String answer;
  final String answerTranslation;
  final String hint;
  final String hintTranslation;

  const PracticeEntity({
    required this.question,
    required this.questionTranslation,
    required this.answer,
    required this.answerTranslation,
    required this.hint,
    required this.hintTranslation,
  });

  factory PracticeEntity.fromJson(Map<String, dynamic> json) {
    return PracticeEntity(
      question: json['question'] as String,
      questionTranslation: json['questionTranslation'] as String,
      answer: json['answer'] as String,
      answerTranslation: json['answerTranslation'] as String,
      hint: json['hint'] as String,
      hintTranslation: json['hintTranslation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionTranslation': questionTranslation,
      'answer': answer,
      'answerTranslation': answerTranslation,
      'hint': hint,
      'hintTranslation': hintTranslation,
    };
  }
}
