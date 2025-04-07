class VocabularyEntity {
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final String exampleTranslation;
  final String audioUrl;

  const VocabularyEntity({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.exampleTranslation,
    required this.audioUrl,
  });

  factory VocabularyEntity.fromJson(Map<String, dynamic> json) {
    return VocabularyEntity(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      exampleTranslation: json['exampleTranslation'] as String,
      audioUrl: json['audioUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'audioUrl': audioUrl,
    };
  }
}
