import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

/// A reusable card widget with consistent styling
Widget buildCard(BuildContext context, bool isDarkMode,
    {required Widget child}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
    decoration: BoxDecoration(
      color: AppColors.getSurfaceColor(isDarkMode),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

/// A reusable recording button widget with pulsing animation
Widget buildRecordButton({
  required BuildContext context,
  required bool isDarkMode,
  required VoidCallback onTap,
  double size = 64,
  Color? color,
  IconData icon = Icons.mic,
}) {
  return StatefulBuilder(builder: (context, setState) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.getPrimaryGradient(isDarkMode),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse animation container
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Container(
                    width: size * 1.15 * value,
                    height: size * 1.15 * value,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2 * (1.2 - value)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
                onEnd: () => setState(() {}), // Restart animation
              ),
              Icon(
                icon,
                color: Colors.white,
                size: size * 0.45,
              ),
            ],
          ),
        ),
      ),
    );
  });
}

/// A reusable audio progress indicator
Widget buildAudioProgressBar({
  required BuildContext context,
  required bool isDarkMode,
  required double progress,
  required String duration,
}) {
  return Row(
    children: [
      Icon(
        Icons.play_arrow,
        size: 16,
        color: AppColors.primary,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[700]!.withAlpha(255)
                : Colors.grey[200]!.withAlpha(255),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        duration,
        style: TextStyles.caption(
          context,
          isDarkMode: isDarkMode,
          color: AppColors.getTextSecondaryColor(isDarkMode),
        ),
      ),
    ],
  );
}

/// A container for displaying text with colored background
Widget buildTextContainer({
  required BuildContext context,
  required bool isDarkMode,
  required String text,
  required Color backgroundColor,
  required Color borderColor,
  required Color textColor,
  EdgeInsets? padding,
}) {
  return Container(
    padding: padding ??
        EdgeInsets.all(ResponsiveLayout.getElementSpacing(context) * 2),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: borderColor,
      ),
    ),
    child: Text(
      text,
      style: TextStyles.body(
        context,
        isDarkMode: isDarkMode,
        color: textColor,
      ),
    ),
  );
}
