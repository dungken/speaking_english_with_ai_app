import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// A standardized text field component following the SpeakBetter design system
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool enabled;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function()? onEditingComplete;
  final EdgeInsetsGeometry contentPadding;

  const AppTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(8.0);
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      validator: validator,
      style: TextStyles.body(context, isDarkMode: isDarkMode),
      decoration: InputDecoration(
        contentPadding: contentPadding,
        hintText: hintText,
        labelText: labelText,
        hintStyle: TextStyles.secondary(context, isDarkMode: isDarkMode).copyWith(
          color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.7),
        ),
        labelStyle: TextStyles.secondary(context, isDarkMode: isDarkMode),
        filled: true,
        fillColor: AppColors.getSurfaceColor(isDarkMode),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.3),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.3),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyles.caption(context, isDarkMode: isDarkMode).copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}
