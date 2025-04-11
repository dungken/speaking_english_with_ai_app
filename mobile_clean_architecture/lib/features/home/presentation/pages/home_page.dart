import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/home_type.dart';
import '../widgets/home_card.dart';
import '../widgets/user_profile_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Enable Fullscreen Edge-to-Edge UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _loadThemePreference();
  }

  void _loadThemePreference() {
    // TODO: Load theme preference from shared preferences
    setState(() {
      _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // TODO: Save theme preference to shared preferences

    // Update the app theme
    if (_isDarkMode) {
      ThemeMode.dark;
    } else {
      ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: _toggleTheme,
            icon: Icon(
              _isDarkMode
                  ? Icons.brightness_2_rounded
                  : Icons.brightness_5_rounded,
              size: 26,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.purple.shade900.withOpacity(0.3)
                  : Colors.purple.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .04,
            vertical: MediaQuery.of(context).size.height * .015,
          ),
          children: [
            // User Profile Card
            const UserProfileCard()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Learning Tools Section
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Learning Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

            // Menu Items
            ...HomeType.values.map((e) => HomeCard(homeType: e)),
          ],
        ),
      ),
    );
  }
}
