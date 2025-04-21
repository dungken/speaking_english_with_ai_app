import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool hasBorder;

  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.tooltip,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBackgroundColor =
        backgroundColor ?? (isDarkMode ? Colors.grey[800] : Colors.grey[200]);
    final defaultIconColor =
        iconColor ?? (isDarkMode ? Colors.white : AppColors.textPrimaryLight);

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: defaultBackgroundColor,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  )
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: defaultIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
