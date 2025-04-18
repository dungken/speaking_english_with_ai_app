import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A reusable card for displaying activities in a grid layout.
/// Each card has a consistent design language but can be customized
/// with different colors, icons, and content.
/// 
/// Implements responsive design that adapts to different screen sizes
/// and handles text overflow elegantly.
class ActivityCard extends StatelessWidget {
  final bool isDarkMode;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String footer;
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
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get appropriate sizing based on screen dimensions
    final screenType = ResponsiveLayout.getScreenType(context);
    
    // Adjust card padding based on screen size
    final cardPadding = screenType == ScreenType.extraSmall
        ? const EdgeInsets.fromLTRB(8, 12, 8, 0)
        : const EdgeInsets.fromLTRB(12, 16, 12, 0);
        
    // Adjust icon size based on screen type
    final iconContainerSize = screenType == ScreenType.extraSmall ? 40.0 :
                            screenType == ScreenType.small ? 45.0 : 50.0;
                            
    // Adjust text sizes based on screen dimensions
    final titleSize = screenType == ScreenType.extraSmall ? 14.0 :
                    screenType == ScreenType.small ? 15.0 : 16.0;
                    
    final subtitleSize = screenType == ScreenType.extraSmall ? 10.0 :
                        screenType == ScreenType.small ? 11.0 : 12.0;
    
    return Material(
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: cardPadding,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Ensure icon container size doesn't exceed available width
                      final availableWidth = constraints.maxWidth;
                      final adjustedIconSize = availableWidth < 100 
                          ? availableWidth * 0.4 
                          : iconContainerSize;
                          
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container with shadow
                          Container(
                            width: adjustedIconSize,
                            height: adjustedIconSize,
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
                              size: adjustedIconSize * 0.45,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.08),
                          
                          // Title with error prevention
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.getTextColor(isDarkMode),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          SizedBox(height: constraints.maxHeight * 0.04),
                          
                          // Subtitle with flexible height
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
              
              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.backgroundDark.withOpacity(0.5) 
                      : AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: isDarkMode 
                          ? iconColor.withOpacity(0.7) 
                          : iconColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        footer,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode 
                              ? iconColor.withOpacity(0.7) 
                              : iconColor.withOpacity(0.8),
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
    );
  }
}
