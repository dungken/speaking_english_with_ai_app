import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A dismissible coaching tip card that displays personalized language learning advice.
/// Uses a distinctive visual design to draw attention to important tips while
/// maintaining effective information hierarchy and readable content.
/// 
/// Implements adaptive layouts for different screen sizes and orientations,
/// ensuring optimal readability and touch target accessibility.
class CoachingTipCard extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onDismiss;

  const CoachingTipCard({
    Key? key,
    required this.isDarkMode,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get responsive values based on screen dimensions
    final orientation = MediaQuery.of(context).orientation;
    final screenType = ResponsiveLayout.getScreenType(context);
    
    // Adjust padding based on screen size
    final horizontalPadding = screenType == ScreenType.extraSmall ? 14.0 : 16.0;
    final verticalPadding = screenType == ScreenType.extraSmall ? 14.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.info.withOpacity(0.15) 
            : AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode 
              ? AppColors.info.withOpacity(0.3) 
              : AppColors.info.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layouts based on orientation and available width
          if (orientation == Orientation.landscape && constraints.maxWidth > 500) {
            return _buildLandscapeLayout(context, screenType);
          } else {
            return _buildPortraitLayout(context, screenType);
          }
        },
      ),
    );
  }

  /// Standard layout for portrait orientation and smaller screens
  Widget _buildPortraitLayout(BuildContext context, ScreenType screenType) {
    return Stack(
      children: [
        // Close button
        Positioned(
          right: 0,
          top: 0,
          child: _buildCloseButton(),
        ),
        
        // Content with icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            _buildIconContainer(screenType),
            
            SizedBox(width: screenType == ScreenType.extraSmall ? 12 : 14),
            
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20), // Space for close button
                child: _buildTipContent(screenType),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Enhanced layout for landscape orientation or wider screens
  Widget _buildLandscapeLayout(BuildContext context, ScreenType screenType) {
    return Stack(
      children: [
        // Close button
        Positioned(
          right: 0,
          top: 0,
          child: _buildCloseButton(),
        ),
        
        // Two-column layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: icon with background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppColors.info.withOpacity(0.1) 
                    : AppColors.info.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _buildIconContainer(screenType),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Right column: content with heading
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 24), // Space for close button
                child: _buildTipContent(screenType),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      icon: Icon(
        Icons.close_rounded,
        size: 18,
        color: isDarkMode ? AppColors.info.withOpacity(0.8) : AppColors.info,
      ),
      tooltip: 'Dismiss tip',
      onPressed: onDismiss,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }

  Widget _buildIconContainer(ScreenType screenType) {
    // Adjust icon size based on screen dimensions
    final containerSize = screenType == ScreenType.extraSmall ? 36.0 : 42.0;
    final iconSize = containerSize * 0.45;
    
    return Container(
      padding: EdgeInsets.all(containerSize * 0.25),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.info.withOpacity(0.2) 
            : AppColors.info.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.tips_and_updates_rounded,
        size: iconSize,
        color: AppColors.info,
      ),
    );
  }

  Widget _buildTipContent(ScreenType screenType) {
    // Adjust text sizes based on screen dimensions
    final titleSize = screenType == ScreenType.extraSmall ? 14.0 : 15.0;
    final contentSize = screenType == ScreenType.extraSmall ? 13.0 : 14.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language Coach Tip',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
            color: AppColors.info,
          ),
        ),
        SizedBox(height: screenType == ScreenType.extraSmall ? 4 : 6),
        Text(
          'I noticed you often mix up past tense verbs. Try practicing the "Express & Improve" exercises below to fix this pattern.',
          style: TextStyle(
            fontSize: contentSize,
            height: 1.4,
            color: isDarkMode 
                ? AppColors.getTextColor(isDarkMode) 
                : AppColors.getTextColor(isDarkMode).withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
