import 'package:flutter/material.dart';

/// A centralized color system that provides a harmonious and accessible color palette
/// for the SpeakBetter application. These colors follow material design principles
/// while maintaining a unique brand identity.
/// 
/// The palette focuses on:
/// - Creating visual hierarchy through intentional contrast
/// - Maintaining accessibility standards (WCAG AA compliance)
/// - Supporting both light and dark modes with appropriate color mapping
/// - Using color semantically to convey meaning and guide user attention
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF5E6AD2);         // Primary indigo - core brand color
  static const Color primaryLight = Color(0xFF8E96E3);    // Lighter variant for backgrounds, selected states
  static const Color primaryDark = Color(0xFF3A429E);     // Darker variant for pressed states, text on light bg
  
  // Secondary accent colors
  static const Color accent = Color(0xFF4ECDC4);          // Teal accent - for progress, success
  static const Color accentLight = Color(0xFF7FDED8);     // Lighter teal for backgrounds, highlights
  static const Color accentDark = Color(0xFF35B3AA);      // Darker teal for pressed states, text
  
  // Semantic colors for feedback and status
  static const Color success = Color(0xFF4CAF50);         // Green for success states
  static const Color warning = Color(0xFFFFA000);         // Amber for warnings, important information
  static const Color error = Color(0xFFE53935);           // Red for errors, critical actions
  static const Color info = Color(0xFF2196F3);            // Blue for information, tips
  
  // Neutral colors for backgrounds, text, and surfaces
  static const Color background = Color(0xFFF8FAFC);      // Light background (light mode)
  static const Color backgroundDark = Color(0xFF1A202C);  // Dark background (dark mode)
  static const Color surface = Color(0xFFFFFFFF);         // Surface color (light mode)
  static const Color surfaceDark = Color(0xFF2D3748);     // Surface color (dark mode)
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D3748);     // Primary text (light mode)
  static const Color textPrimaryDark = Color(0xFFF7FAFC); // Primary text (dark mode)
  static const Color textSecondary = Color(0xFF718096);   // Secondary text (light mode)
  static const Color textSecondaryDark = Color(0xFFA0AEC0); // Secondary text (dark mode)
  
  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF5E6AD2),
    Color(0xFF4856C6),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF4ECDC4),
    Color(0xFF3BBEB5),
  ];
  
  // Achievement and streak colors
  static const Color streakPrimary = Color(0xFFFF9800);   // Orange for streaks and achievements
  static const Color streakLight = Color(0xFFFFB74D);     // Light orange for backgrounds
  static const Color streakDark = Color(0xFFF57C00);      // Dark orange for emphasis
  
  // CEFR level color mapping
  static const Color cefrA1 = Color(0xFFFFD54F);          // Beginner level - light amber
  static const Color cefrA2 = Color(0xFFFFA726);          // Elementary level - amber
  static const Color cefrB1 = Color(0xFF66BB6A);          // Intermediate level - light green
  static const Color cefrB2 = Color(0xFF43A047);          // Upper intermediate - medium green
  static const Color cefrC1 = Color(0xFF42A5F5);          // Advanced level - light blue
  static const Color cefrC2 = Color(0xFF1E88E5);          // Proficiency level - blue
  
  // Return appropriate text color based on background color for accessibility
  static Color getTextOnColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? textPrimary : textPrimaryDark;
  }
  
  // Get appropriate theme based colors
  static Color getSurfaceColor(bool isDarkMode) => isDarkMode ? surfaceDark : surface;
  static Color getBackgroundColor(bool isDarkMode) => isDarkMode ? backgroundDark : background;
  static Color getTextColor(bool isDarkMode) => isDarkMode ? textPrimaryDark : textPrimary;
  static Color getSecondaryTextColor(bool isDarkMode) => isDarkMode ? textSecondaryDark : textSecondary;
  
  // Get appropriate CEFR level color
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
}
