import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeController = Get.find<ThemeController>();

    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: isDarkMode ? Colors.tealAccent : const Color(0xFF3B82F6),
          size: 22,
        ),
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        onPressed: () {
          themeController.toggleTheme();
        },
      ),
    );
  }
}
