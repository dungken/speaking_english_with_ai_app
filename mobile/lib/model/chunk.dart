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
}
