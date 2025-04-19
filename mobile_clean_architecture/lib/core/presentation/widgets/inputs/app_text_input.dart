import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/ui_config.dart';

class AppTextInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final Widget? prefix;
  final Widget? suffix;
  final bool autofocus;
  final bool enabled;
  final String? Function(String?)? validator;
  final EdgeInsets? contentPadding;
  
  const AppTextInput({
    Key? key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.prefix,
    this.suffix,
    this.autofocus = false,
    this.enabled = true,
    this.validator,
    this.contentPadding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(UIConfig.inputBorderRadius);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyles.secondary(context, isDarkMode: isDarkMode),
          ),
          const SizedBox(height: 8),
        ],
        
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          autofocus: autofocus,
          enabled: enabled,
          validator: validator,
          
          style: TextStyles.body(context, isDarkMode: isDarkMode),
          
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyles.body(
              context, 
              isDarkMode: isDarkMode,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ).copyWith(
              color: AppColors.getTextSecondaryColor(isDarkMode).withOpacity(0.7),
            ),
            
            errorText: errorText,
            errorStyle: TextStyles.caption(
              context,
              isDarkMode: isDarkMode,
              color: AppColors.error,
            ),
            
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            
            prefixIcon: prefix,
            suffixIcon: suffix,
            
            filled: true,
            fillColor: isDarkMode
                ? AppColors.surfaceDark.withOpacity(0.8)
                : Colors.white,
            
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: isDarkMode 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: isDarkMode 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
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
          ),
        ),
      ],
    );
  }
}
