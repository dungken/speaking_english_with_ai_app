import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A comprehensive progress section displaying the user's language learning metrics
/// including CEFR levels, mistake tracking, vocabulary growth, and practice time.
///
/// Implements responsive layouts that adapt to different screen sizes and orientations,
/// ensuring optimal data visualization and information hierarchy.
class ProgressSection extends StatelessWidget {
  final bool isDarkMode;

  const ProgressSection({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get responsive spacing values based on screen size
    final spacing = ResponsiveLayout.getSpacing(context);
    final orientation = MediaQuery.of(context).orientation;

    return Container(
      padding: EdgeInsets.all(spacing * 1.25),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: spacing),

          // CEFR level card
          _buildCefrLevelCard(context),
          SizedBox(height: spacing),

          // Stats section
          orientation == Orientation.landscape
              ? _buildLandscapeStats(spacing)
              : _buildPortraitStats(spacing),

          SizedBox(height: spacing),

          // Common mistakes tracker
          _buildMistakesTracker(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    final spacing = ResponsiveLayout.getSpacing(context);
    final fontSize = screenType == ScreenType.extraSmall ? 15.0 : 16.0;
    final buttonTextSize = screenType == ScreenType.extraSmall ? 13.0 : 14.0;
    final iconSize = screenType == ScreenType.extraSmall ? 16.0 : 18.0;

    return Container(
      constraints: const BoxConstraints(
          minHeight: 48), // Following touch target guidelines
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: iconSize,
                  color: AppColors.primary,
                ),
                SizedBox(
                    width:
                        spacing * 0.5), // Element spacing as per design system
                Flexible(
                  child: Text(
                    'Learning Insights',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                      color: AppColors.getTextColor(isDarkMode),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              width: spacing * 0.5), // Element spacing as per design system
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 44, // Minimum touch target size
              minHeight: 44,
            ),
            child: TextButton.icon(
              onPressed: () => context.push('/progress'),
              icon: Icon(
                Icons.analytics_rounded,
                size: iconSize - 2,
                color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
              ),
              label: Text(
                'Detailed Analysis',
                style: TextStyle(
                  fontSize: buttonTextSize,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? AppColors.primaryLight : AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      spacing * 0.5, // Element spacing as per design system
                  vertical: 0,
                ),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CEFR language proficiency level card with visual indicator
  Widget _buildCefrLevelCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cefrLevel = 'B1'; // Mock data - would come from user profile
    final cefrColor = AppColors.getCefrLevelColor(cefrLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cefrColor.withOpacity(0.15),
            cefrColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cefrColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cefrColor.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cefrColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                cefrLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your CEFR Level',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.getTextColor(isDarkMode),
                      ),
                    ),
                    screenWidth > 350
                        ? _buildCefrProgress(cefrLevel)
                        : const SizedBox(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Intermediate level - Can understand main points of clear standard input on familiar matters.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getSecondaryTextColor(isDarkMode),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                screenWidth <= 350
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildCefrProgress(cefrLevel),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CEFR progress indicator showing advancement toward next level
  Widget _buildCefrProgress(String currentLevel) {
    // Progress to next level (mock data)
    const double progress = 0.65;
    final nextLevel = _getNextCefrLevel(currentLevel);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 55,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.getCefrLevelColor(nextLevel),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        AppColors.getCefrLevelColor(nextLevel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    nextLevel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getCefrLevelColor(nextLevel),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Landscape-oriented stats layout with side-by-side metrics
  Widget _buildLandscapeStats(double spacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeStat(),
              SizedBox(height: spacing * 0.8),
              _buildVocabStat(),
            ],
          ),
        ),

        SizedBox(width: spacing),

        // Right column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConversationStat(),
              SizedBox(height: spacing * 0.8),
              _buildMistakesStat(),
            ],
          ),
        ),
      ],
    );
  }

  /// Portrait-oriented stats layout with stacked metrics
  Widget _buildPortraitStats(double spacing) {
    return Column(
      children: [
        _buildTimeStat(),
        SizedBox(height: spacing * 0.8),
        _buildVocabStat(),
        SizedBox(height: spacing * 0.8),
        _buildConversationStat(),
        SizedBox(height: spacing * 0.8),
        _buildMistakesStat(),
      ],
    );
  }

  /// Learning time statistics with visualization
  Widget _buildTimeStat() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.timer_outlined,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Time',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  Text(
                    '42 hours total',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+2.5h this week',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Vocabulary acquisition statistics
  Widget _buildVocabStat() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF6B46C1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.book_outlined,
            size: 20,
            color: Color(0xFF6B46C1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vocabulary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  Text(
                    '780 words mastered',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF6B46C1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+24 new',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Conversation practice statistics
  Widget _buildConversationStat() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chat_outlined,
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
                'Conversations',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  Text(
                    '17 completed',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '3 this week',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mistakes tracking statistics
  Widget _buildMistakesStat() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.warning_amber_outlined,
            size: 20,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mistakes Fixed',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.getTextColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  Text(
                    '32 of 45 corrected',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '71%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Common mistakes tracker with visualization of progress
  Widget _buildMistakesTracker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Common Mistakes to Fix',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.getTextColor(isDarkMode),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/practice-mistakes'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                'Practice Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Mistake item 1
        _buildMistakeItem(
          category: 'Past Tense Verb Forms',
          examples: ['I go yesterday', 'She eat dinner last night'],
          progress: 0.6,
          color: AppColors.warning,
        ),
        const SizedBox(height: 10),

        // Mistake item 2
        _buildMistakeItem(
          category: 'Article Usage',
          examples: ['I bought car', 'She is doctor'],
          progress: 0.3,
          color: AppColors.error,
        ),
        const SizedBox(height: 10),

        // Mistake item 3
        _buildMistakeItem(
          category: 'Preposition Usage',
          examples: [
            'I arrived to home',
            'I\'m good in math'
          ], // Added comma here
          progress: 0.8,
          color: AppColors.success,
        ),
      ],
    );
  }

  /// Individual mistake item with progress indicator
  Widget _buildMistakeItem({
    required String category,
    required List<String> examples,
    required double progress,
    required Color color,
  }) {
    final combinedExamples = examples.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.getTextColor(isDarkMode),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'Examples: $combinedExamples',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(isDarkMode)
                      .withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor:
                isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Helper method to determine the next CEFR level
  String _getNextCefrLevel(String currentLevel) {
    switch (currentLevel) {
      case 'A1':
        return 'A2';
      case 'A2':
        return 'B1';
      case 'B1':
        return 'B2';
      case 'B2':
        return 'C1';
      case 'C1':
        return 'C2';
      case 'C2':
        return 'C2+'; // Mastery beyond C2
      default:
        return 'A2'; // Default next level
    }
  }
}
