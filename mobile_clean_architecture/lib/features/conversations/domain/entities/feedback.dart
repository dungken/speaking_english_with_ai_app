import 'package:equatable/equatable.dart';

/// Class that represents the feedback provided on user's speech
///
/// Contains both user-friendly feedback text and structured detailed feedback
/// for more in-depth analysis and mistake tracking
class FeedbackResult extends Equatable {
  /// Simple, user-friendly feedback text
  final String userFeedback;
  
  /// Detailed, structured feedback for analysis
  final DetailedFeedback detailedFeedback;
  
  /// When the feedback was generated
  final DateTime timestamp;

  const FeedbackResult({
    required this.userFeedback,
    required this.detailedFeedback,
    required this.timestamp,
  });

  /// Generate user-friendly text from the detailed feedback
  String generateUserFriendlyText() {
    // Simple version that just returns the pre-generated text
    return userFeedback;
  }

  @override
  List<Object?> get props => [userFeedback, detailedFeedback, timestamp];
}

/// Structured detailed feedback containing grammar and vocabulary issues
class DetailedFeedback extends Equatable {
  /// List of grammar issues identified in the user's speech
  final List<GrammarIssue> grammarIssues;
  
  /// List of vocabulary issues identified in the user's speech
  final List<VocabularyIssue> vocabularyIssues;

  const DetailedFeedback({
    required this.grammarIssues,
    required this.vocabularyIssues,
  });

  /// Extract all issues as a list of mistakes for practice
  List<dynamic> extractMistakes() {
    return [
      ...grammarIssues,
      ...vocabularyIssues,
    ];
  }

  @override
  List<Object?> get props => [grammarIssues, vocabularyIssues];
}

/// Identifies a grammar error in the user's speech
class GrammarIssue extends Equatable {
  /// Description of the issue
  final String issue;
  
  /// Corrected version
  final String correction;
  
  /// Explanation of why the correction is needed
  final String explanation;
  
  /// Severity of the issue (1-10 scale, 10 being most severe)
  final int severity;

  const GrammarIssue({
    required this.issue,
    required this.correction,
    required this.explanation,
    required this.severity,
  });

  @override
  List<Object?> get props => [issue, correction, explanation, severity];
}

/// Identifies a vocabulary issue in the user's speech
class VocabularyIssue extends Equatable {
  /// Original word or phrase used
  final String original;
  
  /// Better alternative(s)
  final String betterAlternative;
  
  /// Explanation of why the alternative is better
  final String reason;
  
  /// Example of the word/phrase used correctly in a sentence
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
