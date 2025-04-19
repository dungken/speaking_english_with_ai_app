import 'package:flutter/material.dart';

import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class CompleteStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final VoidCallback onNext;

  const CompleteStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.green[900] : Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 28,
            color: Colors.green[500],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Great job!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You\'ve practiced the correct way to express this idea. This will help you avoid similar mistakes in the future.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        _buildImprovementCard(),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue to Next Practice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.blue[800] : Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementCard() {
    return buildCard(
      isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Improvement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.red[900] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode
                    ? Colors.red[800]!.withAlpha(255)
                    : Colors.red[100]!.withAlpha(255),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  practiceItem.commonMistake,
                  style: TextStyle(
                    color: isDarkMode ? Colors.red[100] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  'After:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  practiceItem.betterExpression,
                  style: TextStyle(
                    color: isDarkMode ? Colors.green[100] : Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accuracy:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Text(
                    '95%',
                    style: TextStyle(
                      color: Colors.green[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 128,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[700]!.withAlpha(255)
                          : Colors.grey[200]!.withAlpha(255),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.95,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[500],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
