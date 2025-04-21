import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../domain/entities/message.dart';

/// A bubble to display a message in a conversation
///
/// Different styling for user and AI messages
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
    final timeFormat = DateFormat.jm();
    final timeString = timeFormat.format(message.timestamp);

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: isUserMessage
              ? AppColors.primary.withOpacity(0.8)
              : AppColors.getSurfaceColor(false),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyles.body(
                    context,
                    isDarkMode: isUserMessage,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyles.caption(
                        context,
                        isDarkMode: isUserMessage,
                      ),
                    ),
                    if (isUserMessage && onFeedbackRequest != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onFeedbackRequest,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.feedback_outlined,
                                size: 14,
                                color: AppColors.getTextColor(isUserMessage),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Feedback',
                                style: TextStyles.caption(
                                  context,
                                  isDarkMode: isUserMessage,
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
        ),
      ),
    );
  }
}
