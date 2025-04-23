import '../../domain/entities/feedback.dart';

/// Model class for grammar issues
class GrammarIssueModel extends GrammarIssue {
  const GrammarIssueModel({
    required String issue,
    required String correction,
    required String explanation,
  }) : super(
    issue: issue,
    correction: correction,
    explanation: explanation,
  );

  factory GrammarIssueModel.fromJson(Map<String, dynamic> json) {
    return GrammarIssueModel(
      issue: json['issue'],
      correction: json['correction'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue': issue,
      'correction': correction,
      'explanation': explanation,
    };
  }
}

/// Model class for vocabulary issues
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

  factory VocabularyIssueModel.fromJson(Map<String, dynamic> json) {
    return VocabularyIssueModel(
      original: json['original'],
      betterAlternative: json['better_alternative'],
      reason: json['reason'],
      exampleUsage: json['example_usage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'better_alternative': betterAlternative,
      'reason': reason,
      'example_usage': exampleUsage,
    };
  }
}

/// Model class for the detailed feedback section
class DetailedFeedbackModel extends DetailedFeedback {
  const DetailedFeedbackModel({
    required List<GrammarIssue> grammarIssues,
    required List<VocabularyIssue> vocabularyIssues,
    required List<String> positives,
    required List<String> fluency,
  }) : super(
    grammarIssues: grammarIssues,
    vocabularyIssues: vocabularyIssues,
    positives: positives,
    fluency: fluency,
  );

  /// Factory method to create a detailed feedback model from JSON
  factory DetailedFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DetailedFeedbackModel(
      grammarIssues: (json['grammar_issues'] as List<dynamic>? ?? [])
          .map((issue) => GrammarIssueModel.fromJson(issue))
          .toList(),
      vocabularyIssues: (json['vocabulary_issues'] as List<dynamic>? ?? [])
          .map((issue) => VocabularyIssueModel.fromJson(issue))
          .toList(),
      positives: List<String>.from(json['positives'] ?? []),
      fluency: List<String>.from(json['fluency'] ?? []),
    );
  }

  /// Convert the detailed feedback model to JSON
  Map<String, dynamic> toJson() {
    return {
      'grammar_issues': grammarIssues.map((issue) => (issue as GrammarIssueModel).toJson()).toList(),
      'vocabulary_issues': vocabularyIssues.map((issue) => (issue as VocabularyIssueModel).toJson()).toList(),
      'positives': positives,
      'fluency': fluency,
    };
  }
}

/// Model class for the feedback entity
class FeedbackModel extends FeedbackResult {
  const FeedbackModel({
    required String id,
    required String userFeedback,
    required DateTime createdAt,
    DetailedFeedback? detailedFeedback,
  }) : super(
    id: id,
    userFeedback: userFeedback,
    createdAt: createdAt,
    detailedFeedback: detailedFeedback,
  );

  /// Factory method to create a feedback model from JSON
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    DetailedFeedback? detailedFeedback;
    
    // Only try to parse detailed feedback if it exists
    if (json.containsKey('detailed_feedback') && json['detailed_feedback'] != null) {
      detailedFeedback = DetailedFeedbackModel.fromJson(json['detailed_feedback']);
    }
    
    return FeedbackModel(
      id: json['id'],
      userFeedback: json['user_feedback'],
      createdAt: DateTime.parse(json['created_at']),
      detailedFeedback: detailedFeedback,
    );
  }

  /// Convert the feedback model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'user_feedback': userFeedback,
      'created_at': createdAt.toIso8601String(),
    };
    
    if (detailedFeedback != null) {
      json['detailed_feedback'] = (detailedFeedback as DetailedFeedbackModel).toJson();
    }
    
    return json;
  }
}
