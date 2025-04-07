import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/home_type.dart';

class HomeCard extends StatelessWidget {
  final HomeType type;
  final int index;

  const HomeCard({
    super.key,
    required this.type,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDarkMode ? 2 : 1,
      shadowColor: isDarkMode
          ? Colors.black.withOpacity(0.3)
          : type.color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: type.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      type.color.withOpacity(0.1),
                      type.color.withOpacity(0.05),
                    ]
                  : [
                      Colors.white,
                      type.color.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode
                ? null
                : Border.all(
                    color: type.color.withOpacity(0.1),
                    width: 1,
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? type.color.withOpacity(0.1)
                      : type.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type.icon,
                  size: 28,
                  color: type.color,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                type.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? type.color : type.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                type.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
  }
}
