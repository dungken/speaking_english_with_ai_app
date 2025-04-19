import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A reusable card for displaying activities in a grid layout.
/// 
/// This component implements atomic design principles by serving as a 
/// self-contained UI element with consistent styling while supporting
/// customization through props. Card layout adapts to different screen
/// sizes and orientations through responsive design techniques.
/// 
/// Key features:
/// - Adaptive sizing based on available screen real estate
/// - Consistent visual hierarchy across different content types
/// - Robust overflow handling for varying text lengths
/// - Semantic touch feedback with appropriate states
/// - Scalable icon system with custom color theming
class ActivityCard extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String footer;
  final IconData? footerIcon;
  final bool footerHighlight;
  final VoidCallback onTap;

  const ActivityCard({
    Key? key,
    required this.isDarkMode,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.footer,
    this.footerIcon,
    this.footerHighlight = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get appropriate sizing based on screen dimensions
    final screenType = ResponsiveLayout.getScreenType(context);
    
    // Adjust card padding based on screen size for proper content density
    final cardPadding = screenType == ScreenType.extraSmall
        ? const EdgeInsets.fromLTRB(10, 14, 10, 0)
        : const EdgeInsets.fromLTRB(16, 20, 16, 0);
        
    // Adjust text sizes based on screen dimensions for optimal readability
    final titleSize = screenType == ScreenType.extraSmall ? 14.0 :
                    screenType == ScreenType.small ? 15.0 : 16.0;
                    
    final subtitleSize = screenType == ScreenType.extraSmall ? 11.0 :
                        screenType == ScreenType.small ? 12.0 : 13.0;
    
    return Semantics(
      button: true,
      label: '$title activity',
      hint: subtitle,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(isDarkMode),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: cardPadding,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate appropriate icon size based on available space
                        final contentWidth = constraints.maxWidth;
                        final contentHeight = constraints.maxHeight;
                        final availableIconSpace = contentHeight * 0.5;
                        
                        // Adjust icon container size based on available space
                        final calculatedIconSize = contentWidth < 100 
                            ? contentWidth * 0.4 
                            : availableIconSpace;
                            
                        // Limit icon size to reasonable bounds
                        final iconContainerSize = calculatedIconSize.clamp(36.0, 60.0);
                            
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon container with contextual emphasis
                            Container(
                              width: iconContainerSize,
                              height: iconContainerSize,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: iconContainerSize * 0.45,
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.08),
                            
                            // Title with dynamic sizing
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: AppColors.getTextColor(isDarkMode),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: constraints.maxHeight * 0.04),
                            
                            // Subtitle with adaptive layout
                            Flexible(
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  height: 1.3,
                                  color: AppColors.getSecondaryTextColor(isDarkMode),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                // Footer with optional highlight state
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: footerHighlight 
                        ? (isDarkMode ? iconColor.withOpacity(0.15) : iconColor.withOpacity(0.1))
                        : (isDarkMode ? AppColors.backgroundDark.withOpacity(0.5) : AppColors.primary.withOpacity(0.05)),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        footerIcon ?? Icons.info_outline_rounded,
                        size: 12,
                        color: footerHighlight
                            ? iconColor
                            : (isDarkMode ? iconColor.withOpacity(0.7) : iconColor.withOpacity(0.8)),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          footer,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: footerHighlight
                                ? iconColor
                                : (isDarkMode ? iconColor.withOpacity(0.7) : iconColor.withOpacity(0.8)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
