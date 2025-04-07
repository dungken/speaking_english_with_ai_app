class ChunkEntity {
  final String phrase;
  final String translation;
  final String audioUrl;

  const ChunkEntity({
    required this.phrase,
    required this.translation,
    required this.audioUrl,
  });

  factory ChunkEntity.fromJson(Map<String, dynamic> json) {
    return ChunkEntity(
      phrase: json['phrase'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audioUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phrase': phrase,
      'translation': translation,
      'audioUrl': audioUrl,
    };
  }
}
