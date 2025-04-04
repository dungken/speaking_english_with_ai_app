import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/global.dart';
import '../helper/pref.dart';
import '../widget/custom_loading.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏳ Wait for 2 seconds and then navigate to the appropriate screen
    Future.delayed(const Duration(seconds: 2), () {
      // 📌 If onboarding is enabled, show OnboardingScreen, otherwise go to LoginScreen
      Get.off(() =>
          Pref.showOnboarding ? const OnboardingScreen() : const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📏 Initialize device size for responsive UI
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      // 🎨 Background color (optional)
      backgroundColor: Colors.white,

      // 🖥️ Body of the splash screen
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            // ➖ Adding space at the top
            const Spacer(flex: 2),

            // 🏆 App Logo with Card effect
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(20)), // 🎨 Rounded edges
              ),
              elevation: 5, // 🌟 Adds a slight shadow for better UI
              child: Padding(
                padding: EdgeInsets.all(mq.width * .05),
                child: Image.asset(
                  'assets/images/logo.png', // 🖼️ App Logo
                  width: mq.width * .4, // 📏 Responsive sizing
                ),
              ),
            ),

            // ➖ Adding some space
            const Spacer(),

            // ⏳ Lottie Loading Animation
            const CustomLoading(), // 🎬 Smooth animated loading effect

            // ➖ Adding some space at the bottom
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
