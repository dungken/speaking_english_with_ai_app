import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// A reusable error dialog that shows an error message and optional retry button
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        title,
        style: TextStyles.h6(context, isDarkMode: isDarkMode),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyles.button(context, isDarkMode: isDarkMode).copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        if (showRetryButton && onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(
              'Retry',
              style:
                  TextStyles.button(context, isDarkMode: isDarkMode).copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  /// Show the error dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        showRetryButton: showRetryButton,
      ),
    );
  }
}
