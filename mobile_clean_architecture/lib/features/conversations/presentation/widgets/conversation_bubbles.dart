import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onFeedbackPressed;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onFeedbackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isUserMessage = message.sender == SenderType.user;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isUserMessage ? 50 : 0,
          right: isUserMessage ? 0 : 50,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.getSurfaceColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUserMessage
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role label
            Text(
              isUserMessage ? 'You' : 'AI',
              style: TextStyles.caption(
                context,
                isDarkMode: isDarkMode,
                color: isUserMessage
                    ? AppColors.primary
                    : AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // Message content
            Text(
              message.content,
              style: TextStyles.body(
                context,
                isDarkMode: isDarkMode,
              ),
            ),
            
            // Feedback button (for user messages only)
            if (onFeedbackPressed != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onFeedbackPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Get Feedback',
                          style: TextStyles.caption(
                            context,
                            isDarkMode: isDarkMode,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
