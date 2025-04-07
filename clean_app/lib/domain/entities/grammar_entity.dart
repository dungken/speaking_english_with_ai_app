class GrammarEntity {
  final String title;
  final String description;
  final String explanation;
  final String example;
  final String exampleTranslation;
  final List<String> practiceQuestions;
  final List<String> practiceAnswers;

  const GrammarEntity({
    required this.title,
    required this.description,
    required this.explanation,
    required this.example,
    required this.exampleTranslation,
    required this.practiceQuestions,
    required this.practiceAnswers,
  });

  factory GrammarEntity.fromJson(Map<String, dynamic> json) {
    return GrammarEntity(
      title: json['title'] as String,
      description: json['description'] as String,
      explanation: json['explanation'] as String,
      example: json['example'] as String,
      exampleTranslation: json['exampleTranslation'] as String,
      practiceQuestions: List<String>.from(json['practiceQuestions'] as List),
      practiceAnswers: List<String>.from(json['practiceAnswers'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'explanation': explanation,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'practiceQuestions': practiceQuestions,
      'practiceAnswers': practiceAnswers,
    };
  }
}
