import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';
import 'app_colors.dart';

/// Centralized text styles for the application
/// Follows the typography scale in the design system
class TextStyles {
  // Primary Headings (22sp, Bold)
  static TextStyle h1(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getTitleTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w700,
      letterSpacing: -0.5,
      color: color ?? AppColors.getTextColor(isDarkMode),
    );
  }

  // Section Headers (18sp, SemiBold)
  static TextStyle h2(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getSectionHeaderSize(context),
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: -0.25,
      color: color ?? AppColors.getTextColor(isDarkMode),
    );
  }

  // Card Titles (16sp, Bold)
  static TextStyle h3(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getCardTitleSize(context),
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.getTextColor(isDarkMode),
    );
  }

  // Body Text (14sp, Regular)
  static TextStyle body(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getBodyTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.getTextColor(isDarkMode),
    );
  }

  // Body Small Text (13sp, Regular)
  static TextStyle bodySmall(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getSecondaryTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.getTextColor(isDarkMode),
    );
  }

  // Secondary Text (12sp, Medium)
  static TextStyle secondary(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getSecondaryTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.getTextSecondaryColor(isDarkMode),
    );
  }

  // Captions (11sp, Medium)
  static TextStyle caption(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 11, // Fixed size as per design system
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.getTextSecondaryColor(isDarkMode),
    );
  }

  // Button text style
  static TextStyle button(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getBodyTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w600,
      letterSpacing: 0.2,
      color: color ?? Colors.white,
    );
  }

  // Link style
  static TextStyle link(BuildContext context,
      {Color? color, bool isDarkMode = false, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: ResponsiveLayout.getBodyTextSize(context),
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.primary,
      decoration: TextDecoration.underline,
    );
  }
}
