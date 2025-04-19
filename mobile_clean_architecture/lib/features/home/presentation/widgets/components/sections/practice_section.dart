import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';
import '../cards/activity_card.dart';

/// Practice section containing a grid of activity cards.
/// This component organizes the main practice activities available to the user
/// with a focus on content hierarchy, visual engagement, and information clarity.
/// 
/// Key UX considerations:
/// - Responsive grid layout that adapts to different screen sizes
/// - Dynamic spacing and sizing that prevents overflow
/// - Clear visual differentiation between activity types
/// - Accessible touch targets with proper spacing
/// - Content prioritization based on user learning needs
class PracticeSection extends StatelessWidget {
  final bool isDarkMode;

  const PracticeSection({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the best grid layout based on screen size and orientation
    final orientation = MediaQuery.of(context).orientation;
    final screenType = ResponsiveLayout.getScreenType(context);
    
    // Use screen type to determine the appropriate grid configuration
    final gridColumns = orientation == Orientation.portrait
        ? ResponsiveLayout.getGridColumns(context, defaultColumns: 2)
        : ResponsiveLayout.getGridColumns(context, defaultColumns: 3);
    
    // Calculate spacing and aspect ratio based on screen size for optimal content density
    final spacing = ResponsiveLayout.getSpacing(context);
    final aspectRatio = ResponsiveLayout.getGridAspectRatio(context);
    
    return Column(
      children: [
        // Daily practice reminder with personalized content
        _buildPracticeMessage(screenType),
        SizedBox(height: spacing),
        
        // Responsive activity grid with flexible layout
        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust aspect ratio based on available width for visual balance
            final calculatedAspectRatio = _calculateAspectRatio(
              constraints.maxWidth, 
              gridColumns, 
              spacing,
              defaultRatio: aspectRatio,
            );
            
            // Activity grid with adaptive layout
            return GridView.count(
              crossAxisCount: gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: calculatedAspectRatio,
              children: [
                // Role Play activity card - primary conversation practice
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: isDarkMode
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  iconBgColor: isDarkMode
                      ? AppColors.primaryDark.withOpacity(0.2)
                      : AppColors.primaryLight.withOpacity(0.2),
                  title: 'Role Play',
                  subtitle: 'Practice conversations in real-life scenarios',
                  footer: '12 scenarios available',
                  footerIcon: Icons.star_rounded,
                  footerHighlight: true,
                  onTap: () => context.push('/create-conversation'),
                ),
                
                // Image Description activity card - visual communication practice
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.image_rounded,
                  iconColor: isDarkMode
                      ? const Color(0xFFB794F4) // Light purple
                      : const Color(0xFF6B46C1), // Dark purple
                  iconBgColor: isDarkMode
                      ? const Color(0xFF44337A).withOpacity(0.2) // Very dark purple with opacity
                      : const Color(0xFFE9D8FD).withOpacity(0.6), // Very light purple with opacity
                  title: 'Describe Images',
                  subtitle: 'Practice describing what you see',
                  footer: '20 new images added',
                  footerIcon: Icons.new_releases_rounded,
                  footerHighlight: true,
                  onTap: () => context.push('/image-description'),
                ),
                
                // Mistake Practice activity card - personalized error correction
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.warning_amber_rounded,
                  iconColor: isDarkMode
                      ? AppColors.warning.withOpacity(0.9)
                      : AppColors.warning,
                  iconBgColor: isDarkMode
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.1),
                  title: 'Fix Mistakes',
                  subtitle: 'Practice with your common errors',
                  footer: '15 personalized exercises',
                  footerIcon: Icons.priority_high_rounded,
                  footerHighlight: true,
                  onTap: () => context.push('/practice-mistakes'),
                ),
                
                // Pronunciation activity card - speaking clarity practice
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.record_voice_over_rounded,
                  iconColor: isDarkMode
                      ? AppColors.accentLight
                      : AppColors.accent,
                  iconBgColor: isDarkMode
                      ? AppColors.accentDark.withOpacity(0.2)
                      : AppColors.accentLight.withOpacity(0.2),
                  title: 'Pronunciation',
                  subtitle: 'Focus on challenging sounds',
                  footer: '8 exercises for you',
                  onTap: () => context.push('/pronunciation'),
                ),
                
                // Vocabulary activity card - word mastery practice
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.menu_book_rounded,
                  iconColor: isDarkMode
                      ? const Color(0xFF9AE6B4) // Light green
                      : const Color(0xFF38A169), // Dark green
                  iconBgColor: isDarkMode
                      ? const Color(0xFF276749).withOpacity(0.2) // Very dark green with opacity
                      : const Color(0xFFC6F6D5).withOpacity(0.6), // Very light green with opacity
                  title: 'Vocabulary',
                  subtitle: 'Learn and practice new words',
                  footer: '200+ words in your level',
                  onTap: () => context.push('/vocabulary'),
                ),
                
                // Grammar activity card - sentence structure practice
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.text_fields_rounded,
                  iconColor: isDarkMode
                      ? const Color(0xFFB4A9F5) // Light indigo
                      : const Color(0xFF5A4FB7), // Dark indigo
                  iconBgColor: isDarkMode
                      ? const Color(0xFF44337A).withOpacity(0.2) // Very dark indigo with opacity
                      : const Color(0xFFE9D8FD).withOpacity(0.4), // Very light indigo with opacity
                  title: 'Grammar',
                  subtitle: 'Practice correct sentence structures',
                  footer: '10 grammar rules to master',
                  onTap: () => context.push('/grammar'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
  
  /// Build an attention-grabbing practice message with personalized content
  /// that encourages daily activity based on user data.
  /// 
  /// Uses contextual visual cues and clear call-to-action messaging.
  Widget _buildPracticeMessage(ScreenType screenType) {
    // Adapt text sizes and padding based on screen dimensions
    final titleSize = screenType == ScreenType.extraSmall ? 14.0 : 15.0;
    final messageSize = screenType == ScreenType.extraSmall ? 13.0 : 14.0;
    final containerPadding = screenType == ScreenType.extraSmall 
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    
    return Container(
      padding: containerPadding,
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.accent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Visual icon with container for emphasis
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_rounded,
                size: 20,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            
            // Message content with clear structure
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily practice reminder',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      fontSize: titleSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Just 20 minutes of focused practice today will help you maintain your streak!',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.getTextColor(isDarkMode)
                          : AppColors.getTextColor(isDarkMode).withOpacity(0.9),
                      fontSize: messageSize,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Calculate optimal aspect ratio based on available width
  /// to ensure visual harmony and prevent overflow issues.
  /// 
  /// Implements a responsive algorithm that adapts card proportions
  /// based on available space and device characteristics.
  double _calculateAspectRatio(
    double availableWidth,
    int columns,
    double spacing, {
    double defaultRatio = 0.85,
    double minRatio = 0.7,
    double maxRatio = 1.2,
  }) {
    // Calculate card width accounting for spacing between items
    final totalSpacing = spacing * (columns - 1);
    final cardWidth = (availableWidth - totalSpacing) / columns;
    
    // Smaller cards should be taller relative to width (smaller ratio)
    // This ensures readable text and proper touch targets on small screens
    if (cardWidth < 120) {
      return minRatio;
    } 
    // Larger cards can be more square-like (larger ratio)
    // This creates better visual balance on larger screens
    else if (cardWidth > 180) {
      return maxRatio;
    }
    // Default for medium-sized cards
    else {
      return defaultRatio;
    }
  }
}
