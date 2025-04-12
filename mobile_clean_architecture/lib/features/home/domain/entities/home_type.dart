import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_type.freezed.dart';
part 'home_type.g.dart';

@freezed
class HomeTypeEntity with _$HomeTypeEntity {
  const factory HomeTypeEntity({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String route,
  }) = _$HomeTypeEntityImpl;

  factory HomeTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$HomeTypeEntityFromJson(json);
}

enum HomeType {
  conversation,
  imageDescription,
  topics,
  profile;

  String get title {
    switch (this) {
      case HomeType.conversation:
        return 'Conversation';
      case HomeType.imageDescription:
        return 'Image Description';
      case HomeType.topics:
        return 'Topics';
      case HomeType.profile:
        return 'Profile';
    }
  }

  String get description {
    switch (this) {
      case HomeType.conversation:
        return 'Practice conversations in different scenarios';
      case HomeType.imageDescription:
        return 'Describe images and improve your vocabulary';
      case HomeType.topics:
        return 'Explore various topics and learn new words';
      case HomeType.profile:
        return 'Manage your profile and preferences';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeType.conversation:
        return Icons.chat_bubble_outline;
      case HomeType.imageDescription:
        return Icons.image_outlined;
      case HomeType.topics:
        return Icons.topic_outlined;
      case HomeType.profile:
        return Icons.person_outline;
    }
  }
}
