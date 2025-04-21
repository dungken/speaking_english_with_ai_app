import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

/// A button for recording audio in conversations
///
/// Shows different states for idle, recording, and processing
class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onRecordingStarted;
  final VoidCallback onRecordingStopped;
  final VoidCallback onRecordingCancelled;

  const RecordingButton({
    Key? key,
    required this.isRecording,
    required this.isProcessing,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    required this.onRecordingCancelled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return _buildProcessingState(context);
    }

    if (isRecording) {
      return _buildRecordingState(context);
    }

    return _buildIdleState(context);
  }

  Widget _buildIdleState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tap the microphone to respond',
          style: TextStyles.secondary(context),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onRecordingStarted,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Recording... Tap to stop',
          style: TextStyles.secondary(context),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: onRecordingCancelled,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 24),
            InkWell(
              onTap: onRecordingStopped,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 28,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).fadeOut(
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ).then().fadeIn(
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Processing your response...',
          style: TextStyles.secondary(context),
        ),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
