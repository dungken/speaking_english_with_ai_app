import 'package:flutter/material.dart';
import '../../../domain/entities/grammar_entity.dart';

class GrammarStage extends StatelessWidget {
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double tinyPadding = 8.0;
  static const double defaultBorderRadius = 20.0;
  static const double smallBorderRadius = 16.0;
  static const double defaultElevation = 3.0;
  static const double defaultIconSize = 24.0;
  static const double defaultFontSize = 16.0;
  static const double largeFontSize = 24.0;

  final GrammarEntity grammar;
  final VoidCallback onShowExplanation;
  final VoidCallback onShowExample;
  final VoidCallback onShowPractice;

  const GrammarStage({
    Key? key,
    required this.grammar,
    required this.onShowExplanation,
    required this.onShowExample,
    required this.onShowPractice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleSection(context),
        const SizedBox(height: defaultPadding),
        _buildActionsSection(context),
        const SizedBox(height: defaultPadding),
        _buildExampleSection(context),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
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
            grammar.title,
            style: TextStyle(
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            grammar.description,
            style: const TextStyle(
              fontSize: defaultFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.book,
          label: 'Explanation',
          onPressed: onShowExplanation,
        ),
        _buildActionButton(
          context,
          icon: Icons.format_quote,
          label: 'Example',
          onPressed: onShowExample,
        ),
        _buildActionButton(
          context,
          icon: Icons.edit,
          label: 'Practice',
          onPressed: onShowPractice,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: smallPadding,
          horizontal: defaultPadding,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildExampleSection(BuildContext context) {
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
            'Example:',
            style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            grammar.example,
            style: const TextStyle(
              fontSize: defaultFontSize,
            ),
          ),
          const SizedBox(height: smallPadding),
          Text(
            'Translation: ${grammar.exampleTranslation}',
            style: TextStyle(
              fontSize: defaultFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
