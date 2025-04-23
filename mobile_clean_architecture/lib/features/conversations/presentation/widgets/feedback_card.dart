import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/feedback.dart' as app_feedback;

class FeedbackCard extends StatelessWidget {
  final app_feedback.FeedbackResult? feedback;
  final bool isLoading;
  final bool isProcessing;
  final String? processingMessage;
  final String? error;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;

  const FeedbackCard({
    Key? key,
    this.feedback,
    this.isLoading = false,
    this.isProcessing = false,
    this.processingMessage,
    this.error,
    this.onClose,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Language Feedback',
                style: TextStyles.h2(context, isDarkMode: isDarkMode),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Content
          if (isLoading)
            const _LoadingContent()
          else if (isProcessing)
            _ProcessingContent(
              message: processingMessage,
              onRetry: onRetry,
            )
          else if (error != null)
            _ErrorContent(
              message: error!,
              onRetry: onRetry,
            )
          else if (feedback != null)
            _FeedbackContent(feedback: feedback!),

          const SizedBox(height: 16),

          // Close button
          if (onClose != null && !isLoading)
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                text: 'Close',
                onPressed: onClose,
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your English...'),
          ],
        ),
      ),
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const _ProcessingContent({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_bottom,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'Your feedback is being generated',
            style: TextStyles.h3(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message ??
                'This process takes a few seconds. Please wait or try again.',
            style: TextStyles.body(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            PrimaryButton(
              text: 'Check Again',
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorContent({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyles.h3(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyles.body(context, isDarkMode: isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            PrimaryButton(
              text: 'Try Again',
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}

class _FeedbackContent extends StatelessWidget {
  final app_feedback.FeedbackResult feedback;

  const _FeedbackContent({
    Key? key,
    required this.feedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Feedback',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.userFeedback,
                    style: TextStyles.body(context, isDarkMode: isDarkMode),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed feedback (only shown if available)
            if (feedback.detailedFeedback != null) ...[
              Text(
                'Detailed Analysis',
                style: TextStyles.h3(context, isDarkMode: isDarkMode),
              ),
              const SizedBox(height: 12),

              // Grammar issues
              if (feedback.detailedFeedback!.grammarIssues.isNotEmpty) ...[
                _FeedbackSection(
                  title: 'Grammar',
                  icon: Icons.rule,
                  color: AppColors.error,
                  items: feedback.detailedFeedback!.grammarIssues
                      .map((issue) => issue.issue)
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Vocabulary issues
              if (feedback.detailedFeedback!.vocabularyIssues.isNotEmpty) ...[
                _FeedbackSection(
                  title: 'Vocabulary',
                  icon: Icons.book,
                  color: AppColors.warning,
                  items: feedback.detailedFeedback!.vocabularyIssues
                      .map((issue) => issue.original)
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Positives
              if (feedback.detailedFeedback!.positives.isNotEmpty) ...[
                _FeedbackSection(
                  title: 'What You Did Well',
                  icon: Icons.thumb_up,
                  color: AppColors.success,
                  items: feedback.detailedFeedback!.positives,
                ),
                const SizedBox(height: 16),
              ],

              // Fluency
              if (feedback.detailedFeedback!.fluency.isNotEmpty) ...[
                _FeedbackSection(
                  title: 'Fluency',
                  icon: Icons.auto_stories,
                  color: AppColors.info,
                  items: feedback.detailedFeedback!.fluency,
                ),
              ],
            ] else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display simple feedback sections when detailed feedback isn't available
                  const SizedBox(height: 16),
                  _FeedbackSection(
                    title: 'Tips',
                    icon: Icons.lightbulb,
                    color: AppColors.info,
                    items: [
                      'Keep practicing regularly to improve your English skills.',
                      'Try to apply this feedback in your next conversation.'
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _FeedbackSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.h3(
                  context,
                  isDarkMode: isDarkMode,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: TextStyles.body(
                        context,
                        isDarkMode: isDarkMode,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyles.body(
                          context,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
