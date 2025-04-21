import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../domain/entities/feedback.dart';

/// Panel to display feedback on a user's message
///
/// Shows grammar and vocabulary issues with corrections and explanations
class FeedbackPanel extends StatelessWidget {
  final FeedbackResult feedback;
  final VoidCallback onClose;
  final bool isOverlay;

  const FeedbackPanel({
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
                  _buildOverallFeedback(context),
                  const SizedBox(height: 16),
                  if (feedback.detailedFeedback.grammarIssues.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Grammar Issues'),
                    const SizedBox(height: 8),
                    ...feedback.detailedFeedback.grammarIssues.map(
                      (issue) => _buildGrammarIssueCard(context, issue),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (feedback.detailedFeedback.vocabularyIssues.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Vocabulary Suggestions'),
                    const SizedBox(height: 8),
                    ...feedback.detailedFeedback.vocabularyIssues.map(
                      (issue) => _buildVocabularyIssueCard(context, issue),
                    ),
                  ],
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

  Widget _buildOverallFeedback(BuildContext context) {
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
            'Overall Feedback',
            style: TextStyles.h3(context),
          ),
          const SizedBox(height: 8),
          Text(
            feedback.userFeedback,
            style: TextStyles.body(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyles.h3(context),
    );
  }

  Widget _buildGrammarIssueCard(BuildContext context, GrammarIssue issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.error.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issue',
                        style: TextStyles.secondary(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        issue.issue,
                        style: TextStyles.body(context).copyWith(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.error,
                          color: AppColors.getTextColor(false).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correction',
                        style: TextStyles.secondary(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        issue.correction,
                        style: TextStyles.body(context).copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Explanation',
              style: TextStyles.secondary(
                context,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              issue.explanation,
              style: TextStyles.body(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyIssueCard(BuildContext context, VocabularyIssue issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.info.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original',
                        style: TextStyles.secondary(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        issue.original,
                        style: TextStyles.body(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Better Alternative',
                        style: TextStyles.secondary(
                          context,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        issue.betterAlternative,
                        style: TextStyles.body(context).copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Reason',
              style: TextStyles.secondary(
                context,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              issue.reason,
              style: TextStyles.body(context),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example Usage',
                    style: TextStyles.secondary(
                      context,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.exampleUsage,
                    style: TextStyles.body(context).copyWith(
                      fontStyle: FontStyle.italic,
                    ),
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
