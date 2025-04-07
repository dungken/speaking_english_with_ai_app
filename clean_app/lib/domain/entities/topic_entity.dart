import 'package:flutter/material.dart';

class TopicEntity {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<TopicEntity>? subtopics;
  final String? lessonCount;
  final bool isCompleted;
  final bool isReview;

  TopicEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.subtopics,
    this.lessonCount,
    this.isCompleted = false,
    this.isReview = false,
  });

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get difficultyText {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  /// 📥 Create from JSON
  factory TopicEntity.fromJson(Map<String, dynamic> json) {
    return TopicEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      subtopics: json['subtopics'] != null
          ? (json['subtopics'] as List)
              .map((e) => TopicEntity.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      lessonCount: json['lessonCount'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isReview: json['isReview'] as bool? ?? false,
    );
  }

  /// 📤 Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'subtopics': subtopics?.map((e) => e.toJson()).toList(),
      'lessonCount': lessonCount,
      'isCompleted': isCompleted,
      'isReview': isReview,
    };
  }
}
