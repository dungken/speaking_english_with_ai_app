import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

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
      color: Colors.blue
          .withOpacity(.2), // 🎨 Light blue transparent card background
      elevation: 0, // 🌫️ No shadow for a flat look
      margin: EdgeInsets.only(
          bottom: mq.height * .02), // 📏 Adds spacing below each card
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(20)), // 🔵 Rounded card corners
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(
            Radius.circular(20)), // ✋ Ripple effect within rounded area
        onTap: homeType.onTap, // 🎯 Navigate or perform action on tap

        // 🔄 Conditional Layout: Left-aligned or Right-aligned content
        child: homeType.leftAlign
            ? Row(
                children: [
                  // 🎞️ Lottie Animation
                  Container(
                    width: mq.width * .35, // 📏 Set animation width
                    padding: homeType.padding, // 🏞️ Custom padding
                    child: Lottie.asset('assets/lottie/${homeType.lottie}'),
                  ),

                  const Spacer(), // 📏 Adds spacing

                  // 📝 Title Text
                  Text(
                    homeType.title,
                    style: const TextStyle(
                      fontSize: 18, // 🔠 Readable font size
                      fontWeight: FontWeight.w500, // 🔤 Medium weight
                      letterSpacing: 1, // 🔡 Improves text appearance
                    ),
                  ),

                  const Spacer(flex: 2), // 📏 Extra spacing
                ],
              )
            : Row(
                children: [
                  const Spacer(flex: 2), // 📏 Extra spacing

                  // 📝 Title Text (Right-Aligned)
                  Text(
                    homeType.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const Spacer(), // 📏 Adds spacing

                  // 🎞️ Lottie Animation
                  Container(
                    width: mq.width * .35,
                    padding: homeType.padding,
                    child: Lottie.asset('assets/lottie/${homeType.lottie}'),
                  ),
                ],
              ),
      ),
    ).animate().fade(
        duration: 1.seconds,
        curve: Curves.easeIn); // ✨ Smooth fade-in animation
  }
}
