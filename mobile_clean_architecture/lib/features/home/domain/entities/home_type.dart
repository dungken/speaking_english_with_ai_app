import 'package:flutter/material.dart';

enum HomeType {
  conversations,
  topics,
  imageDescription,
  profile;

  String get title {
    switch (this) {
      case HomeType.conversations:
        return 'Conversations';
      case HomeType.topics:
        return 'Topics';
      case HomeType.imageDescription:
        return 'Image Description';
      case HomeType.profile:
        return 'Profile';
    }
  }

  String get description {
    switch (this) {
      case HomeType.conversations:
        return 'Practice conversations with AI';
      case HomeType.topics:
        return 'Explore different topics';
      case HomeType.imageDescription:
        return 'Describe images in English';
      case HomeType.profile:
        return 'Manage your profile';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeType.conversations:
        return Icons.chat_bubble_outline;
      case HomeType.topics:
        return Icons.topic_outlined;
      case HomeType.imageDescription:
        return Icons.image_outlined;
      case HomeType.profile:
        return Icons.person_outline;
    }
  }
}
