import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class ScoreIndicator extends StatelessWidget {
  final String title;
  final double score;
  final bool showLabel;

  const ScoreIndicator({
    Key? key,
    required this.title,
    required this.score,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: UIConstants.titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.tinyPadding),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(score),
              ),
              minHeight: UIConstants.progressBarHeight,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: UIConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Accuracy',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: UIConstants.defaultFontSize,
                  ),
                ),
                Text(
                  '${(score * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontSize: UIConstants.defaultFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= UIConstants.scoreThresholdHigh) return Colors.green;
    if (score >= UIConstants.scoreThresholdMedium) return Colors.orange;
    return Colors.red;
  }
}
