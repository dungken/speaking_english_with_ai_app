import 'package:flutter/material.dart';

/// 📌 **Onboarding Model**
///
/// This class represents an onboarding screen item in the application.
///
/// Each onboarding item consists of:
/// - `title`: The main heading for the onboarding screen.
/// - `subtitle`: A short description explaining the feature.
/// - `icon`: The icon to display for this step.
/// - `color`: The color to use for the icon.
class Onboard {
  /// 🏷 **Title**
  ///
  /// The main heading or title of the onboarding screen.
  final String title;

  /// 📝 **Subtitle**
  ///
  /// A short description providing more information about the feature.
  final String subtitle;

  /// 🎨 **Icon**
  ///
  /// The icon to display for this step.
  final IconData icon;

  /// 🎨 **Color**
  ///
  /// The color to use for the icon.
  final Color color;

  /// 🔹 **Constructor**
  ///
  /// - `title`: Required title of the onboarding step.
  /// - `subtitle`: Required subtitle explaining the feature.
  /// - `icon`: Required icon for this step.
  /// - `color`: Required color for the icon.
  Onboard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
