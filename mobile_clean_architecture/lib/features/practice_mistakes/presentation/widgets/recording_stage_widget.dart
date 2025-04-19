import 'package:flutter/material.dart';

import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class RecordingStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final String recordingState; // 'ready', 'recording', 'recorded'
  final VoidCallback onRecordTap;
  final VoidCallback onRecordAgain;
  final VoidCallback onShowFeedback;

  const RecordingStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.recordingState,
    required this.onRecordTap,
    required this.onRecordAgain,
    required this.onShowFeedback,
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
                'Express This Idea',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.blue[700]!.withAlpha(255)
                        : Colors.blue[100]!.withAlpha(255),
                  ),
                ),
                child: Text(
                  practiceItem.situationPrompt,
                  style: TextStyle(
                    color: isDarkMode ? Colors.blue[100] : Colors.blue[700],
                  ),
                ),
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
                'Your Response',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (recordingState == 'recording')
                _buildRecordingInProgress()
              else
                _buildRecordingCompleted(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInProgress() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.red[900] : Colors.red[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red[500],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Recording...',
          style: TextStyle(
            color: Colors.red[500],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to stop',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onRecordTap,
          child: Container(
            width: 56,
            height: 56,
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
  }

  Widget _buildRecordingCompleted() {
    return Column(
      children: [
        buildAudioProgressBar(
          isDarkMode: isDarkMode,
          progress: 0.75,
          duration: '0:04',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey[700]!.withAlpha(255)
                  : Colors.grey[200]!.withAlpha(255),
            ),
          ),
          child: Text(
            practiceItem.commonMistake,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRecordAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Record Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  foregroundColor:
                      isDarkMode ? Colors.blue[300] : Colors.blue[600],
                  elevation: 0,
                  side: BorderSide(
                    color: isDarkMode
                        ? Colors.blue[700]!.withAlpha(255)
                        : Colors.blue[200]!.withAlpha(255),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onShowFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? Colors.blue[800] : Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('See Feedback'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
