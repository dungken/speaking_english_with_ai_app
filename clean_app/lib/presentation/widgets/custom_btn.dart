import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final String text; // 📝 Button text
  final VoidCallback onTap; // 🎯 Callback function for button press

  const CustomBtn({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      // 📌 Centering the button
      alignment: Alignment.center,

      // 🔘 Elevated Button with custom styling
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(), // 🎨 Rounded stadium shape
          elevation: 0, // ✨ No shadow for a clean design
          backgroundColor:
              Theme.of(context).primaryColor, // 🎨 Theme-based color
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500), // 🔠 Font styling
          minimumSize: Size(MediaQuery.of(context).size.width * .4,
              50), // 📏 Button size (responsive)
        ),

        // 🚀 On button press action
        onPressed: onTap,

        // 🏷️ Display button text
        child: Text(text),
      ),
    );
  }
}
