import 'package:flutter/material.dart';

/// A utility class that manages responsive layout calculations based on screen size.
/// Provides consistent spacing, breakpoints, and sizing across the application.
class ResponsiveLayout {
  static const double _smallScreenWidth = 320.0;
  static const double _mediumScreenWidth = 375.0;
  static const double _largeScreenWidth = 414.0;
  static const double _tabletScreenWidth = 768.0;

  /// Get the current screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < _smallScreenWidth) return ScreenType.extraSmall;
    if (width < _mediumScreenWidth) return ScreenType.small;
    if (width < _largeScreenWidth) return ScreenType.medium;
    if (width < _tabletScreenWidth) return ScreenType.large;
    return ScreenType.tablet;
  }

  /// Calculate grid columns based on screen width
  static int getGridColumns(BuildContext context, {int defaultColumns = 2}) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
      case ScreenType.small:
        return defaultColumns <= 2 ? defaultColumns : 2;
      case ScreenType.medium:
        return defaultColumns;
      case ScreenType.large:
      case ScreenType.tablet:
        return defaultColumns > 2 ? defaultColumns : defaultColumns + 1;
    }
  }

  /// Calculate the appropriate item spacing based on screen size
  static double getSpacing(BuildContext context, {double defaultSpacing = 16.0}) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
        return defaultSpacing * 0.75;
      case ScreenType.small:
        return defaultSpacing * 0.85;
      case ScreenType.medium:
        return defaultSpacing;
      case ScreenType.large:
        return defaultSpacing * 1.1;
      case ScreenType.tablet:
        return defaultSpacing * 1.25;
    }
  }

  /// Calculate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
        return const EdgeInsets.all(12.0);
      case ScreenType.small:
        return const EdgeInsets.all(16.0);
      case ScreenType.medium:
      case ScreenType.large:
        return const EdgeInsets.all(20.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
    }
  }

  /// Calculate the best title text size based on screen size
  static double getTitleTextSize(BuildContext context, {double defaultSize = 20.0}) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
        return defaultSize * 0.85;
      case ScreenType.small:
        return defaultSize * 0.9;
      case ScreenType.medium:
        return defaultSize;
      case ScreenType.large:
        return defaultSize * 1.05;
      case ScreenType.tablet:
        return defaultSize * 1.1;
    }
  }

  /// Calculate child aspect ratio for grid items based on screen size
  static double getGridAspectRatio(BuildContext context, {double defaultRatio = 0.85}) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
        return defaultRatio * 0.9; // More compact
      case ScreenType.small:
        return defaultRatio * 0.95;
      case ScreenType.medium:
        return defaultRatio;
      case ScreenType.large:
        return defaultRatio * 1.05;
      case ScreenType.tablet:
        return defaultRatio * 1.1; // More spacious
    }
  }
  
  /// Calculate the appropriate section spacing
  static double getSectionSpacing(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.extraSmall:
        return 16.0;
      case ScreenType.small:
        return 20.0;
      case ScreenType.medium:
        return 24.0;
      case ScreenType.large:
        return 28.0;
      case ScreenType.tablet:
        return 32.0;
    }
  }
}

/// Enum representing different screen size categories
enum ScreenType {
  extraSmall,  // Smaller phones
  small,       // Small phones (iPhone SE size)
  medium,      // Average phones (iPhone X/11/12)
  large,       // Large phones (iPhone Plus, Samsung S series)
  tablet       // Tablets and large foldables
}
