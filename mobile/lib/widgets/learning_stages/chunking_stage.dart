import 'package:flutter/material.dart';
import '../../model/chunk.dart';

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
  final Chunk currentChunk;
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
            'Translate the bold phrase:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: defaultPadding),
          _buildTranslationBox(context),
        ],
      ),
    );
  }

  Widget _buildTranslationBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(smallBorderRadius),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionTranslation,
            style: const TextStyle(
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: smallPadding),
          InkWell(
            onTap: onPlayAudio,
            child: Row(
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: Theme.of(context).primaryColor,
                  size: defaultIconSize,
                ),
                const SizedBox(width: tinyPadding),
                Text(
                  'Tap to listen',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: defaultFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceSection(BuildContext context) {
    return Container(
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
            'Choose the correct answer:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: defaultPadding),
          ..._buildChoiceButtons(context),
        ],
      ),
    );
  }

  List<Widget> _buildChoiceButtons(BuildContext context) {
    return options.map((text) {
      final bool isSelected = text == userAnswer;
      final bool isCorrectAnswer = text == currentChunk.phrase;

      return Padding(
        padding: const EdgeInsets.only(bottom: smallPadding),
        child: _buildChoiceButton(
          context,
          text,
          isSelected,
          isCorrectAnswer,
        ),
      );
    }).toList();
  }

  Widget _buildChoiceButton(
    BuildContext context,
    String text,
    bool isSelected,
    bool isCorrectAnswer,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onAnswerSelected(text),
        style: _getChoiceButtonStyle(
          context,
          isSelected,
          isCorrectAnswer,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: defaultFontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  ButtonStyle _getChoiceButtonStyle(
    BuildContext context,
    bool isSelected,
    bool isCorrectAnswer,
  ) {
    return ElevatedButton.styleFrom(
      backgroundColor: _getChoiceButtonColor(isSelected, isCorrectAnswer),
      foregroundColor: _getChoiceButtonTextColor(isSelected, isCorrectAnswer),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: smallPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
        side: BorderSide(
          color: _getChoiceButtonBorderColor(isSelected, isCorrectAnswer),
          width: 1,
        ),
      ),
      elevation: isSelected ? 0 : defaultElevation,
    );
  }

  Color _getChoiceButtonColor(bool isSelected, bool isCorrectAnswer) {
    if (!showFeedback) return Colors.white;
    if (isCorrectAnswer) return Colors.green.shade500;
    if (isSelected) return Colors.red.shade500;
    return Colors.grey.shade200;
  }

  Color _getChoiceButtonTextColor(bool isSelected, bool isCorrectAnswer) {
    if (!showFeedback) return Colors.black87;
    if (isCorrectAnswer || isSelected) return Colors.white;
    return Colors.black87;
  }

  Color _getChoiceButtonBorderColor(bool isSelected, bool isCorrectAnswer) {
    if (!showFeedback) return Colors.grey.shade300;
    if (isCorrectAnswer) return Colors.green.shade500;
    if (isSelected) return Colors.red.shade500;
    return Colors.grey.shade300;
  }
}
