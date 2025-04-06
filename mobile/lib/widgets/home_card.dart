import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../helper/global.dart';
import '../model/home_type.dart';

class HomeCard extends StatelessWidget {
  final HomeType homeType;

  const HomeCard({super.key, required this.homeType});

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload =
        true; // 🔄 Ensures animations reload on hot restart

    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.withOpacity(.1) // 🎨 Dark mode card background
          : Colors.white, // 🎨 Light mode card background
      elevation: 2, // 🌫️ Subtle shadow for depth
      margin: EdgeInsets.only(
          bottom: mq.height * .02), // 📏 Adds spacing below each card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 🔵 Rounded card corners
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16), // ✋ Ripple effect within rounded area
        onTap: homeType.onTap, // 🎯 Navigate or perform action on tap
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 🎨 Icon Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  homeType.icon,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // 📝 Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homeType.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDescription(homeType),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ➡️ Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(
        duration: 1.seconds,
        curve: Curves.easeIn); // ✨ Smooth fade-in animation
  }

  // 📝 Get description for each menu item
  String _getDescription(HomeType type) => switch (type) {
        HomeType.createSituations =>
          'Practice conversations in different scenarios',
        HomeType.chooseTopic => 'Select topics to improve your English skills',
        HomeType.describeImage => 'Describe images to enhance vocabulary',
        HomeType.progressTracking =>
          'Track your learning progress and achievements',
        HomeType.settings => 'Customize app settings and preferences',
        HomeType.profile => 'View and edit your profile information',
      };
}
