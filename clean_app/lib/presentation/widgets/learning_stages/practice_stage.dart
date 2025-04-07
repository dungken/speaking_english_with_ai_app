import 'package:flutter/material.dart';
import '../../../domain/entities/practice_entity.dart';

class PracticeStage extends StatelessWidget {
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double defaultBorderRadius = 20.0;
  static const double smallBorderRadius = 16.0;
  static const double defaultElevation = 3.0;
  static const double defaultIconSize = 24.0;
  static const double defaultFontSize = 16.0;
  static const double largeFontSize = 24.0;

  final PracticeEntity practice;
  final String userAnswer;
  final bool showFeedback;
  final Function(String) onAnswerSubmitted;
  final VoidCallback onNextQuestion;

  const PracticeStage({
    Key? key,
    required this.practice,
    required this.userAnswer,
    required this.showFeedback,
    required this.onAnswerSubmitted,
    required this.onNextQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionSection(context),
        const SizedBox(height: defaultPadding),
        _buildAnswerSection(context),
        if (showFeedback) ...[
          const SizedBox(height: defaultPadding),
          _buildFeedbackSection(context),
        ],
      ],
    );
  }

  Widget _buildQuestionSection(BuildContext context) {
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
            'Question:',
            style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            practice.question,
            style: const TextStyle(
              fontSize: defaultFontSize,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            'Translation: ${practice.questionTranslation}',
            style: TextStyle(
              fontSize: defaultFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context) {
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
            'Your Answer:',
            style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: smallPadding),
          TextField(
            onChanged: onAnswerSubmitted,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(smallBorderRadius),
              ),
              contentPadding: const EdgeInsets.all(smallPadding),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final bool isCorrect =
        userAnswer.toLowerCase() == practice.answer.toLowerCase();

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
                ? 'Great job! Your answer is correct.'
                : 'The correct answer is: ${practice.answer}',
            style: const TextStyle(
              fontSize: defaultFontSize,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            'Translation: ${practice.answerTranslation}',
            style: TextStyle(
              fontSize: defaultFontSize,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: defaultPadding),
          Center(
            child: ElevatedButton(
              onPressed: onNextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: smallPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(smallBorderRadius),
                ),
              ),
              child: const Text('Next Question'),
            ),
          ),
        ],
      ),
    );
  }
}
