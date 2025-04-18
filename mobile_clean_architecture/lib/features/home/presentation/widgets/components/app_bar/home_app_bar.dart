import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_colors.dart';

/// A custom app bar specifically designed for the home screen.
/// Implements PreferredSizeWidget to function as an AppBar.
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
    return AppBar(
      title: const Text(
        'SpeakBetter',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      elevation: 0,
      backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
      actions: [
        // Theme toggle
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
          ),
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: onThemeToggle,
        ),
        
        // Settings button
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
        
        // Profile button
        IconButton(
          icon: const Icon(Icons.person_rounded, color: Colors.white),
          tooltip: 'Your profile',
          onPressed: () => context.push('/profile'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
