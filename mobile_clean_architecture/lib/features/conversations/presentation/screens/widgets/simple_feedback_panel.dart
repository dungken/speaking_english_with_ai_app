import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

/// A simple panel that displays text feedback on the user's speech
///
/// This shows only the main feedback text without detailed categories.
/// It can be displayed as an overlay or as part of the main layout.
class SimpleFeedbackPanel extends StatelessWidget {
  final String feedback;
  final VoidCallback onClose;
  final bool isOverlay;

  const SimpleFeedbackPanel({
    Key? key,
    required this.feedback,
    required this.onClose,
    this.isOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(false),
        borderRadius: isOverlay ? null : BorderRadius.circular(12),
        boxShadow: isOverlay
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: isOverlay
                  ? null
                  : const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Feedback',
                    style: TextStyles.h3(context, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                  tooltip: 'Close feedback',
                ),
              ],
            ),
          ),
          // Feedback content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback,
                    style: TextStyles.body(context),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    context,
                    'Apply this feedback in your next response to improve your speaking skills!',
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Continue Conversation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withOpacity(0.6),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: panel,
            ),
          ),
        ),
      );
    }

    return panel;
  }

  Widget _buildTipCard(BuildContext context, String tipText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tipText,
              style: TextStyles.secondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
