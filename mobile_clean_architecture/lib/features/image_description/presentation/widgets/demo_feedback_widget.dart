import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';


class SimpleFeedbackWidget extends StatelessWidget {
  const SimpleFeedbackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your description',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'So basically what I see is that he\'s holding something really closely. So he\'s holding the tools which help him to look at the super details on something.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Corrected message',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'So basically, what I see is that he\'s holding something very closely. He\'s holding tools that help him look at the super details of something.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A comma is needed after "So basically" as an introductory phrase. "Very closely" is more appropriate than "really closely" for describing the manner of holding. "The tools" should be "tools" because it\'s not specified which tools exactly. "Which" should be changed to "that" to introduce a defining clause. The phrase "help him to look at" can be simplified to "help him look at." "Super details on something" should be "super details of something" to use the correct preposition.',
                  style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 