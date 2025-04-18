import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A card showing the user's current streak and daily goal progress.
/// This card is designed with micro-interactions and visual hierarchy
/// to highlight the user's progress towards their language learning goals.
/// 
/// Implements responsive design patterns to ensure proper display across
/// different device sizes and orientations.
class StreakGoalCard extends StatelessWidget {
  final bool isDarkMode;

  const StreakGoalCard({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get responsive values based on screen dimensions
    final orientation = MediaQuery.of(context).orientation;
    final screenType = ResponsiveLayout.getScreenType(context);
    final padding = screenType == ScreenType.extraSmall ? 12.0 : 16.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layouts based on orientation and available width
          if (orientation == Orientation.landscape && constraints.maxWidth > 500) {
            return _buildExpandedLayout(context, screenType);
          } else {
            return _buildCompactLayout(context, screenType);
          }
        },
      ),
    );
  }

  /// Standard layout for portrait orientation and smaller screens
  Widget _buildCompactLayout(BuildContext context, ScreenType screenType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStreakSection(screenType),
        _buildGoalSection(screenType),
      ],
    );
  }

  /// Enhanced layout for landscape orientation or wider screens
  /// Adds visual enhancements and more detailed information
  Widget _buildExpandedLayout(BuildContext context, ScreenType screenType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              _buildStreakIcon(screenType),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getSecondaryTextColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '7',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(isDarkMode),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            'days',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextColor(isDarkMode),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep going to reach your 10-day milestone!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getSecondaryTextColor(isDarkMode),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildGoalSection(screenType),
        ),
      ],
    );
  }

  Widget _buildStreakSection(ScreenType screenType) {
    // Adjust sizes based on screen dimensions
    final iconSize = _getIconSize(screenType);
    final fontSize = _getFontSize(screenType);
    final labelSize = _getLabelSize(screenType);
    
    return Row(
      children: [
        _buildStreakIcon(screenType),
        SizedBox(width: screenType == ScreenType.extraSmall ? 10 : 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Streak',
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
                color: AppColors.getSecondaryTextColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '7',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'days',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakIcon(ScreenType screenType) {
    final iconSize = _getIconSize(screenType);
    final containerSize = iconSize * 2.0;
    
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.streakDark.withOpacity(0.2) : AppColors.streakLight.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.streakPrimary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.local_fire_department_rounded,
        color: AppColors.streakPrimary,
        size: iconSize,
      ),
    );
  }

  Widget _buildGoalSection(ScreenType screenType) {
    // Adjust sizes based on screen dimensions
    final progressSize = _getProgressSize(screenType);
    final fontSize = _getFontSize(screenType) * 0.55;
    final labelSize = _getLabelSize(screenType);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                value: 0.75,
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                color: AppColors.accent,
                strokeWidth: screenType == ScreenType.extraSmall ? 4 : 5,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '75%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Today's Goal",
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            color: AppColors.getSecondaryTextColor(isDarkMode),
          ),
        ),
      ],
    );
  }
  
  // Helper methods to calculate responsive sizes
  
  double _getIconSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.extraSmall:
        return 20.0;
      case ScreenType.small:
        return 22.0;
      case ScreenType.medium:
        return 24.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 26.0;
    }
  }
  
  double _getProgressSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.extraSmall:
        return 44.0;
      case ScreenType.small:
        return 48.0;
      case ScreenType.medium:
        return 52.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 56.0;
    }
  }
  
  double _getFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.extraSmall:
        return 20.0;
      case ScreenType.small:
        return 22.0;
      case ScreenType.medium:
        return 24.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 26.0;
    }
  }
  
  double _getLabelSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.extraSmall:
        return 10.0;
      case ScreenType.small:
        return 11.0;
      case ScreenType.medium:
        return 12.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 13.0;
    }
  }
}
