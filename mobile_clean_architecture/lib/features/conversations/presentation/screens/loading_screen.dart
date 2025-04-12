import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),

            // Main content
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating elements
                  _buildFloatingElement('A', -120, -80, 0.8),
                  _buildFloatingElement('B', 140, -100, 0.7),
                  _buildFloatingElement('✏️', -100, 50, 0.9),
                  _buildFloatingElement('📚', 120, 80, 0.6),
                  _buildFloatingElement('✈️', -80, -120, 0.5),
                  _buildFloatingElement('☁️', 100, -50, 0.3),

                  // Main illustration and text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: Image.asset(
                          'assets/images/reading_illustration.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Đang tạo tình huống của bạn...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress indicator
            const Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(
      String element, double offsetX, double offsetY, double speed) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final sineValue = math.sin(value * 2 * math.pi * speed);

        return Transform.translate(
          offset: Offset(
            offsetX,
            offsetY + (sineValue * 15), // Vertical floating motion
          ),
          child: Text(
            element,
            style: const TextStyle(fontSize: 24),
          ),
        );
      },
    );
  }
}
