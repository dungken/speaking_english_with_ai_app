import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/shared_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 2 seconds and then navigate to the appropriate screen
    Future.delayed(const Duration(seconds: 2), () {
      // If onboarding is enabled, show OnboardingScreen, otherwise go to LoginScreen
      final showOnboarding = SharedPrefs.showOnboarding;
      Get.offNamed(showOnboarding ? AppRoutes.onboarding : AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.white,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon with Animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.blue,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms)
                  .then()
                  .shake(duration: 400.ms),

              const SizedBox(height: 24),

              // App Name with Animation
              Text(
                'Speaking English\nWith AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Practice English with AI',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),

              // Loading Indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
