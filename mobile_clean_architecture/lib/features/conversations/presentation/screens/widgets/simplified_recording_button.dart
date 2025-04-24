import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

/// A simplified recording button that uses minimal animations to prevent
/// BLASTBufferQueue errors on Android devices.
///
/// Instead of continuous pulse animation, it uses:
/// - Static visual state changes
/// - Simple color transitions
/// - Minimal UI updates during recording
class SimplifiedRecordingButton extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onRecordingStarted;
  final VoidCallback onRecordingStopped;
  final VoidCallback onRecordingCancelled;

  const SimplifiedRecordingButton({
    Key? key,
    required this.isRecording,
    required this.isProcessing,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    required this.onRecordingCancelled,
  }) : super(key: key);

  @override
  State<SimplifiedRecordingButton> createState() =>
      _SimplifiedRecordingButtonState();
}

class _SimplifiedRecordingButtonState extends State<SimplifiedRecordingButton> {
  int _recordingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isRecording) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimplifiedRecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startTimer();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _recordingSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isProcessing) {
      return _buildProcessingButton();
    } else if (widget.isRecording) {
      return _buildActiveRecordingButton();
    } else {
      return _buildIdleButton();
    }
  }

  Widget _buildIdleButton() {
    return Column(
      children: [
        Text(
          'Tap to speak',
          style: TextStyles.secondary(context),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.onRecordingStarted,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.mic,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRecordingButton() {
    return Column(
      children: [
        // Recording timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple recording indicator (static red dot)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(),
                style: TextStyles.body(context, color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel button
            InkWell(
              onTap: widget.onRecordingCancelled,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Stop recording button (static red button, no animation)
            InkWell(
              onTap: widget.onRecordingStopped,
              customBorder: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: Border.all(
                    color: Colors.red.shade700,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessingButton() {
    return Column(
      children: [
        Text(
          'Processing...',
          style: TextStyles.secondary(context),
        ),
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade100,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
