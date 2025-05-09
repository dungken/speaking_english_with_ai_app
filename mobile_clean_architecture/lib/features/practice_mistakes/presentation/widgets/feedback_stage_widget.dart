import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class FeedbackStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final VoidCallback onPracticeCorrect;

  const FeedbackStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.onPracticeCorrect,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Response',
                    style: TextStyles.h3(
                      context,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Play'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      padding: EdgeInsets.symmetric(
                        horizontal: elementSpacing * 1.5,
                        vertical: elementSpacing * 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.accent.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: elementSpacing * 2),
              Container(
                padding: EdgeInsets.all(elementSpacing * 2),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(isDarkMode).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
                child: _buildHighlightedText(context),
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
                'Improvement Suggestions',
                style: TextStyles.h3(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              ..._buildMistakeDetails(context),
              SizedBox(height: elementSpacing * 3),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.success,
                  ),
                  SizedBox(width: elementSpacing * 1.5),
                  Text(
                    'Better way to express this:',
                    style: TextStyles.body(
                      context,
                      isDarkMode: isDarkMode,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: elementSpacing * 2),
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
                      practiceItem.betterExpression,
                      style: TextStyles.body(
                        context,
                        isDarkMode: isDarkMode,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: elementSpacing * 1.5),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, size: 14),
                      label: const Text('Listen'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                        padding: EdgeInsets.symmetric(
                          horizontal: elementSpacing * 1.5,
                          vertical: elementSpacing * 0.5,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onPracticeCorrect,
                  icon: const Icon(Icons.repeat, size: 20),
                  label: const Text('Practice the Correct Version'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildHighlightedText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyles.body(
          context,
          isDarkMode: isDarkMode,
          color: AppColors.getTextColor(isDarkMode),
        ),
        children: [
          const TextSpan(text: 'I '),
          TextSpan(
            text: 'no can',
            style: TextStyle(
              color: AppColors.error,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
            ),
          ),
          const TextSpan(text: ' join the meeting '),
          TextSpan(
            text: 'yesterday',
            style: TextStyle(
              color: AppColors.error,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
            ),
          ),
          const TextSpan(text: ' because I '),
          TextSpan(
            text: 'am',
            style: TextStyle(
              color: AppColors.error,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 2,
            ),
          ),
          const TextSpan(text: ' sick.'),
        ],
      ),
    );
  }

  List<Widget> _buildMistakeDetails(BuildContext context) {
    final elementSpacing = ResponsiveLayout.getElementSpacing(context);

    return List.generate(
      practiceItem.mistakeDetails.length,
      (index) => Padding(
        padding: EdgeInsets.only(bottom: elementSpacing * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(width: elementSpacing * 1.5),
                Expanded(
                  child: Text(
                    practiceItem.mistakeDetails[index].issue,
                    style: TextStyles.body(
                      context,
                      isDarkMode: isDarkMode,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 24 + elementSpacing * 1.5),
              child: Text(
                practiceItem.mistakeDetails[index].example,
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
            ),
            if (index < practiceItem.mistakeDetails.length - 1)
              Padding(
                padding: EdgeInsets.only(top: elementSpacing * 2),
                child: Divider(
                  color: isDarkMode
                      ? Colors.grey[700]!.withOpacity(0.5)
                      : Colors.grey[200]!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
