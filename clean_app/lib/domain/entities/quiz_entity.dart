class QuizEntity {
  final String question;
  final String questionTranslation;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const QuizEntity({
    required this.question,
    required this.questionTranslation,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizEntity.fromJson(Map<String, dynamic> json) {
    return QuizEntity(
      question: json['question'] as String,
      questionTranslation: json['questionTranslation'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionTranslation': questionTranslation,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
