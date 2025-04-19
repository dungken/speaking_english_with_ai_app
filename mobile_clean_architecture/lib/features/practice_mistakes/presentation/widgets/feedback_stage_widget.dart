import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Response',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: const Text('Play'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDarkMode ? Colors.blue[300] : Colors.blue[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[700]!.withAlpha(255)
                        : Colors.grey[200]!.withAlpha(255),
                  ),
                ),
                child: _buildHighlightedText(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Improvement Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildMistakeDetails(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.green[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Better way to express this:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[100]!.withAlpha(255),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practiceItem.betterExpression,
                      style: TextStyle(
                        color:
                            isDarkMode ? Colors.green[100] : Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, size: 12),
                      label: const Text('Listen'),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDarkMode ? Colors.green[300] : Colors.green[700],
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPracticeCorrect,
                  icon: const Icon(Icons.repeat),
                  label: const Text('Practice the Correct Version'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDarkMode ? Colors.blue[800] : Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ),
        children: [
          const TextSpan(text: 'I '),
          TextSpan(
            text: 'no can',
            style: TextStyle(
              color: Colors.red[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const TextSpan(text: ' join the meeting '),
          TextSpan(
            text: 'yesterday',
            style: TextStyle(
              color: Colors.red[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const TextSpan(text: ' because I '),
          TextSpan(
            text: 'am',
            style: TextStyle(
              color: Colors.red[500],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const TextSpan(text: ' sick.'),
        ],
      ),
    );
  }

  List<Widget> _buildMistakeDetails() {
    return List.generate(
      practiceItem.mistakeDetails.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red[500],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    practiceItem.mistakeDetails[index].issue,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                practiceItem.mistakeDetails[index].example,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            if (index < practiceItem.mistakeDetails.length - 1)
              const Divider(height: 24),
          ],
        ),
      ),
    );
  }
}
