import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool hasFeedback;
  final VoidCallback? onFeedbackTap;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.hasFeedback = false,
    this.onFeedbackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('h:mm a');
    // Get screen width to ensure proper width constraints
    final screenWidth = MediaQuery.of(context).size.width;
    // Set a max width for the bubble to prevent overflow
    final maxBubbleWidth = screenWidth * 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.smart_toy_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxBubbleWidth,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Message bubble
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : AppColors.getSurfaceColor(isDarkMode),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight:
                                isUser ? const Radius.circular(0) : null,
                            bottomLeft:
                                !isUser ? const Radius.circular(0) : null,
                          ),
                          border: !isUser
                              ? Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.getBodyTextSize(context),
                            color: isUser
                                ? Colors.white
                                : AppColors.getTextColor(isDarkMode),
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),

                      // Feedback button
                      if (hasFeedback && onFeedbackTap != null)
                        Positioned(
                          top: -8,
                          right: -8,
                          child: GestureDetector(
                            onTap: onFeedbackTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isUser)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              left: isUser ? 0 : 8.0,
              right: isUser ? 8.0 : 0,
            ),
            child: Text(
              timeFormat.format(timestamp),
              style: TextStyles.caption(context, isDarkMode: isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}
