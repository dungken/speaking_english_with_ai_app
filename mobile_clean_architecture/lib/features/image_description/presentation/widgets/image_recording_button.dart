import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_layout.dart';

/// Recording button for image description feature
///
/// Provides a clean recording interface with three states:
/// - Idle: Ready to start recording
/// - Recording: Active recording with timer
/// - Processing: Uploading and transcribing audio
class ImageRecordingButton extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onRecordingStarted;
  final VoidCallback onRecordingStopped;
  final VoidCallback onRecordingCancelled;

  const ImageRecordingButton({
    Key? key,
    required this.isRecording,
    required this.isProcessing,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    required this.onRecordingCancelled,
  }) : super(key: key);

  @override
  State<ImageRecordingButton> createState() => _ImageRecordingButtonState();
}

class _ImageRecordingButtonState extends State<ImageRecordingButton> {
  int _recordingSeconds = 0;
  Timer? _timer;

  // Responsive sizing
  double get _containerHeight =>
      ResponsiveLayout.isLargeScreen(context) ? 160.0 : 140.0;
  double get _buttonSize =>
      ResponsiveLayout.isLargeScreen(context) ? 72.0 : 64.0;
  double get _smallButtonSize =>
      ResponsiveLayout.isLargeScreen(context) ? 56.0 : 48.0;

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
  void didUpdateWidget(ImageRecordingButton oldWidget) {
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
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _recordingSeconds = 0;
  }

  String _formatDuration() {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: _containerHeight,
        alignment: Alignment.center,
        child: IndexedStack(
          index: widget.isProcessing
              ? 2
              : widget.isRecording
                  ? 1
                  : 0,
          children: [
            _buildIdleButton(),
            _buildActiveRecordingButton(),
            _buildProcessingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleButton() {
    return Container(
      key: const ValueKey('idle'),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
          Text(
            'Tap to describe the image',
            style: TextStyles.secondary(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          InkWell(
            onTap: widget.onRecordingStarted,
            customBorder: const CircleBorder(),
            child: Container(
              width: _buttonSize,
              height: _buttonSize,
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
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.mic,
                  color: AppColors.primary,
                  size: _buttonSize * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRecordingButton() {
    return Container(
      key: const ValueKey('recording'),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Recording timer
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.getCardPadding(context),
              vertical: ResponsiveLayout.getElementSpacing(context),
            ),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recording indicator (static red dot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getElementSpacing(context)),
                Text(
                  _formatDuration(),
                  style: TextStyles.body(context, color: Colors.red)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          // Recording controls
          SizedBox(
            width: _buttonSize +
                _smallButtonSize +
                ResponsiveLayout.getElementSpacing(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel button
                SizedBox(
                  width: _smallButtonSize,
                  height: _smallButtonSize,
                  child: InkWell(
                    onTap: widget.onRecordingCancelled,
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: _smallButtonSize * 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveLayout.getElementSpacing(context)),
                // Stop recording button
                SizedBox(
                  width: _buttonSize,
                  height: _buttonSize,
                  child: InkWell(
                    onTap: widget.onRecordingStopped,
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        border: Border.all(
                          color: Colors.red.shade700,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.stop,
                          color: Colors.white,
                          size: _buttonSize * 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingButton() {
    return Container(
      key: const ValueKey('processing'),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: ResponsiveLayout.getSectionSpacing(context)),
          Text(
            'Processing your description...',
            style: TextStyles.secondary(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveLayout.getElementSpacing(context)),
          Container(
            width: _buttonSize,
            height: _buttonSize,
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
                width: _buttonSize * 0.4,
                height: _buttonSize * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
