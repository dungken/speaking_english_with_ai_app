import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../cubit/image_description_cubit.dart';
import '../../domain/entities/feedback_entity.dart';

/// Widget that displays user's transcription feedback with improvements
class FeedbackDisplayWidget extends StatelessWidget {
  final String userTranscription;
  final ImageFeedbackEntity? feedback;
  final VoidCallback? onNext;

  const FeedbackDisplayWidget({
    super.key,
    required this.userTranscription,
    this.feedback,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with next button
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                if (onNext != null)
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveLayout.getCardPadding(context) * 2,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyles.button(context),
                    ),
                  ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),

            // User's description
            Text(
              'Your description',
              style: TextStyles.secondary(context, isDarkMode: isDarkMode),
            ),
            SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
            Text(
              userTranscription.isNotEmpty
                  ? userTranscription
                  : 'No transcription available',
              style: TextStyles.body(context, isDarkMode: isDarkMode)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),

            // Feedback content
            if (feedback != null) ...[
              // Better version
              Text(
                'Improved version',
                style: TextStyles.secondary(context, isDarkMode: isDarkMode),
              ),
              SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
              Text(
                feedback!.betterVersion,
                style: TextStyles.body(context, isDarkMode: isDarkMode)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),

              // Explanation
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation',
                      style: TextStyles.h3(context, color: Colors.white),
                    ),
                    SizedBox(
                        height: ResponsiveLayout.getElementSpacing(context)),
                    Text(
                      feedback!.explanation,
                      style: TextStyles.body(context, color: Colors.white)
                          .copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Loading state for feedback
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(isDarkMode),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(
                        height: ResponsiveLayout.getSectionSpacing(context)),
                    Text(
                      'Generating feedback...',
                      style: TextStyles.body(context, isDarkMode: isDarkMode),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error widget for feedback display
class FeedbackErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const FeedbackErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
          Text(
            'Feedback Error',
            style: TextStyles.h2(context, isDarkMode: isDarkMode),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Text(
            errorMessage,
            style: TextStyles.body(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Try Again',
                style: TextStyles.button(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
