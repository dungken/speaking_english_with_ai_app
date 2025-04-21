import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class FeedbackPanel extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onClose;

  const FeedbackPanel({
    Key? key,
    required this.feedback,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: AppColors.getBackgroundColor(isDarkMode).withOpacity(0.95),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feedback',
                  style: TextStyles.h2(context, isDarkMode: isDarkMode),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (feedback['grammarIssues'] != null &&
                      (feedback['grammarIssues'] as List).isNotEmpty)
                    _buildSection(
                      context,
                      'Grammar',
                      feedback['grammarIssues'] as List,
                      Icons.spellcheck,
                      Colors.red.shade600,
                      isDarkMode,
                    ),
                  
                  if (feedback['vocabularySuggestions'] != null &&
                      (feedback['vocabularySuggestions'] as List).isNotEmpty)
                    _buildSection(
                      context,
                      'Vocabulary',
                      feedback['vocabularySuggestions'] as List,
                      Icons.book,
                      Colors.blue.shade600,
                      isDarkMode,
                    ),
                  
                  if (feedback['pronunciationFeedback'] != null &&
                      (feedback['pronunciationFeedback'] as List).isNotEmpty)
                    _buildSection(
                      context,
                      'Pronunciation',
                      feedback['pronunciationFeedback'] as List,
                      Icons.record_voice_over,
                      Colors.orange.shade600,
                      isDarkMode,
                    ),
                  
                  if (feedback['positiveAspects'] != null &&
                      (feedback['positiveAspects'] as List).isNotEmpty)
                    _buildSection(
                      context,
                      'What You Did Well',
                      feedback['positiveAspects'] as List,
                      Icons.thumb_up,
                      Colors.green.shade600,
                      isDarkMode,
                    ),
                  
                  if (feedback['fluencyScore'] != null)
                    _buildFluencyScore(
                      context,
                      feedback['fluencyScore'] as double,
                      isDarkMode,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List items,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.h3(context, isDarkMode: isDarkMode).copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildFeedbackItem(context, item, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(BuildContext context, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyles.body(context, isDarkMode: isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluencyScore(BuildContext context, double score, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.purple.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Fluency Score',
                style: TextStyles.h3(context, isDarkMode: isDarkMode).copyWith(
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: score / 10,
                    minHeight: 20,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: _getFluencyColor(score),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${score.toStringAsFixed(1)}/10',
                style: TextStyles.h3(context, isDarkMode: isDarkMode),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getFluencyFeedback(score),
            style: TextStyles.body(context, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }

  Color _getFluencyColor(double score) {
    if (score >= 8.5) return Colors.green.shade500;
    if (score >= 7.0) return Colors.lightGreen.shade500;
    if (score >= 5.5) return Colors.amber.shade500;
    if (score >= 4.0) return Colors.orange.shade500;
    return Colors.red.shade500;
  }

  String _getFluencyFeedback(double score) {
    if (score >= 8.5) {
      return 'Excellent fluency! Your speech flows naturally with minimal hesitation.';
    } else if (score >= 7.0) {
      return 'Very good fluency. You speak smoothly with only occasional pauses.';
    } else if (score >= 5.5) {
      return 'Good fluency, but work on reducing pauses and hesitations.';
    } else if (score >= 4.0) {
      return 'Your fluency needs improvement. Try to reduce the frequent pauses and hesitations.';
    } else {
      return 'Focus on building fluency by practicing speaking more regularly.';
    }
  }
}
