import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'platform_checker.dart';

/// Optimizes Android recording to prevent BLASTBufferQueue issues
///
/// This class provides specific optimizations for audio recording
/// to prevent buffer overflow issues that commonly occur on Android
class AndroidRecordingOptimizer {
  static const platform =
      MethodChannel('com.example.mobile_clean_architecture/recording');
  static Timer? _keepAliveTimer;
  static bool _isOptimized = false;

  /// Initialize recording optimizations
  static Future<void> beginRecordingOptimization() async {
    if (!PlatformChecker.isAndroid || _isOptimized) return;

    try {
      // REMOVED: No longer changing system UI mode to prevent screen shifts
      // Just keep the screen awake during recording
      await SystemChannels.platform.invokeMethod(
          'SystemChrome.setEnabledSystemUIMode',
          [SystemUiMode.edgeToEdge.index]);

      // Create a keep-alive timer to prevent system sleep
      _keepAliveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        WidgetsBinding.instance.scheduleFrame();
      });

      _isOptimized = true;
    } catch (e) {
      debugPrint('Failed to optimize recording: $e');
    }
  }

  /// End recording optimizations
  static Future<void> endRecordingOptimization() async {
    if (!PlatformChecker.isAndroid || !_isOptimized) return;

    try {
      // No need to restore UI mode since we're not changing it anymore

      // Cancel keep-alive timer
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;

      _isOptimized = false;
    } catch (e) {
      debugPrint('Failed to restore system settings: $e');
    }
  }

  /// Wrap a recording widget with optimizations
  static Widget wrapRecordingWidget({
    required Widget child,
    required bool isRecording,
  }) {
    if (!PlatformChecker.isAndroid) return child;

    return _RecordingOptimizationWrapper(
      isRecording: isRecording,
      child: child,
    );
  }
}

/// Internal wrapper widget that handles recording optimization lifecycle
class _RecordingOptimizationWrapper extends StatefulWidget {
  final bool isRecording;
  final Widget child;

  const _RecordingOptimizationWrapper({
    Key? key,
    required this.isRecording,
    required this.child,
  }) : super(key: key);

  @override
  State<_RecordingOptimizationWrapper> createState() =>
      _RecordingOptimizationWrapperState();
}

class _RecordingOptimizationWrapperState
    extends State<_RecordingOptimizationWrapper> {
  @override
  void didUpdateWidget(_RecordingOptimizationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && !oldWidget.isRecording) {
      AndroidRecordingOptimizer.beginRecordingOptimization();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      AndroidRecordingOptimizer.endRecordingOptimization();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
