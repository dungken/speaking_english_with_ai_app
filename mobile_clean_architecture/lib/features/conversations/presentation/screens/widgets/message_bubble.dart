import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../domain/entities/message.dart';

/// Widget that displays a message bubble in the conversation
///
/// Shows different styling for user and AI messages,
/// and provides a button to request feedback for user messages
class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onFeedbackRequest;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onFeedbackRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.sender == SenderType.user;
    final hasAudio = message.audioPath != null && message.audioPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) _buildAvatar(isUserMessage),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUserMessage
                        ? AppColors.primary.withOpacity(0.9)
                        : AppColors.getSurfaceColor(false),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyles.body(
                          context,
                          color: isUserMessage ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyles.caption(
                              context,
                              color: isUserMessage
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey,
                            ),
                          ),
                          if (isUserMessage &&
                              hasAudio &&
                              onFeedbackRequest != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: onFeedbackRequest,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Feedback',
                                      style: TextStyles.caption(
                                        context,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (message.feedbackId != null && !isUserMessage)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Feedback available',
                      style: TextStyles.caption(
                        context,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUserMessage) _buildAvatar(isUserMessage),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser ? AppColors.primary : AppColors.accent,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}
