import 'package:flutter/material.dart';

class ResponsiveLayout {
  static double getTitleTextSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base size is 22
    if (width < 320) return 19; // 0.85x scale for small screens
    if (width > 600) return 24; // 1.1x scale for large screens
    return 22; // Default/base size
  }

  static double getSectionHeaderSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base size is 18
    if (width < 320) return 16; // 0.85x scale for small screens
    if (width > 600) return 20; // 1.1x scale for large screens
    return 18; // Default/base size
  }

  static double getCardTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base size is 16
    if (width < 320) return 14; // 0.85x scale for small screens
    if (width > 600) return 17; // 1.05x scale for large screens
    return 16; // Default/base size
  }

  static double getBodyTextSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base size is 14
    if (width < 320) return 13; // 0.9x scale for small screens
    if (width > 600) return 15; // 1.05x scale for large screens
    return 14; // Default/base size
  }

  static double getSecondaryTextSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base size is 12
    if (width < 320) return 11; // 0.9x scale for small screens
    if (width > 600) return 12; // 1.0x scale for large screens (no scaling)
    return 12; // Default/base size
  }

  static double getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base spacing is 24
    if (width < 320) return 20; // Reduced spacing for small screens
    if (width > 600) return 28; // Expanded spacing for large screens
    return 24; // Default/base spacing
  }

  static double getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Base padding is 16
    if (width < 320) return 12; // Reduced padding for small screens
    if (width > 600) return 20; // Expanded padding for large screens
    return 16; // Default/base padding
  }

  static double getElementSpacing(BuildContext context) {
    final cardPadding = getCardPadding(context);
    // Element spacing is 50-75% of component padding
    return cardPadding * 0.5;
  }

  // Text scaling with constraints
  static double scaleText(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    double factor = 1.0;
    
    if (width < 320) factor = 0.9;
    else if (width > 600) factor = 1.05;
    
    return baseSize * factor;
  }

  // Check if device is in landscape orientation and large enough for dual-pane
  static bool isLargeScreen(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return orientation == Orientation.landscape && screenWidth > 600;
  }

  // Get screen density mode
  static String getScreenDensityMode(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 320) return 'compact';
    if (width > 414) return 'enhanced';
    return 'standard';
  }
}
