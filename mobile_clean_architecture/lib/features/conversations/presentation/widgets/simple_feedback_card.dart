import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class SimpleFeedbackCard extends StatelessWidget {
  final String? feedback;
  final bool isLoading;
  final bool isProcessing;
  final String? processingMessage;
  final String? error;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;

  const SimpleFeedbackCard({
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
            message ?? 'This process takes a few seconds. Please wait or try again.',
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
  final String feedback;

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
            // Only display the feedback string
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
                    'Feedback',
                    style: TextStyles.h3(context, isDarkMode: isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback,
                    style: TextStyles.body(context, isDarkMode: isDarkMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
