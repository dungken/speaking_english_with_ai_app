import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

class RecordingIndicator extends StatefulWidget {
  final VoidCallback onCancel;

  const RecordingIndicator({
    Key? key,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _recordingDuration = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust number of wave bars based on screen width
    final numWaveBars = math.max(7, (screenWidth / 30).floor());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio visualization with responsive sizing
        SizedBox(
          height: ResponsiveLayout.getSectionSpacing(context) * 2,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  numWaveBars,
                  (index) {
                    // Create random but consistent heights based on animation and index
                    final height = 8.0 +
                        ResponsiveLayout.getElementSpacing(context) *
                            2 *
                            math.sin(
                                (_animationController.value * math.pi * 2) +
                                    (index * 0.2));

                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveLayout.getElementSpacing(context) / 4,
                      ),
                      width: 3,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Recording time and status
        Text(
          _formatDuration(_recordingDuration),
          style: TextStyles.h2(context, isDarkMode: isDarkMode),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Recording...',
              style: TextStyles.body(context, isDarkMode: isDarkMode),
            ),
          ],
        ),
        SizedBox(height: ResponsiveLayout.getElementSpacing(context) * 2),

        // Control buttons with responsive layout
        Wrap(
          alignment: WrapAlignment.center,
          spacing: ResponsiveLayout.getElementSpacing(context) * 2,
          runSpacing: ResponsiveLayout.getElementSpacing(context),
          children: [
            ElevatedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.getCardPadding(context),
                  vertical: ResponsiveLayout.getElementSpacing(context),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget
                  .onCancel, // Same as cancel for now - in real app would be different
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.getCardPadding(context),
                  vertical: ResponsiveLayout.getElementSpacing(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
