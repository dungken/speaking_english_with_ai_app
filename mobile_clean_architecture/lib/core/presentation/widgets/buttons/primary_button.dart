import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/ui_config.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  
  const PrimaryButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 48.0,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: UIConfig.buttonElevation,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConfig.buttonBorderRadius),
          ),
          minimumSize: Size(isFullWidth ? double.infinity : 120, height),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.7),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Loading indicator (visible when isLoading is true)
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            
            // Button content (invisible when isLoading is true)
            Opacity(
              opacity: isLoading ? 0.0 : 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyles.button(context, isDarkMode: isDarkMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
