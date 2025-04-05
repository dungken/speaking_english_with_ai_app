import 'package:flutter/material.dart';

enum TopicDifficulty {
  easy,
  medium,
  hard,
}

class Topic {
  final String title;
  final String description;
  final TopicDifficulty difficulty;
  final List<Topic>? subtopics;
  final String? lessonCount;
  final bool isCompleted;
  final bool isReview;

  Topic({
    required this.title,
    required this.description,
    required this.difficulty,
    this.subtopics,
    this.lessonCount,
    this.isCompleted = false,
    this.isReview = false,
  });

  Color get difficultyColor {
    switch (difficulty) {
      case TopicDifficulty.easy:
        return Colors.green;
      case TopicDifficulty.medium:
        return Colors.orange;
      case TopicDifficulty.hard:
        return Colors.red;
    }
  }

  String get difficultyText {
    switch (difficulty) {
      case TopicDifficulty.easy:
        return 'Easy';
      case TopicDifficulty.medium:
        return 'Medium';
      case TopicDifficulty.hard:
        return 'Hard';
    }
  }
}
