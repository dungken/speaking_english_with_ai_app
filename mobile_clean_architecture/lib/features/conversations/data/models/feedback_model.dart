import '../../domain/entities/feedback.dart';

/// Model class for feedback data from the API
class FeedbackModel extends FeedbackResult {
  const FeedbackModel({
    required String userFeedback,
    required DetailedFeedback detailedFeedback,
    required DateTime timestamp,
  }) : super(
          userFeedback: userFeedback,
          detailedFeedback: detailedFeedback,
          timestamp: timestamp,
        );

  /// Creates a FeedbackModel from a JSON object
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      userFeedback: json['user_feedback'],
      detailedFeedback: DetailedFeedbackModel.fromJson(json['detailed_feedback']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'user_feedback': userFeedback,
      'detailed_feedback': (detailedFeedback as DetailedFeedbackModel).toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Model class for detailed feedback data from the API
class DetailedFeedbackModel extends DetailedFeedback {
  const DetailedFeedbackModel({
    required List<GrammarIssue> grammarIssues,
    required List<VocabularyIssue> vocabularyIssues,
  }) : super(
          grammarIssues: grammarIssues,
          vocabularyIssues: vocabularyIssues,
        );

  /// Creates a DetailedFeedbackModel from a JSON object
  factory DetailedFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DetailedFeedbackModel(
      grammarIssues: (json['grammar_issues'] as List)
          .map((issue) => GrammarIssueModel.fromJson(issue))
          .toList(),
      vocabularyIssues: (json['vocabulary_issues'] as List)
          .map((issue) => VocabularyIssueModel.fromJson(issue))
          .toList(),
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'grammar_issues': (grammarIssues as List<GrammarIssueModel>)
          .map((issue) => (issue as GrammarIssueModel).toJson())
          .toList(),
      'vocabulary_issues': (vocabularyIssues as List<VocabularyIssueModel>)
          .map((issue) => (issue as VocabularyIssueModel).toJson())
          .toList(),
    };
  }
}

/// Model class for grammar issue data from the API
class GrammarIssueModel extends GrammarIssue {
  const GrammarIssueModel({
    required String issue,
    required String correction,
    required String explanation,
    required int severity,
  }) : super(
          issue: issue,
          correction: correction,
          explanation: explanation,
          severity: severity,
        );

  /// Creates a GrammarIssueModel from a JSON object
  factory GrammarIssueModel.fromJson(Map<String, dynamic> json) {
    return GrammarIssueModel(
      issue: json['issue'],
      correction: json['correction'],
      explanation: json['explanation'],
      severity: json['severity'],
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'issue': issue,
      'correction': correction,
      'explanation': explanation,
      'severity': severity,
    };
  }
}

/// Model class for vocabulary issue data from the API
class VocabularyIssueModel extends VocabularyIssue {
  const VocabularyIssueModel({
    required String original,
    required String betterAlternative,
    required String reason,
    required String exampleUsage,
  }) : super(
          original: original,
          betterAlternative: betterAlternative,
          reason: reason,
          exampleUsage: exampleUsage,
        );

  /// Creates a VocabularyIssueModel from a JSON object
  factory VocabularyIssueModel.fromJson(Map<String, dynamic> json) {
    return VocabularyIssueModel(
      original: json['original'],
      betterAlternative: json['better_alternative'],
      reason: json['reason'],
      exampleUsage: json['example_usage'],
    );
  }

  /// Converts this model to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'better_alternative': betterAlternative,
      'reason': reason,
      'example_usage': exampleUsage,
    };
  }
}
