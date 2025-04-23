import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A simplified feedback panel that displays a string feedback
/// 
/// This is a temporary solution until the detailed feedback structure is implemented
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
        boxShadow: [
          if (isOverlay)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
        ],
        borderRadius: isOverlay
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeedbackContent(context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SecondaryButton(
              text: 'Close Feedback',
              onPressed: onClose,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );

    if (isOverlay) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Dismissible area - tapping here will close the panel
            Expanded(
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // The actual panel (non-dismissible)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: panel,
            ),
          ],
        ),
      );
    }

    return panel;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: isOverlay
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            : BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.feedback_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Language Feedback',
              style: TextStyles.h3(context),
            ),
          ),
          if (isOverlay)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback',
            style: TextStyles.h3(context),
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: TextStyles.body(context),
          ),
        ],
      ),
    );
  }
}
