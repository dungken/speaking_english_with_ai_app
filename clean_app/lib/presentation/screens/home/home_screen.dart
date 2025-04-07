import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/utils/shared_prefs.dart';
import '../../../domain/models/home_type.dart';
import '../../widgets/home_card.dart';
import '../../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock user data - replace with actual user data from your backend
  final String _userName = "John Doe";
  final String _userEmail = "john.doe@example.com";
  final String _userAvatar =
      "https://ui-avatars.com/api/?name=John+Doe&background=0D8ABC&color=fff";

  @override
  void initState() {
    super.initState();

    // Enable Fullscreen Edge-to-Edge UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Disable Onboarding for Future Launches
    SharedPrefs.setShowOnboarding(false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: const Text('Speaking English with AI'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [
          ThemeToggleButton(),
        ],
      ),

      // Main Body
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : const Color(0xFFEFF6FF), // Light blue background
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900.withOpacity(0.3)
                  : const Color(0xFFF5F3FF), // Light purple background
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * .04,
            vertical: size.height * .015,
          ),
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(_userAvatar),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.blue.shade50,
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit Profile Button
                  IconButton(
                    onPressed: () {
                      // Navigate to profile screen
                      HomeType.profile.onTap();
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.shade700
                          : const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Progress Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem(
                        icon: Icons.timer,
                        value: '2.5h',
                        label: 'Practice Time',
                      ),
                      _buildProgressItem(
                        icon: Icons.star,
                        value: '85%',
                        label: 'Accuracy',
                      ),
                      _buildProgressItem(
                        icon: Icons.emoji_events,
                        value: '12',
                        label: 'Achievements',
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Features Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                HomeCard(
                  type: HomeType.topicSelection,
                  index: 0,
                ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0),
                HomeCard(
                  type: HomeType.imageDescription,
                  index: 1,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                HomeCard(
                  type: HomeType.rolePlay,
                  index: 2,
                ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0),
                HomeCard(
                  type: HomeType.translator,
                  index: 3,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade700.withOpacity(0.2)
                : const Color(0xFF3B82F6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade700
                : const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
