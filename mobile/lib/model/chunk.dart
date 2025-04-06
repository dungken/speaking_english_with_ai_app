class Chunk {
  final String phrase;
  final String meaning;
  final String audioUrl;
  final bool isLearned;

  const Chunk({
    required this.phrase,
    required this.meaning,
    required this.audioUrl,
    this.isLearned = false,
  });

  factory Chunk.fromJson(Map<String, dynamic> json) {
    return Chunk(
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String,
      audioUrl: json['audioUrl'] as String,
      isLearned: json['isLearned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'phrase': phrase,
        'meaning': meaning,
        'audioUrl': audioUrl,
        'isLearned': isLearned,
      };
}
