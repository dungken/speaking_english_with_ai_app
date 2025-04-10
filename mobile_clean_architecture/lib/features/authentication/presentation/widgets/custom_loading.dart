import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A custom loading animation widget for the application
class CustomLoading extends StatelessWidget {
  /// Creates a loading widget with a default size
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade100),
      ),
    );
  }
}

/// A full-page loading overlay
class FullPageLoading extends StatelessWidget {
  /// Creates a full-page loading overlay
  const FullPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 100,
          height: 100,
          frameRate: FrameRate.max,
        ),
      ),
    );
  }
}
