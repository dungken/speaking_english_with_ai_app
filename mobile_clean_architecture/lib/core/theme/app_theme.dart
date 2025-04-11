/// app_theme.dart
///
/// This file defines the application's theme configuration.
/// It provides consistent styling across the app using Material Design 3.
///
/// Key features:
/// - Defines light and dark theme variants
/// - Sets up color schemes based on a seed color
/// - Configures common widget themes (AppBar, Cards)
/// - Ensures consistent visual hierarchy

import 'package:flutter/material.dart';

/// Central theme configuration for the application
///
/// This class:
/// - Provides light and dark theme variants
/// - Uses Material Design 3
/// - Maintains consistent styling across the app
class AppTheme {
  /// Light theme configuration
  ///
  /// Features:
  /// - Material 3 design system
  /// - Light color scheme based on blue seed color
  /// - Centered app bar with no elevation
  /// - Elevated cards with rounded corners
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Dark theme configuration
  ///
  /// Features:
  /// - Material 3 design system
  /// - Dark color scheme based on blue seed color
  /// - Consistent styling with light theme
  /// - Same card and app bar configurations
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
