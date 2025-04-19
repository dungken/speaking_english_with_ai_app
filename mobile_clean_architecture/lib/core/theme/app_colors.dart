import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF5E6AD2);
  static const primaryLight = Color(0xFF8E96E3);
  static const primaryDark = Color(0xFF3A429E);
  static const accent = Color(0xFF4ECDC4);
  static const accentLight = Color(0xFF7FDED8);
  static const accentDark = Color(0xFF35B3AA);

  // Neutral Colors - Light Mode
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF2D3748);
  static const textSecondaryLight = Color(0xFF718096);

  // Neutral Colors - Dark Mode
  static const backgroundDark = Color(0xFF1A202C);
  static const surfaceDark = Color(0xFF2D3748);
  static const textPrimaryDark = Color(0xFFF7FAFC);
  static const textSecondaryDark = Color(0xFFA0AEC0);

  // Functional Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA000);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF2196F3);

  // Learning-Specific Colors
  static const streakPrimary = Color(0xFFFF9800);
  static const streakLight = Color(0xFFFFB74D);
  static const streakDark = Color(0xFFF57C00);

  // CEFR Level Colors
  static const cefrA1 = Color(0xFFFFD54F);
  static const cefrA2 = Color(0xFFFFA726);
  static const cefrB1 = Color(0xFF66BB6A);
  static const cefrB2 = Color(0xFF43A047);
  static const cefrC1 = Color(0xFF42A5F5);
  static const cefrC2 = Color(0xFF1E88E5);

  // Theme-aware getters
  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? textPrimaryDark : textPrimaryLight;
  }

  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? textSecondaryDark : textSecondaryLight;
  }

  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? surfaceDark : surfaceLight;
  }

  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? backgroundDark : backgroundLight;
  }

  static Color getCefrLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1': return cefrA1;
      case 'A2': return cefrA2;
      case 'B1': return cefrB1;
      case 'B2': return cefrB2;
      case 'C1': return cefrC1;
      case 'C2': return cefrC2;
      default: return cefrA1;
    }
  }

  // Gradient generators
  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [primaryDark, Color(0xFF2E3584)]
          : [primary, primaryDark],
    );
  }

  static LinearGradient getAccentGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, accentDark],
    );
  }

  // Prevent instantiation
  AppColors._();
}
