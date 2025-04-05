import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';
import '../screen/feature/image_feature.dart';
import '../screen/feature/settings_feature.dart';
import '../screen/feature/profile_feature.dart';
import '../screen/feature/topic_selection_screen.dart';

/// Enum representing different features of the application.
enum HomeType {
  createSituations,
  chooseTopic,
  describeImage,
  progressTracking,
  settings,
  profile
}

/// Extension that provides additional properties and functions for `HomeType`.
extension MyHomeType on HomeType {
  /// 📌 **Title for each feature**
  ///
  /// Returns the display title corresponding to the selected feature.
  String get title => switch (this) {
        HomeType.createSituations => 'Create Situations & Dialogues',
        HomeType.chooseTopic => 'Choose a Topic to Study',
        HomeType.describeImage => 'Describe Image',
        HomeType.progressTracking => 'Progress Tracking',
        HomeType.settings => 'Settings',
        HomeType.profile => 'Profile',
      };

  /// 🎥 **Lottie animation file name for each feature**
  ///
  /// Used for displaying animations associated with each feature.
  String get lottie => switch (this) {
        HomeType.createSituations => 'ai_hand_waving.json',
        HomeType.chooseTopic => 'ai_play.json',
        HomeType.describeImage => 'ai_ask_me.json',
        HomeType.progressTracking => 'ai_hand_waving.json',
        HomeType.settings => 'ai_play.json',
        HomeType.profile => 'ai_ask_me.json',
      };

  /// 🔄 **Alignment of the content**
  ///
  /// - `true`: Align content to the left.
  /// - `false`: Align content to the right.
  bool get leftAlign => switch (this) {
        HomeType.createSituations => true,
        HomeType.chooseTopic => false,
        HomeType.describeImage => true,
        HomeType.progressTracking => false,
        HomeType.settings => true,
        HomeType.profile => false,
      };

  /// 📏 **Padding configuration for the content**
  ///
  /// Defines the amount of padding applied to each feature's UI.
  EdgeInsets get padding => switch (this) {
        HomeType.createSituations => EdgeInsets.zero,
        HomeType.chooseTopic => const EdgeInsets.all(20),
        HomeType.describeImage => EdgeInsets.zero,
        HomeType.progressTracking => const EdgeInsets.all(20),
        HomeType.settings => EdgeInsets.zero,
        HomeType.profile => const EdgeInsets.all(20),
      };

  /// 🎨 **Icon for each feature**
  ///
  /// Returns the icon corresponding to the selected feature.
  IconData get icon => switch (this) {
        HomeType.createSituations => Icons.chat_bubble_outline,
        HomeType.chooseTopic => Icons.topic_outlined,
        HomeType.describeImage => Icons.image_outlined,
        HomeType.progressTracking => Icons.trending_up_outlined,
        HomeType.settings => Icons.settings_outlined,
        HomeType.profile => Icons.person_outline,
      };

  /// 🚀 **Navigation function**
  ///
  /// Defines the action to be performed when tapping on a feature.
  VoidCallback get onTap => switch (this) {
        HomeType.createSituations => () => Get.to(() => const ChatBotFeature()),
        HomeType.chooseTopic => () =>
            Get.to(() => const TopicSelectionScreen()),
        HomeType.describeImage => () => Get.to(() => const ImageFeature()),
        HomeType.progressTracking => () => Get.to(() => const ChatBotFeature()),
        HomeType.settings => () => Get.to(() => const SettingsFeature()),
        HomeType.profile => () => Get.to(() => const ProfileFeature()),
      };
}
