import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class PracticeStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final String recordingState; // 'ready', 'recording', 'recorded'
  final VoidCallback onRecordTap;
  final VoidCallback onRecordAgain;
  final VoidCallback onComplete;

  const PracticeStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.recordingState,
    required this.onRecordTap,
    required this.onRecordAgain,
    required this.onComplete,
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
                'Practice the Correct Version',
                style: TextStyles.h3(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              Container(
                padding: EdgeInsets.all(elementSpacing * 2),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practiceItem.betterExpression,
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.green[100] : Colors.green[800],
                      ),
                    ),
                    SizedBox(height: elementSpacing * 1.5),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, size: 12),
                      label: const Text('Listen'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.green[300] : Colors.green[700],
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              Text(
                'Alternative Expressions:',
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: elementSpacing * 1.5),
              ..._buildAlternatives(context),
              Divider(height: elementSpacing * 5),
              Center(
                child: Text(
                  'Your Practice',
                  style: TextStyles.h3(
                    context,
                    isDarkMode: isDarkMode,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              _buildRecordingSection(context),
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
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: elementSpacing * 1.5),
                  Text(
                    'Why This Matters',
                    style: TextStyles.h3(
                      context,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              SizedBox(height: elementSpacing * 2),
              Text(
                'Using the correct tense helps your listener understand exactly when events happened. For past events, using past tense forms like "couldn\'t" and "was" is essential for clarity.',
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAlternatives(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return List.generate(
      practiceItem.alternatives.length,
      (index) => Padding(
        padding: EdgeInsets.only(bottom: elementSpacing * 1.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.primaryDark.withOpacity(0.3)
                    : AppColors.primaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: elementSpacing * 1.5),
            Expanded(
              child: Text(
                practiceItem.alternatives[index],
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    if (recordingState == 'recording') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated recording indicator
          Center(
            child: TweenAnimationBuilder<double>(
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
          Center(
            child: Material(
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
          ),
        ],
      );
    } else if (recordingState == 'recorded') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: elementSpacing * 2),
              child: buildAudioProgressBar(
                context: context,
                isDarkMode: isDarkMode,
                progress: 0.75,
                duration: '0:05',
              ),
            ),
          ),
          SizedBox(height: elementSpacing * 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  child: ElevatedButton.icon(
                    onPressed: onRecordAgain,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(
                      'Try Again',
                      style: TextStyles.button(
                        context,
                        isDarkMode: isDarkMode,
                        color: AppColors.primary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getSurfaceColor(isDarkMode),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: elementSpacing * 2),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Complete',
                      style: TextStyles.button(
                        context,
                        isDarkMode: isDarkMode,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: elementSpacing * 2),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: elementSpacing * 2),
              child: Text(
                'Your practice sounds good! The pronunciation and grammar are correct.',
                textAlign: TextAlign.center,
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Ready state
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap to record your practice',
            textAlign: TextAlign.center,
            style: TextStyles.body(
              context,
              isDarkMode: isDarkMode,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          SizedBox(height: elementSpacing * 3),
          Center(
            child: buildRecordButton(
              context: context,
              isDarkMode: isDarkMode,
              onTap: onRecordTap,
            ),
          ),
        ],
      );
    }
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
}
