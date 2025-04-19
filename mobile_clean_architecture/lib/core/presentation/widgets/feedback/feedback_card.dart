import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/ui_config.dart';

class FeedbackCard extends StatelessWidget {
  final String title;
  final String content;
  final FeedbackType type;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool isDismissible;
  final VoidCallback? onDismiss;
  
  const FeedbackCard({
    Key? key,
    required this.title,
    required this.content,
    this.type = FeedbackType.info,
    this.onActionPressed,
    this.actionLabel,
    this.isDismissible = false,
    this.onDismiss,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final card = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(UIConfig.cardBorderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and optional dismiss button
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveLayout.getCardPadding(context),
              right: ResponsiveLayout.getCardPadding(context),
              top: ResponsiveLayout.getCardPadding(context),
              bottom: 8,
            ),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: UIConfig.mediumIcon,
                ),
                SizedBox(width: ResponsiveLayout.getElementSpacing(context)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyles.h3(context, isDarkMode: isDarkMode, color: _getTextColor(isDarkMode)),
                  ),
                ),
                if (isDismissible)
                  IconButton(
                    icon: const Icon(Icons.close, size: UIConfig.smallIcon),
                    onPressed: onDismiss,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    color: _getTextColor(isDarkMode).withOpacity(0.6),
                  ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.getCardPadding(context),
            ),
            child: Text(
              content,
              style: TextStyles.body(context, isDarkMode: isDarkMode, color: _getTextColor(isDarkMode)),
            ),
          ),
          
          // Optional action button
          if (actionLabel != null && onActionPressed != null)
            Padding(
              padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: _getActionColor(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(UIConfig.buttonBorderRadius / 2),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: TextStyles.button(context, isDarkMode: isDarkMode, color: _getActionColor()),
                  ),
                ),
              ),
            )
          else
            SizedBox(height: ResponsiveLayout.getCardPadding(context)),
        ],
      ),
    );
    
    // If card is dismissible, wrap it with a dismissible widget
    if (isDismissible && onDismiss != null) {
      return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(UIConfig.cardBorderRadius),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: card,
      );
    }
    
    return card;
  }
  
  Color _getBackgroundColor(bool isDarkMode) {
    final baseColor = _getBaseColor();
    return isDarkMode 
        ? baseColor.withOpacity(0.15)
        : baseColor.withOpacity(0.08);
  }
  
  Color _getBorderColor() {
    return _getBaseColor().withOpacity(0.3);
  }
  
  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : Colors.black87;
  }
  
  Color _getIconColor() {
    return _getBaseColor();
  }
  
  Color _getActionColor() {
    return _getBaseColor();
  }
  
  Color _getBaseColor() {
    switch (type) {
      case FeedbackType.success:
        return AppColors.success;
      case FeedbackType.warning:
        return AppColors.warning;
      case FeedbackType.error:
        return AppColors.error;
      case FeedbackType.info:
      default:
        return AppColors.info;
    }
  }
  
  IconData _getIcon() {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle_outline;
      case FeedbackType.warning:
        return Icons.warning_amber_outlined;
      case FeedbackType.error:
        return Icons.error_outline;
      case FeedbackType.info:
      default:
        return Icons.info_outline;
    }
  }
}

enum FeedbackType {
  success,
  warning,
  error,
  info,
}
