import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/responsive_layout.dart';

/// A custom app bar specifically designed for the home screen.
/// 
/// Features a contextually adaptive layout that adjusts based on screen size:
/// - Compact mode: Streamlined UI for smaller screens
/// - Full mode: Complete action set for larger screens
/// 
/// Implements accessibility features including proper contrast ratios,
/// semantic labels, and appropriate touch target sizes.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomeAppBar({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveLayout.getScreenType(context);
    final isCompactScreen = screenType == ScreenType.extraSmall || 
                           screenType == ScreenType.small;
    
    // Adjust elevation based on screen type for proper visual hierarchy
    final elevation = screenType == ScreenType.tablet ? 2.0 : 0.0;
    
    // Adapt title font size based on screen dimensions
    final titleSize = isCompactScreen ? 20.0 : 22.0;
    
    return AppBar(
      title: Row(
        children: [
          // App logo/icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          
          // App title with adaptive size
          Text(
            'SpeakBetter',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      elevation: elevation,
      backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
      actions: [
        // Streak counter with visual indicator
        if (!isCompactScreen) _buildStreakIndicator(),
        
        // Theme toggle button
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
            semanticLabel: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          ),
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: onThemeToggle,
        ),
        
        // Overflow menu for compact screens
        if (isCompactScreen)
          _buildOverflowMenu(context)
        else
          ...[
            // Notification button
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
            
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
            ),
            
            // Profile button with avatar
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: Tooltip(
                  message: 'Your profile',
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
      ],
    );
  }

  /// Builds the streak indicator with visual feedback
  Widget _buildStreakIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.streakPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.streakPrimary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColors.streakPrimary,
          ),
          const SizedBox(width: 4),
          const Text(
            '5 days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the overflow menu for compact screens
  Widget _buildOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      tooltip: 'More options',
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.push('/profile');
            break;
          case 'settings':
            context.push('/settings');
            break;
          case 'notifications':
            context.push('/notifications');
            break;
          case 'help':
            context.push('/help');
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          value: 'profile',
          icon: Icons.person_outline_rounded,
          text: 'Your Profile',
        ),
        _buildPopupMenuItem(
          value: 'notifications',
          icon: Icons.notifications_outlined,
          text: 'Notifications',
          showBadge: true,
        ),
        _buildPopupMenuItem(
          value: 'settings',
          icon: Icons.settings_outlined,
          text: 'Settings',
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          value: 'help',
          icon: Icons.help_outline_rounded,
          text: 'Help & Support',
        ),
      ],
    );
  }

  /// Helper to build consistent popup menu items
  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    bool showBadge = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          showBadge
              ? Stack(
                  children: [
                    Icon(icon, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 6,
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(icon, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
