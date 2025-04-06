import 'package:flutter/material.dart';

class ReflexPracticeStage extends StatelessWidget {
  final String sentence;
  final String translation;
  final List<String> chunks;
  final bool showFeedback;
  final double reactionTime;
  final Function(String) onAnswerSelected;
  final VoidCallback onPlayAudio;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isRecording;

  const ReflexPracticeStage({
    Key? key,
    required this.sentence,
    required this.translation,
    required this.chunks,
    required this.showFeedback,
    required this.reactionTime,
    required this.onAnswerSelected,
    required this.onPlayAudio,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConversationBubble(
            context,
            isUser: false,
            text:
                "Now, let's have a conversation! I'll ask you questions, and you can respond naturally.",
          ),
          const SizedBox(height: 16),
          _buildConversationBubble(
            context,
            isUser: false,
            text: sentence,
            showAudioButton: true,
          ),
          const SizedBox(height: 16),
          _buildConversationBubble(
            context,
            isUser: false,
            text: "Here's what it means: $translation",
            isTranslation: true,
          ),
          const SizedBox(height: 24),
          _buildRecordingSection(context),
          if (showFeedback) ...[
            const SizedBox(height: 16),
            _buildFeedbackSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationBubble(
    BuildContext context, {
    required bool isUser,
    required String text,
    bool showAudioButton = false,
    bool isTranslation = false,
  }) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.android, color: Colors.white),
            ),
          ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).primaryColor
                  : isTranslation
                      ? Colors.grey.shade100
                      : Colors.white,
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
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isUser
                            ? Colors.white
                            : isTranslation
                                ? Colors.grey.shade700
                                : Colors.black,
                      ),
                ),
                if (showAudioButton) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onPlayAudio,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Listen'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildRecordingSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            isRecording ? 'Recording...' : 'Click to Answer',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isRecording ? Colors.red : Colors.grey.shade700,
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
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return _buildConversationBubble(
      context,
      isUser: false,
      text: _getFeedbackText(),
    );
  }

  String _getFeedbackText() {
    if (reactionTime <= 1.5) {
      return "Great response! You answered quickly and naturally. Your conversation skills are excellent!";
    } else if (reactionTime <= 3.0) {
      return "Good job! You're maintaining a natural conversation pace. Keep practicing to respond even more quickly.";
    } else {
      return "Take your time to think, but try to respond a bit more quickly to keep the conversation flowing naturally.";
    }
  }
}
