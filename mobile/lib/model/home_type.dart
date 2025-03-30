import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';
import '../screen/feature/image_feature.dart';
import '../screen/feature/translator_feature.dart';

/// Enum representing different features of the application.
enum HomeType { aiChatBot, aiImage, aiTranslator }

/// Extension that provides additional properties and functions for `HomeType`.
extension MyHomeType on HomeType {
  /// 📌 **Title for each feature**
  ///
  /// Returns the display title corresponding to the selected feature.
  String get title => switch (this) {
        HomeType.aiChatBot => 'AI ChatBot',
        HomeType.aiImage => 'AI Image Creator',
        HomeType.aiTranslator => 'Language Translator',
      };

  /// 🎥 **Lottie animation file name for each feature**
  ///
  /// Used for displaying animations associated with each feature.
  String get lottie => switch (this) {
        HomeType.aiChatBot => 'ai_hand_waving.json',
        HomeType.aiImage => 'ai_play.json',
        HomeType.aiTranslator => 'ai_ask_me.json',
      };

  /// 🔄 **Alignment of the content**
  ///
  /// - `true`: Align content to the left.
  /// - `false`: Align content to the right.
  bool get leftAlign => switch (this) {
        HomeType.aiChatBot => true,
        HomeType.aiImage => false,
        HomeType.aiTranslator => true,
      };

  /// 📏 **Padding configuration for the content**
  ///
  /// Defines the amount of padding applied to each feature’s UI.
  EdgeInsets get padding => switch (this) {
        HomeType.aiChatBot => EdgeInsets.zero,
        HomeType.aiImage => const EdgeInsets.all(20),
        HomeType.aiTranslator => EdgeInsets.zero,
      };

  /// 🚀 **Navigation function**
  ///
  /// Defines the action to be performed when tapping on a feature.
  VoidCallback get onTap => switch (this) {
        HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),
        HomeType.aiImage => () => Get.to(() => const ImageFeature()),
        HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
      };
}
