import 'package:equatable/equatable.dart';

/// Grammar issue in the feedback
class GrammarIssue extends Equatable {
  final String issue;
  final String correction;
  final String explanation;

  const GrammarIssue({
    required this.issue,
    required this.correction,
    required this.explanation,
  });

  @override
  List<Object?> get props => [issue, correction, explanation];
}

/// Vocabulary issue in the feedback
class VocabularyIssue extends Equatable {
  final String original;
  final String betterAlternative;
  final String reason;
  final String exampleUsage;

  const VocabularyIssue({
    required this.original,
    required this.betterAlternative,
    required this.reason,
    required this.exampleUsage,
  });

  @override
  List<Object?> get props => [original, betterAlternative, reason, exampleUsage];
}

/// Detailed feedback section containing specific aspects of language analysis
class DetailedFeedback extends Equatable {
  final List<GrammarIssue> grammarIssues;
  final List<VocabularyIssue> vocabularyIssues;
  final List<String> positives;
  final List<String> fluency;

  const DetailedFeedback({
    required this.grammarIssues,
    required this.vocabularyIssues,
    required this.positives,
    required this.fluency,
  });

  @override
  List<Object?> get props => [grammarIssues, vocabularyIssues, positives, fluency];
}

/// Feedback entity representing language analysis of a user's message
class FeedbackResult extends Equatable {
  final String id;
  final String userFeedback;
  final DateTime createdAt;
  final DetailedFeedback? detailedFeedback;

  const FeedbackResult({
    required this.id,
    required this.userFeedback,
    required this.createdAt,
    this.detailedFeedback,
  });

  @override
  List<Object?> get props => [id, userFeedback, createdAt, detailedFeedback];
}

/// Alias type to maintain compatibility with new API code
typedef Feedback = FeedbackResult;
