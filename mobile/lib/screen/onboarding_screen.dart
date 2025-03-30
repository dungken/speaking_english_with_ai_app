import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../helper/global.dart';
import '../model/onboard.dart';
import '../widget/custom_btn.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 📄 PageController to manage page transitions
  final PageController _controller = PageController();

  // 📜 List of onboarding screens
  final List<Onboard> _onboardingList = [
    Onboard(
      title: '🤖 Ask me Anything',
      subtitle:
          'I can be your Best Friend & You can ask me anything & I will help you!',
      lottie: 'ai_ask_me',
    ),
    Onboard(
      title: '🎨 Imagination to Reality',
      subtitle:
          'Just Imagine anything & let me know, I will create something wonderful for you!',
      lottie: 'ai_play',
    ),
  ];

  @override
  void dispose() {
    // 🗑️ Dispose the PageController when not in use
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📜 PageView to display each onboarding screen
      body: PageView.builder(
        controller: _controller,
        itemCount: _onboardingList.length,
        itemBuilder: (ctx, index) {
          final isLastPage = index == _onboardingList.length - 1;

          return Column(
            children: [
              // 🎥 Display Lottie animation
              Lottie.asset(
                'assets/lottie/${_onboardingList[index].lottie}.json',
                height: mq.height * 0.6,
                width: isLastPage ? mq.width * 0.7 : null,
              ),

              // 📝 Onboarding title
              Text(
                _onboardingList[index].title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              // ➖ Adding some space
              SizedBox(height: mq.height * 0.015),

              // 📌 Onboarding subtitle
              SizedBox(
                width: mq.width * 0.7,
                child: Text(
                  _onboardingList[index].subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    letterSpacing: 0.5,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),

              const Spacer(),

              // 🔵 Indicator Dots for current page position
              Wrap(
                spacing: 10,
                children: List.generate(
                  _onboardingList.length,
                  (i) => Container(
                    width: i == index ? 15 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == index ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 🔘 "Next" or "Finish" button
              CustomBtn(
                onTap: () {
                  if (isLastPage) {
                    // 🏡 Navigate to HomeScreen if this is the last page
                    Get.offAll(() => const HomeScreen());
                  } else {
                    // ⏭️ Move to the next page
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.ease,
                    );
                  }
                },
                text: isLastPage ? '🎉 Finish' : '➡️ Next',
              ),

              const Spacer(flex: 2),
            ],
          );
        },
      ),
    );
  }
}
