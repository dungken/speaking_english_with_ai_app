import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';
import '../cards/activity_card.dart';

/// Practice section containing a grid of activity cards.
/// This component organizes the main practice activities available to the user.
/// 
/// Implements a responsive grid layout that adapts to different screen sizes
/// and orientations to prevent overflow issues.
class PracticeSection extends StatelessWidget {
  final bool isDarkMode;

  const PracticeSection({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the best grid layout based on screen size
    final orientation = MediaQuery.of(context).orientation;
    final gridColumns = orientation == Orientation.portrait
        ? ResponsiveLayout.getGridColumns(context, defaultColumns: 2)
        : ResponsiveLayout.getGridColumns(context, defaultColumns: 4);
    
    // Calculate spacing and aspect ratio based on screen size
    final spacing = ResponsiveLayout.getSpacing(context);
    final aspectRatio = ResponsiveLayout.getGridAspectRatio(context);
    
    return Column(
      children: [
        _buildPracticeMessage(),
        SizedBox(height: spacing),
        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust aspect ratio based on available width
            final calculatedAspectRatio = _calculateAspectRatio(
              constraints.maxWidth, 
              gridColumns, 
              spacing,
              defaultRatio: aspectRatio,
            );
            
            return GridView.count(
              crossAxisCount: gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: calculatedAspectRatio,
              children: [
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
                  onTap: () => context.push('/create-conversation'),
                ),
                ActivityCard(
                  isDarkMode: isDarkMode,
                  icon: Icons.image_rounded,
                  iconColor: isDarkMode
                      ? Color(0xFFB794F4) // Light purple
                      : Color(0xFF6B46C1), // Dark purple
                  iconBgColor: isDarkMode
                      ? Color(0xFF44337A).withOpacity(0.2) // Very dark purple with opacity
                      : Color(0xFFE9D8FD).withOpacity(0.6), // Very light purple with opacity
                  title: 'Describe Images',
                  subtitle: 'Practice describing what you see',
                  footer: '20 new images added',
                  onTap: () => context.push('/image-description'),
                ),
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
                  onTap: () => context.push('/practice-mistakes'),
                ),
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
              ],
            );
          },
        ),
      ],
    );
  }
  
  /// Build an attention-grabbing practice message that encourages daily activity
  Widget _buildPracticeMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.accent.withOpacity(0.15)
            : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily practice reminder',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Just 20 minutes of focused practice today will help you maintain your streak!',
                  style: TextStyle(
                    color: isDarkMode
                        ? AppColors.getTextColor(isDarkMode)
                        : AppColors.getTextColor(isDarkMode).withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Calculate optimal aspect ratio based on available width
  double _calculateAspectRatio(
    double availableWidth,
    int columns,
    double spacing, {
    double defaultRatio = 0.85,
    double minRatio = 0.7,
    double maxRatio = 1.2,
  }) {
    // Calculate card width accounting for spacing
    final totalSpacing = spacing * (columns - 1);
    final cardWidth = (availableWidth - totalSpacing) / columns;
    
    // Smaller cards should be taller relative to width (smaller ratio)
    if (cardWidth < 120) {
      return minRatio;
    } 
    // Larger cards can be more square-like (larger ratio)
    else if (cardWidth > 180) {
      return maxRatio;
    }
    // Default for medium-sized cards
    else {
      return defaultRatio;
    }
  }
}
