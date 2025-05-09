import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class PromptStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final VoidCallback onRecordTap;

  const PromptStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.onRecordTap,
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
              SizedBox(height: elementSpacing * 3),
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 16,
                    color: AppColors.streakPrimary,
                  ),
                  SizedBox(width: elementSpacing),
                  Text(
                    'Based on mistakes from your conversations',
                    style: TextStyles.caption(
                      context,
                      isDarkMode: isDarkMode,
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: sectionSpacing * 0.75),
        buildCard(
          context,
          isDarkMode,
          child: Column(
            children: [
              Text(
                'Tap to record your response',
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
              SizedBox(height: elementSpacing * 3),
              buildRecordButton(
                context: context,
                isDarkMode: isDarkMode,
                onTap: onRecordTap,
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
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: elementSpacing * 1.5),
                  Text(
                    'What to Watch For',
                    style: TextStyles.h3(
                      context,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              SizedBox(height: elementSpacing * 2),
              Text(
                'Pay attention to using the correct verb tense when talking about past events.',
                style: TextStyles.body(
                  context,
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(height: elementSpacing * 1.5),
              Text(
                'This is an area you\'ve struggled with before',
                style: TextStyles.caption(
                  context,
                  isDarkMode: isDarkMode,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
