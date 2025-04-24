import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/platform_checker.dart';
import '../../../utils/rendering/surface_view_optimizer.dart';
import '../../../utils/ui_config.dart';
import '../../widgets/wrapper/surface_view_wrapper.dart';
import '../buttons/mic_button.dart';

class VoiceInput extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onRecordingStarted;
  final VoidCallback onRecordingStopped;
  final Duration maxDuration;
  final String? placeholder;
  final String? recordedText;
  final bool showWaveform;
  final bool enableTextEditing;
  final void Function(String)? onTextChanged;

  const VoiceInput({
    Key? key,
    required this.isRecording,
    required this.onRecordingStarted,
    required this.onRecordingStopped,
    this.maxDuration = const Duration(seconds: 30),
    this.placeholder,
    this.recordedText,
    this.showWaveform = true,
    this.enableTextEditing = false,
    this.onTextChanged,
  }) : super(key: key);

  @override
  State<VoiceInput> createState() => _VoiceInputState();
}

class _VoiceInputState extends State<VoiceInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _animationController;
  late Animation<double> _waveformAnimation;

  final List<double> _waveformBars = [];
  final int _waveformBarCount = 30;
  final double _maxBarHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recordedText);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _waveformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize waveform bars
    _generateRandomWaveform();

    if (widget.isRecording) {
      _animationController.repeat(reverse: true);
    }

    // Prepare the SurfaceView environment when recording begins
    if (widget.isRecording && PlatformChecker.isAndroid) {
      SurfaceViewOptimizer.prepareForSurfaceView();
    }
  }

  @override
  void didUpdateWidget(VoiceInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.recordedText != oldWidget.recordedText) {
      _textController.text = widget.recordedText ?? '';
    }

    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _animationController.repeat(reverse: true);
        _generateRandomWaveform();

        // Optimize for SurfaceView when recording starts
        if (PlatformChecker.isAndroid) {
          SurfaceViewOptimizer.prepareForSurfaceView();
        }
      } else {
        _animationController.stop();

        // Clean up SurfaceView optimizations when recording stops
        if (PlatformChecker.isAndroid) {
          SurfaceViewOptimizer.cleanupAfterSurfaceView();
        }
      }
    }
  }

  void _generateRandomWaveform() {
    _waveformBars.clear();
    for (int i = 0; i < _waveformBarCount; i++) {
      _waveformBars.add((0.3 +
          0.7 *
              (i % 3 == 0
                  ? 0.8
                  : i % 2 == 0
                      ? 0.5
                      : 0.3)));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();

    // Ensure we clean up any SurfaceView optimizations
    if (PlatformChecker.isAndroid) {
      SurfaceViewOptimizer.cleanupAfterSurfaceView();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // If we're on Android, wrap with SurfaceViewWrapper to prevent BLASTBufferQueue errors
    // otherwise just return the normal widget
    Widget voiceInputWidget = _buildVoiceInputContent(isDarkMode);

    if (!PlatformChecker.isAndroid) {
      return voiceInputWidget;
    }

    return SurfaceViewWrapper(
      isActiveMedia: widget.isRecording,
      child: voiceInputWidget,
    );
  }

  Widget _buildVoiceInputContent(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark.withOpacity(0.6)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: MediaQuery.of(context).size.height *
                0.5, // 50% of screen height
          ),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // This ensures the column only takes needed space
            children: [
              // Text display area
              Padding(
                padding: const EdgeInsets.all(16),
                child: widget.enableTextEditing
                    ? _buildTextEditor(isDarkMode)
                    : _buildTextDisplay(isDarkMode),
              ),

              // Waveform visualization (if enabled and recording)
              if (widget.showWaveform &&
                  (widget.isRecording || widget.recordedText != null)) ...[
                const Divider(height: 1),
                SizedBox(
                  height: 60,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return _buildWaveform(isDarkMode);
                    },
                  ),
                ),
              ],

              // Microphone control - wrapped with RepaintBoundary to optimize rendering
              RepaintBoundary(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: MicButton(
                      isRecording: widget.isRecording,
                      onRecordingStarted: widget.onRecordingStarted,
                      onRecordingStopped: widget.onRecordingStopped,
                      maxDuration: widget.maxDuration,
                      pulseAnimation: true,
                      visualizeMicInput: widget.showWaveform,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextDisplay(bool isDarkMode) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 60,
      ),
      child: Text(
        widget.recordedText ??
            widget.placeholder ??
            'Tap the microphone to start recording',
        style: TextStyles.body(
          context,
          isDarkMode: isDarkMode,
          color: widget.recordedText == null
              ? AppColors.getTextSecondaryColor(isDarkMode)
              : null,
        ),
      ),
    );
  }

  Widget _buildTextEditor(bool isDarkMode) {
    return TextField(
      controller: _textController,
      style: TextStyles.body(context, isDarkMode: isDarkMode),
      maxLines: null,
      decoration: InputDecoration(
        hintText: widget.placeholder ?? 'Tap the microphone to start recording',
        hintStyle: TextStyles.body(
          context,
          isDarkMode: isDarkMode,
          color: AppColors.getTextSecondaryColor(isDarkMode),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: widget.onTextChanged,
    );
  }

  Widget _buildWaveform(bool isDarkMode) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _waveformBarCount,
          (index) {
            // Calculate height based on position and animation
            double height = _waveformBars[index] * _maxBarHeight;
            if (widget.isRecording) {
              // Apply animation to make the bars move
              final animationOffset = (_waveformAnimation.value * 0.4) - 0.2;
              height *= (1 +
                  math.sin(index + _animationController.value * 10) *
                      animationOffset);
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: widget.isRecording
                    ? AppColors.error
                    : AppColors.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          },
        ),
      ),
    );
  }
}
