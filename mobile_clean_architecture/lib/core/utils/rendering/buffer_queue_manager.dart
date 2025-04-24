import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform_checker.dart';

/// Manages buffer queue issues specifically for Android SurfaceView rendering
///
/// This class provides strategies to prevent and recover from BLASTBufferQueue errors
/// that occur when too many buffers are acquired during media operations
class BufferQueueManager {
  static const int _maxBufferCount = 5;
  static int _currentBufferCount = 0;
  static Timer? _bufferMonitor;
  static bool _isMonitoring = false;

  /// Start monitoring buffer usage
  static void startMonitoring() {
    if (!PlatformChecker.isAndroid || _isMonitoring) return;

    _isMonitoring = true;
    _bufferMonitor = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _checkBufferStatus();
    });
  }

  /// Stop monitoring buffer usage
  static void stopMonitoring() {
    _bufferMonitor?.cancel();
    _bufferMonitor = null;
    _isMonitoring = false;
    _currentBufferCount = 0;
  }

  /// Check buffer status and take action if needed
  static void _checkBufferStatus() {
    // If we're approaching the buffer limit, force a frame refresh
    if (_currentBufferCount >= _maxBufferCount - 2) {
      _forceBufferRelease();
    }
  }

  /// Force buffer release by scheduling a frame update
  static void _forceBufferRelease() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force update to flush buffers
      WidgetsBinding.instance.scheduleFrame();

      // Reduce buffer count after forcing update
      if (_currentBufferCount > 0) {
        _currentBufferCount--;
      }
    });
  }

  /// Register a buffer acquisition
  static void registerBufferAcquisition() {
    if (!PlatformChecker.isAndroid) return;
    _currentBufferCount++;

    // If we've exceeded limits, force immediate release
    if (_currentBufferCount >= _maxBufferCount) {
      _forceBufferRelease();
    }
  }

  /// Register a buffer release
  static void registerBufferRelease() {
    if (!PlatformChecker.isAndroid) return;
    if (_currentBufferCount > 0) {
      _currentBufferCount--;
    }
  }

  /// Optimize a widget by wrapping it with buffer management
  static Widget optimizeWidget({required Widget child}) {
    if (!PlatformChecker.isAndroid) return child;

    return _BufferOptimizedWidget(child: child);
  }
}

/// Internal widget that handles buffer optimization
class _BufferOptimizedWidget extends StatefulWidget {
  final Widget child;

  const _BufferOptimizedWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_BufferOptimizedWidget> createState() => _BufferOptimizedWidgetState();
}

class _BufferOptimizedWidgetState extends State<_BufferOptimizedWidget> {
  @override
  void initState() {
    super.initState();
    BufferQueueManager.registerBufferAcquisition();
  }

  @override
  void dispose() {
    BufferQueueManager.registerBufferRelease();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
