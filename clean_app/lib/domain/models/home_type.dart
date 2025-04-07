import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';

enum HomeType {
  rolePlay(
    title: 'Role Play',
    subtitle: 'Practice conversations in different scenarios',
    icon: Icons.people,
    color: Colors.blue,
  ),

  imageDescription(
    title: 'Describe Images',
    subtitle: 'Practice describing images in English',
    icon: Icons.image,
    color: Colors.purple,
  ),

  topicSelection(
    title: 'Topic Selection',
    subtitle: 'Choose topics to practice vocabulary and grammar',
    icon: Icons.topic,
    color: Colors.orange,
  ),

  translator(
    title: 'Translator',
    subtitle: 'Translate text between languages',
    icon: Icons.translate,
    color: Colors.green,
  ),

  profile(
    title: 'Profile',
    subtitle: 'View and edit your profile',
    icon: Icons.person,
    color: Colors.indigo,
  ),

  settings(
    title: 'Settings',
    subtitle: 'Configure app settings',
    icon: Icons.settings,
    color: Colors.grey,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const HomeType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  void onTap() {
    switch (this) {
      case HomeType.rolePlay:
        Get.toNamed(AppRoutes.rolePlay);
        break;
      case HomeType.imageDescription:
        Get.toNamed(AppRoutes.imageDescription);
        break;
      case HomeType.topicSelection:
        Get.toNamed(AppRoutes.topicSelection);
        break;
      case HomeType.translator:
        Get.toNamed(AppRoutes.translate);
        break;
      case HomeType.profile:
        Get.toNamed(AppRoutes.profile);
        break;
      case HomeType.settings:
        Get.toNamed(AppRoutes.settings);
        break;
    }
  }
}
