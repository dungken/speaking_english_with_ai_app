import 'package:flutter/material.dart';

/// A reusable card widget with consistent styling
Widget buildCard(bool isDarkMode, {required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
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

/// A reusable recording button widget
Widget buildRecordButton({
  required bool isDarkMode, 
  required VoidCallback onTap,
  double size = 64,
  Color? color,
  IconData icon = Icons.mic,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? (isDarkMode ? Colors.blue[800] : Colors.blue[600]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.45,
      ),
    ),
  );
}

/// A reusable audio progress indicator
Widget buildAudioProgressBar({
  required bool isDarkMode,
  required double progress,
  required String duration,
}) {
  return Row(
    children: [
      Icon(
        Icons.play_arrow,
        size: 16,
        color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
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
                color: isDarkMode ? Colors.blue[600] : Colors.blue[500],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        duration,
        style: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
    ],
  );
}

/// A container for displaying text with colored background
Widget buildTextContainer({
  required bool isDarkMode,
  required String text,
  required Color backgroundColor,
  required Color borderColor,
  required Color textColor,
  EdgeInsets? padding,
}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: borderColor,
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
      ),
    ),
  );
}
