import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/platform_checker.dart';
import '../../../utils/ui_config.dart';
import '../../widgets/wrapper/surface_view_wrapper.dart';

class MicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onRecordingStarted;
  final VoidCallback onRecordingStopped;
  final Duration maxDuration;
  final bool pulseAnimation;
  final bool visualizeMicInput;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  const MicButton({
    Key? key,
    required this.isRecording,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    this.maxDuration = const Duration(seconds: 30),
    this.pulseAnimation = true,
    this.visualizeMicInput = true,
    this.size,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size ?? UIConfig.getMicButtonSize(context);
    final activeColor = widget.activeColor ?? AppColors.error;
    final inactiveColor = widget.inactiveColor ?? AppColors.primary;

    Widget micButtonContent =
        _buildMicButtonContent(buttonSize, activeColor, inactiveColor);

    // Wrap with SurfaceViewWrapper only on Android and when recording
    if (PlatformChecker.isAndroid && widget.isRecording) {
      return SurfaceViewWrapper(
        isActiveMedia: true,
        child: micButtonContent,
      );
    }

    return micButtonContent;
  }

  Widget _buildMicButtonContent(
      double buttonSize, Color activeColor, Color inactiveColor) {
    return Semantics(
      button: true,
      enabled: true,
      label: widget.isRecording ? 'Stop recording' : 'Start recording',
      child: GestureDetector(
        onTap: () {
          if (widget.isRecording) {
            widget.onRecordingStopped();
          } else {
            widget.onRecordingStarted();
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isRecording && widget.pulseAnimation
                  ? _scaleAnimation.value
                  : 1.0,
              child: RepaintBoundary(
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isRecording ? activeColor : inactiveColor,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (widget.isRecording ? activeColor : inactiveColor)
                                .withOpacity(0.3),
                        blurRadius: widget.isRecording ? 16 : 8,
                        spreadRadius: widget.isRecording ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: buttonSize *
                        0.4, // Icon size proportional to button size
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
