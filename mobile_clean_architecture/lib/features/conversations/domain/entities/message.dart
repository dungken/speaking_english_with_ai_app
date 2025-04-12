import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class Message extends Equatable {
  final String text;
  final MessageRole role;
  final String? audioUrl;
  final Feedback? feedback;

  const Message({
    required this.text,
    required this.role,
    this.audioUrl,
    this.feedback,
  });

  @override
  List<Object?> get props => [text, role, audioUrl, feedback];
}

class Feedback extends Equatable {
  final List<GrammarIssue> grammar;
  final List<VocabularyIssue> vocabulary;
  final PronunciationFeedback? pronunciation;

  const Feedback({
    required this.grammar,
    required this.vocabulary,
    this.pronunciation,
  });

  @override
  List<Object?> get props => [grammar, vocabulary, pronunciation];
}

class GrammarIssue extends Equatable {
  final String mistake;
  final String suggestion;
  final String explanation;

  const GrammarIssue({
    required this.mistake,
    required this.suggestion,
    required this.explanation,
  });

  @override
  List<Object> get props => [mistake, suggestion, explanation];
}

class VocabularyIssue extends Equatable {
  final String word;
  final String alternative;
  final String reason;

  const VocabularyIssue({
    required this.word,
    required this.alternative,
    required this.reason,
  });

  @override
  List<Object> get props => [word, alternative, reason];
}

class PronunciationFeedback extends Equatable {
  final double score;
  final String details;

  const PronunciationFeedback({
    required this.score,
    required this.details,
  });

  @override
  List<Object> get props => [score, details];
}
