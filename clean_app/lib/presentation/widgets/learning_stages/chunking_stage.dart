import 'package:flutter/material.dart';
import '../../../domain/entities/chunk_entity.dart';

class ChunkingStage extends StatelessWidget {
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double defaultBorderRadius = 20.0;
  static const double smallBorderRadius = 16.0;
  static const double defaultElevation = 3.0;
  static const double defaultIconSize = 24.0;
  static const double defaultFontSize = 16.0;
  static const double largeFontSize = 24.0;

  final String questionTranslation;
  final ChunkEntity currentChunk;
  final String userAnswer;
  final bool showFeedback;
  final Function(String) onAnswerSelected;
  final VoidCallback onPlayAudio;
  final List<String> options;

  const ChunkingStage({
    Key? key,
    required this.questionTranslation,
    required this.currentChunk,
    required this.userAnswer,
    required this.showFeedback,
    required this.onAnswerSelected,
    required this.onPlayAudio,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionSection(context),
        const SizedBox(height: defaultPadding),
        _buildMultipleChoiceSection(context),
      ],
    );
  }

  Widget _buildQuestionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Listen and select the correct chunk:',
            style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: smallPadding),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_outline),
                iconSize: defaultIconSize,
                onPressed: onPlayAudio,
              ),
              const SizedBox(width: tinyPadding),
              Expanded(
                child: Text(
                  currentChunk.phrase,
                  style: const TextStyle(
                    fontSize: defaultFontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: smallPadding),
          Text(
            'Translation: $questionTranslation',
            style: TextStyle(
              fontSize: defaultFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the correct chunk:',
          style: TextStyle(
            fontSize: defaultFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: smallPadding),
        ...options
            .map((option) => _buildOptionButton(context, option))
            .toList(),
        if (showFeedback) ...[
          const SizedBox(height: defaultPadding),
          _buildFeedbackSection(context),
        ],
      ],
    );
  }

  Widget _buildOptionButton(BuildContext context, String option) {
    final bool isSelected = option == userAnswer;
    final bool isCorrect = option == currentChunk.phrase;

    return Padding(
      padding: const EdgeInsets.only(bottom: smallPadding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: showFeedback
              ? isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : isSelected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.white
              : isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.white,
          foregroundColor: showFeedback
              ? isCorrect
                  ? Colors.green
                  : isSelected
                      ? Colors.red
                      : Colors.black
              : isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallBorderRadius),
            side: BorderSide(
              color: showFeedback
                  ? isCorrect
                      ? Colors.green
                      : isSelected
                          ? Colors.red
                          : Colors.grey.shade300
                  : isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: smallPadding,
            horizontal: defaultPadding,
          ),
        ),
        onPressed: () => onAnswerSelected(option),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: defaultFontSize,
                ),
              ),
            ),
            if (showFeedback && (isSelected || isCorrect))
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final bool isCorrect = userAnswer == currentChunk.phrase;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: smallPadding),
              Text(
                isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: defaultFontSize,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: smallPadding),
          Text(
            isCorrect
                ? 'Great job! You correctly identified the chunk.'
                : 'The correct chunk is: ${currentChunk.phrase}',
            style: const TextStyle(
              fontSize: defaultFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
