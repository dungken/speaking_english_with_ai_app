import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class RecordingStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final String recordingState; // 'ready', 'recording', 'recorded'
  final VoidCallback onRecordTap;
  final VoidCallback onRecordAgain;
  final VoidCallback onShowFeedback;

  const RecordingStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.recordingState,
    required this.onRecordTap,
    required this.onRecordAgain,
    required this.onShowFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);
    final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCard(
          context,
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Express This Idea',
                style: TextStyles.h3(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(height: elementSpacing * 2),
              Container(
                padding: EdgeInsets.all(elementSpacing * 3),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.primaryDark.withOpacity(0.2)
                      : AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                ),
                child: Text(
                  practiceItem.situationPrompt,
                  style: TextStyles.body(
                    context,
                    isDarkMode: isDarkMode,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sectionSpacing * 0.75),
        buildCard(
          context,
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Response',
                style: TextStyles.h3(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(height: elementSpacing * 2),
              if (recordingState == 'recording')
                _buildRecordingInProgress(context)
              else
                _buildRecordingCompleted(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInProgress(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return Column(
      children: [
        // Animated recording indicator
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 48 * value,
                  height: 48 * value,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
          onEnd: () {},
        ),
        SizedBox(height: elementSpacing * 2),
        // Animated recording text
        DefaultTextStyle(
          style: TextStyles.body(
            context,
            isDarkMode: isDarkMode,
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Recording'),
              SizedBox(width: 2),
              _buildDot(),
              SizedBox(width: 2),
              _buildDot(delay: 150),
              SizedBox(width: 2),
              _buildDot(delay: 300),
            ],
          ),
        ),
        SizedBox(height: elementSpacing),
        Text(
          'Tap to stop',
          style: TextStyles.caption(
            context,
            isDarkMode: isDarkMode,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        SizedBox(height: elementSpacing * 4),
        // Enhanced stop button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(56),
            onTap: onRecordTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error,
                    AppColors.error
                        .withRed((AppColors.error.red - 40).clamp(0, 255))
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.stop_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Animated recording dot
  Widget _buildDot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value <= 0.5 ? value * 2 : (1 - value) * 2,
          child: const Text('.'),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildRecordingCompleted(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return Column(
      children: [
        buildAudioProgressBar(
          context: context,
          isDarkMode: isDarkMode,
          progress: 0.75,
          duration: '0:04',
        ),
        SizedBox(height: elementSpacing * 3),
        Container(
          padding: EdgeInsets.all(elementSpacing * 2),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.surfaceDark.withOpacity(0.6)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.surfaceDark
                  : AppColors.getBackgroundColor(false).withOpacity(0.8),
            ),
          ),
          child: Text(
            practiceItem.commonMistake,
            style: TextStyles.body(
              context,
              isDarkMode: isDarkMode,
              color: AppColors.getTextColor(isDarkMode),
            ),
          ),
        ),
        SizedBox(height: elementSpacing * 3),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRecordAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Record Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getSurfaceColor(isDarkMode),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  side: BorderSide(
                    color: isDarkMode
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                ),
              ),
            ),
            SizedBox(width: elementSpacing * 2),
            Expanded(
              child: ElevatedButton(
                onPressed: onShowFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('See Feedback'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
