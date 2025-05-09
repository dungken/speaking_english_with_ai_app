import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../providers/practice_mistakes_provider.dart';
import '../widgets/prompt_stage_widget.dart';
import '../widgets/recording_stage_widget.dart';
import '../widgets/feedback_stage_widget.dart';
import '../widgets/practice_stage_widget.dart';
import '../widgets/complete_stage_widget.dart';

/// Screen for practicing common language mistakes
/// Provides a multi-stage interactive experience for users to improve their expression
class PracticeMistakesScreen extends StatelessWidget {
  const PracticeMistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PracticeMistakesProvider(),
      child: const _PracticeMistakesScreenContent(),
    );
  }
}

class _PracticeMistakesScreenContent extends StatefulWidget {
  const _PracticeMistakesScreenContent();

  @override
  State<_PracticeMistakesScreenContent> createState() =>
      _PracticeMistakesScreenContentState();
}

class _PracticeMistakesScreenContentState
    extends State<_PracticeMistakesScreenContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for page transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PracticeMistakesProvider>(context);
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDarkMode),
      appBar: _buildAppBar(context, isDarkMode, provider),
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.05),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    EdgeInsets.all(ResponsiveLayout.getSectionSpacing(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(context, isDarkMode, provider),
                    SizedBox(
                        height:
                            ResponsiveLayout.getElementSpacing(context) * 2),
                    // Stage content
                    _buildContent(context, isDarkMode, provider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the app bar with title and a consistent visual style
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode,
      PracticeMistakesProvider provider) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getPrimaryGradient(isDarkMode),
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.psychology_outlined,
            color: Colors.white.withOpacity(0.9),
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Improve Your Expression',
              style: TextStyles.h2(
                context,
                isDarkMode: isDarkMode,
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  '${provider.currentItemIndex + 1}/${provider.totalItems}',
                  style: TextStyles.caption(
                    context,
                    isDarkMode: isDarkMode,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a visual progress indicator for the practice session
  Widget _buildProgressIndicator(BuildContext context, bool isDarkMode,
      PracticeMistakesProvider provider) {
    final progress = (provider.currentItemIndex) /
        (provider.totalItems > 0 ? provider.totalItems : 1);
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Practice Progress',
              style: TextStyles.body(
                context,
                isDarkMode: isDarkMode,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyles.body(
                context,
                isDarkMode: isDarkMode,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: elementSpacing),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the appropriate content based on the current stage
  Widget _buildContent(BuildContext context, bool isDarkMode,
      PracticeMistakesProvider provider) {
    switch (provider.currentStage) {
      case PracticeStage.prompt:
        return PromptStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onRecordTap: provider.handleRecord,
        );
      case PracticeStage.recording:
        return RecordingStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          recordingState: provider.recordingStateString,
          onRecordTap: provider.handleRecord,
          onRecordAgain: provider.resetRecording,
          onShowFeedback: provider.showFeedback,
        );
      case PracticeStage.feedback:
        return FeedbackStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onPracticeCorrect: provider.practiceCorrect,
        );
      case PracticeStage.practice:
        return PracticeStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          recordingState: provider.recordingStateString,
          onRecordTap: provider.handleRecord,
          onRecordAgain: provider.resetRecording,
          onComplete: provider.complete,
        );
      case PracticeStage.complete:
        return CompleteStageWidget(
          practiceItem: provider.currentItem,
          isDarkMode: isDarkMode,
          onNext: provider.next,
        );
    }
  }
}
