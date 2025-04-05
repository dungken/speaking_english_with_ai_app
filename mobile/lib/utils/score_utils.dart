import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// Utility functions for handling scores and related UI elements
class ScoreUtils {
  /// Gets the appropriate color based on the score
  static Color getScoreColor(double score) {
    if (score >= UIConstants.scoreThresholdHigh) return Colors.green;
    if (score >= UIConstants.scoreThresholdMedium) return Colors.orange;
    return Colors.red;
  }

  /// Gets the feedback message based on the score
  static String getScoreFeedback(double score) {
    if (score >= UIConstants.scoreThresholdHigh) {
      return 'Excellent! Keep up the good work!';
    }
    if (score >= UIConstants.scoreThresholdMedium) {
      return 'Good progress! Practice more to improve.';
    }
    return 'Keep practicing! You\'ll get better with time.';
  }

  /// Formats the score as a percentage string
  static String formatScorePercentage(double score) {
    return '${(score * 100).toStringAsFixed(0)}%';
  }
}
