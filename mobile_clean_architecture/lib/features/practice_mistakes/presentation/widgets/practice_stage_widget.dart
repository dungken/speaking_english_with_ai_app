import 'package:flutter/material.dart';

import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class PracticeStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final String recordingState; // 'ready', 'recording', 'recorded'
  final VoidCallback onRecordTap;
  final VoidCallback onRecordAgain;
  final VoidCallback onComplete;

  const PracticeStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.recordingState,
    required this.onRecordTap,
    required this.onRecordAgain,
    required this.onComplete,
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
              const Text(
                'Practice the Correct Version',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      practiceItem.betterExpression,
                      style: TextStyle(
                        color: isDarkMode ? Colors.green[100] : Colors.green[800],
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
              const Text(
                'Alternative Expressions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildAlternatives(),
              const Divider(height: 32),
              const Text(
                'Your Practice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecordingSection(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildCard(
          isDarkMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Why This Matters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Using the correct tense helps your listener understand exactly when events happened. For past events, using past tense forms like "couldn\'t" and "was" is essential for clarity.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAlternatives() {
    return List.generate(
      practiceItem.alternatives.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue[800] : Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                practiceItem.alternatives[index],
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    if (recordingState == 'recording') {
      return Column(
        children: [
          Text(
            'Recording...',
            style: TextStyle(
              color: Colors.red[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onRecordTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red[500],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stop,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (recordingState == 'recorded') {
      return Column(
        children: [
          buildAudioProgressBar(
            isDarkMode: isDarkMode,
            progress: 1.0,
            duration: '0:03',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRecordAgain,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    foregroundColor: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                    elevation: 0,
                    side: BorderSide(
                      color: isDarkMode
                          ? Colors.blue[700]!.withAlpha(255)
                          : Colors.blue[200]!.withAlpha(255),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle, size: 14),
                  label: const Text('Perfect!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.green[800]!.withAlpha(255)
                        : Colors.green[600]!.withAlpha(255),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Center(
        child: GestureDetector(
          onTap: onRecordTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue[800] : Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
  }
}
