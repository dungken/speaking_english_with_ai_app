import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/ui_config.dart';

class AppCard extends StatelessWidget {
  final Widget? icon;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;
  final double? elevation;
  final bool animate;
  final BorderRadius? borderRadius;
  
  const AppCard({
    Key? key,
    this.icon,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.padding,
    this.elevation,
    this.animate = true,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardWidget = Card(
      elevation: elevation ?? UIConfig.cardElevation,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(UIConfig.cardBorderRadius),
      ),
      color: AppColors.getSurfaceColor(isDarkMode),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(UIConfig.cardBorderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(ResponsiveLayout.getCardPadding(context)),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: icon,
                ),
                SizedBox(width: ResponsiveLayout.getElementSpacing(context) * 2),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.h3(context, isDarkMode: isDarkMode),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyles.secondary(context, isDarkMode: isDarkMode),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) 
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: UIConfig.smallIcon,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
            ],
          ),
        ),
      ),
    );
    
    // Apply animations conditionally
    if (animate) {
      return cardWidget
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
    }
    
    return cardWidget;
  }
}
