import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../../domain/models/onboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // PageController to manage page transitions
  final PageController _controller = PageController();

  // List of onboarding screens
  final List<Onboard> _onboardingList = [
    Onboard(
      title: '🎤 Practice Speaking',
      subtitle:
          'Improve your English speaking skills with AI-powered conversations and instant feedback',
      icon: Icons.mic,
      color: Colors.blue,
    ),
    Onboard(
      title: '📚 Learn Naturally',
      subtitle:
          'Engage in real conversations, learn new vocabulary, and perfect your pronunciation',
      icon: Icons.school,
      color: Colors.purple,
    ),
    Onboard(
      title: '📊 Track Progress',
      subtitle:
          'Monitor your improvement with detailed feedback and personalized learning paths',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    // Set onboarding as completed
    await SharedPrefs.setShowOnboarding(false);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
        child: PageView.builder(
          controller: _controller,
          itemCount: _onboardingList.length,
          itemBuilder: (ctx, index) {
            final isLastPage = index == _onboardingList.length - 1;
            final onboard = _onboardingList[index];

            return Column(
              children: [
                const Spacer(flex: 1),

                // Icon with Animation
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
                  child: Icon(
                    onboard.icon,
                    size: 80,
                    color: onboard.color,
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms)
                    .then()
                    .shake(duration: 400.ms),

                const SizedBox(height: 32),

                // Title
                Text(
                  onboard.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onboard.color,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                // Subtitle
                SizedBox(
                  width: size.width * 0.8,
                  child: Text(
                    onboard.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingList.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            i == index ? onboard.color : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 32),

                // Next/Finish Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 32),
                      backgroundColor: onboard.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isLastPage) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward, size: 24),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms).scale(delay: 1000.ms),

                const Spacer(flex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
