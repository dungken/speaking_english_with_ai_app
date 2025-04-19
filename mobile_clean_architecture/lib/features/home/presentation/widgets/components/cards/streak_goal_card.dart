import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A card showcasing the user's current streak and daily goal progress.
/// 
/// This component implements gamification principles through visual reinforcement
/// and progress tracking to maintain user engagement and motivation. The design
/// emphasizes achievement and creates a clear mental model of progress toward
/// language learning goals.
/// 
/// Key UX considerations:
/// - Clear visual feedback on progress status
/// - Achievement celebration through color and iconography
/// - Adaptive layout that prioritizes key metrics
/// - Contextual motivational messaging
/// - Responsive sizing for different device formats
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
    final padding = screenType == ScreenType.extraSmall ? 14.0 : 18.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppColors.streakDark.withOpacity(0.2),
                  AppColors.streakDark.withOpacity(0.1),
                ]
              : [
                  AppColors.streakLight.withOpacity(0.2),
                  AppColors.streakLight.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? AppColors.streakPrimary.withOpacity(0.2)
              : AppColors.streakPrimary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakPrimary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
  /// Uses a compact, information-dense layout to maximize limited screen real estate
  Widget _buildCompactLayout(BuildContext context, ScreenType screenType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStreakSection(screenType),
        _buildVerticalDivider(),
        _buildGoalSection(screenType),
      ],
    );
  }

  /// Enhanced layout for landscape orientation or wider screens
  /// Leverages additional horizontal space to provide more detailed metrics and context
  Widget _buildExpandedLayout(BuildContext context, ScreenType screenType) {
    // Mock data for milestone display
    final milestoneProgress = 7; // Current streak
    final nextMilestone = 10; // Next streak milestone
    final progress = milestoneProgress / nextMilestone; // Progress percentage
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 4,
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
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$milestoneProgress',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.streakPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getTextColor(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Milestone progress bar
                    Stack(
                      children: [
                        // Background track
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        
                        // Progress indicator
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.streakPrimary,
                                  AppColors.streakLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.streakPrimary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    Text(
                      '${nextMilestone - milestoneProgress} more days to reach your $nextMilestone-day milestone!',
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
        
        _buildVerticalDivider(),
        
        Expanded(
          flex: 3,
          child: _buildGoalSection(screenType),
        ),
      ],
    );
  }

  /// Builds the streak counter section with visual emphasis
  Widget _buildStreakSection(ScreenType screenType) {
    // Adjust sizes based on screen dimensions for visual consistency
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
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '7',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.streakPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'days',
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getTextColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Creates a visually engaging streak icon with layered effects
  Widget _buildStreakIcon(ScreenType screenType) {
    final iconSize = _getIconSize(screenType);
    final containerSize = iconSize * 2.0;
    
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.streakPrimary.withOpacity(0.2),
            AppColors.streakPrimary.withOpacity(0.1),
          ],
          radius: 0.85,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.streakPrimary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: containerSize * 0.85,
            height: containerSize * 0.85,
            decoration: BoxDecoration(
              color: AppColors.streakPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          
          // Icon with shadow
          Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.streakPrimary,
            size: iconSize,
            shadows: [
              Shadow(
                color: AppColors.streakPrimary.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the goal progress section with circular indicator
  Widget _buildGoalSection(ScreenType screenType) {
    // Adjust sizes based on screen dimensions for proper proportions
    final progressSize = _getProgressSize(screenType);
    final fontSize = _getFontSize(screenType) * 0.55;
    final labelSize = _getLabelSize(screenType);
    
    // Mock data for today's goal
    const double goalProgress = 0.75; // 75% complete
    const int minutesCompleted = 15;
    const int totalMinutes = 20;
    const int remainingMinutes = totalMinutes - minutesCompleted;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Track for progress indicator
            Container(
              width: progressSize,
              height: progressSize,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
            ),
            
            // Progress indicator
            SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                value: goalProgress,
                backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                strokeWidth: screenType == ScreenType.extraSmall ? 4 : 5,
                strokeCap: StrokeCap.round,
              ),
            ),
            
            // Layered content display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(goalProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  '$minutesCompleted/$totalMinutes min',
                  style: TextStyle(
                    fontSize: labelSize - 1,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getSecondaryTextColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Goal label with action emphasis
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Today's Goal",
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
                color: AppColors.getSecondaryTextColor(isDarkMode),
              ),
            ),
            
            if (remainingMinutes > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$remainingMinutes min left',
                  style: TextStyle(
                    fontSize: labelSize - 2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  /// Creates a subtle visual separator for content sections
  Widget _buildVerticalDivider() {
    return Container(
      height: 45,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }
  
  // Helper methods to calculate responsive sizes based on screen type
  
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
        return 46.0;
      case ScreenType.small:
        return 50.0;
      case ScreenType.medium:
        return 54.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 58.0;
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
        return 11.0;
      case ScreenType.small:
        return 12.0;
      case ScreenType.medium:
        return 13.0;
      case ScreenType.large:
      case ScreenType.tablet:
        return 14.0;
    }
  }
}
