import 'package:flutter/material.dart';

class UIConfig {
  // Border radii
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;
  
  // Elevation levels
  static const double cardElevation = 2.0;
  static const double modalElevation = 8.0;
  static const double buttonElevation = 2.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 250);
  static const Duration longAnimation = Duration(milliseconds: 300);
  
  // Icon sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  
  // Touch targets
  static const double minTouchTargetSize = 44.0;
  
  // Spacing
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 320) return 12.0;
    if (width > 600) return 24.0;
    return 16.0;
  }
  
  static double getVerticalSpacing(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 600) return 16.0;
    if (height > 900) return 24.0;
    return 20.0;
  }

  // Component-specific sizes
  static double getAvatarSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 320) return 32.0;
    if (width > 600) return 48.0;
    return 40.0;
  }

  static double getMicButtonSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 320) return 56.0;
    if (width > 600) return 72.0;
    return 64.0;
  }

  // Opacity levels for emphasis hierarchy
  static const double primaryOpacity = 1.0;
  static const double secondaryOpacity = 0.85;
  static const double tertiaryOpacity = 0.65;
  static const double disabledOpacity = 0.38;

  // Method to check contrast ratio for accessibility
  static bool hasAdequateContrast(Color foreground, Color background) {
    double luminance1 = foreground.computeLuminance();
    double luminance2 = background.computeLuminance();
    double brightest = luminance1 > luminance2 ? luminance1 : luminance2;
    double darkest = luminance1 < luminance2 ? luminance1 : luminance2;
    return (brightest + 0.05) / (darkest + 0.05) >= 4.5;
  }
}
