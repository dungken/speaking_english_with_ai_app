import 'package:flutter/material.dart';
import '../common/score_indicator.dart';

class SentenceBuildingStage extends StatelessWidget {
  final String sentence;
  final String translation;
  final bool isRecording;
  final bool showFeedback;
  final double pronunciationScore;
  final VoidCallback onPlayAudio;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const SentenceBuildingStage({
    Key? key,
    required this.sentence,
    required this.translation,
    required this.isRecording,
    required this.showFeedback,
    required this.pronunciationScore,
    required this.onPlayAudio,
    required this.onStartRecording,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionCard(context),
          const SizedBox(height: 24),
          _buildSentenceCard(context),
          const SizedBox(height: 24),
          _buildRecordingSection(context),
          if (showFeedback) ...[
            const SizedBox(height: 24),
            _buildFeedbackSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Read the sentence aloud clearly. Listen to your recording to improve pronunciation.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            sentence,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            translation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.volume_up),
            label: const Text('Listen to Example'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isRecording ? 'Recording in Progress...' : 'Record Your Reading',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isRecording ? Colors.red : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: isRecording ? onStopRecording : onStartRecording,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRecording
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color:
                    isRecording ? Colors.red : Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isRecording ? 'Tap to Stop' : 'Tap to Start',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            'Reading Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ScoreIndicator(
            title: 'Pronunciation',
            score: pronunciationScore,
            showLabel: true,
          ),
          const SizedBox(height: 16),
          Text(
            _getFeedbackText(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getFeedbackText() {
    if (pronunciationScore >= 0.8) {
      return "Excellent reading! Your pronunciation is clear and natural.";
    } else if (pronunciationScore >= 0.6) {
      return "Good reading. Focus on word stress and intonation to improve further.";
    } else {
      return "Keep practicing. Try to speak more clearly and pay attention to each word.";
    }
  }
}
