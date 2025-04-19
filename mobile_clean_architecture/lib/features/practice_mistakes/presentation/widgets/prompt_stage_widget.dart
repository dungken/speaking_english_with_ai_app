import 'package:flutter/material.dart';

import '../../domain/models/practice_item_model.dart';
import 'common_widgets.dart';

class PromptStageWidget extends StatelessWidget {
  final PracticeItemModel practiceItem;
  final bool isDarkMode;
  final VoidCallback onRecordTap;

  const PromptStageWidget({
    super.key,
    required this.practiceItem,
    required this.isDarkMode,
    required this.onRecordTap,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 16,
                    color: Colors.amber[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Based on mistakes from your conversations',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildCard(
          isDarkMode,
          child: Column(
            children: [
              Text(
                'Tap to record your response',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              buildRecordButton(
                isDarkMode: isDarkMode,
                onTap: onRecordTap,
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
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.amber[500],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'What to Watch For',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pay attention to using the correct verb tense when talking about past events.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is an area you\'ve struggled with before',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
