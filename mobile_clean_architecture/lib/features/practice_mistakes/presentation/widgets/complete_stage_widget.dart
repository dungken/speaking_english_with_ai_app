import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class CompleteStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final VoidCallback onNext;

  const CompleteStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);
    final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: sectionSpacing),
        // Success animation
        _buildSuccessAnimation(context),
        SizedBox(height: elementSpacing * 3),
        Text(
          'Great job!',
          style: TextStyles.h2(
            context,
            isDarkMode: isDarkMode,
          ),
        ),
        SizedBox(height: elementSpacing),
        Text(
          'You\'ve practiced the correct way to express this idea. This will help you avoid similar mistakes in the future.',
          textAlign: TextAlign.center,
          style: TextStyles.body(
            context,
            isDarkMode: isDarkMode,
            color: AppColors.getTextSecondaryColor(isDarkMode),
          ),
        ),
        SizedBox(height: sectionSpacing),
        _buildImprovementCard(context),
        SizedBox(height: sectionSpacing),
        // Enhanced button
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward, size: 22),
            label: Text(
              'Continue to Next Practice',
              style: TextStyles.button(
                context,
                isDarkMode: isDarkMode,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAnimation(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success,
                  AppColors.success
                      .withGreen((AppColors.success.green - 40).clamp(0, 255)),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildImprovementCard(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return buildCard(
      context,
      isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Improvement',
            style: TextStyles.h3(
              context,
              isDarkMode: isDarkMode,
            ),
          ),
          SizedBox(height: elementSpacing * 3),
          Container(
            padding: EdgeInsets.all(elementSpacing * 2),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.error.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before:',
                  style: TextStyles.caption(
                    context,
                    isDarkMode: isDarkMode,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: elementSpacing),
                Text(
                  practiceItem.commonMistake,
                  style: TextStyles.body(
                    context,
                    isDarkMode: isDarkMode,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: elementSpacing * 3),
          Container(
            padding: EdgeInsets.all(elementSpacing * 2),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? AppColors.success.withOpacity(0.5)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'After:',
                  style: TextStyles.caption(
                    context,
                    isDarkMode: isDarkMode,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: elementSpacing),
                Text(
                  practiceItem.betterExpression,
                  style: TextStyles.body(
                    context,
                    isDarkMode: isDarkMode,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: elementSpacing * 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accuracy:',
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
              Row(
                children: [
                  Text(
                    '95%',
                    style: TextStyles.body(
                      context,
                      isDarkMode: isDarkMode,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: elementSpacing * 1.5),
                  SizedBox(
                    width: 128,
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.95,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withGreen(
                                    (AppColors.success.green + 20)
                                        .clamp(0, 255),
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
