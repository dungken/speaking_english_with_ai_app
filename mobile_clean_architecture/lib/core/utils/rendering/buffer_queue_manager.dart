import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform_checker.dart';

/// Manages buffer queue issues specifically for Android SurfaceView rendering
///
/// This class provides strategies to prevent and recover from BLASTBufferQueue errors
/// that occur when too many buffers are acquired during media operations
class BufferQueueManager {
  static const int _maxBufferCount = 5; // Android allows 5+2 frames
  static int _currentBufferCount = 0;
  static Timer? _bufferMonitor;
  static bool _isMonitoring = false;
  static const MethodChannel _channel =
      MethodChannel('com.example.mobile_clean_architecture/surface_view');

  /// Start monitoring buffer usage
  static void startMonitoring() {
    if (!PlatformChecker.isAndroid || _isMonitoring) return;

    _isMonitoring = true;
    // Force release buffers when starting to ensure clean state
    _forceBufferRelease(immediate: true);

    _bufferMonitor = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _checkBufferStatus();
    });

    // Try to initialize native surface optimization if available
    _initializeNativeSurfaceOptimization();
  }

  /// Stop monitoring buffer usage
  static void stopMonitoring() {
    _bufferMonitor?.cancel();
    _bufferMonitor = null;
    _isMonitoring = false;
    _currentBufferCount = 0;

    // Release native resources
    _releaseNativeSurfaceOptimization();
  }

  /// Try to initialize native surface optimization
  static Future<void> _initializeNativeSurfaceOptimization() async {
    if (!PlatformChecker.isAndroid) return;

    try {
      await _channel.invokeMethod('initializeSurfaceOptimization');
    } catch (e) {
      // Native method might not be available, continue with fallback
    }
  }

  /// Release native surface optimization
  static Future<void> _releaseNativeSurfaceOptimization() async {
    if (!PlatformChecker.isAndroid) return;

    try {
      await _channel.invokeMethod('releaseSurfaceOptimization');
    } catch (e) {
      // Native method might not be available, ignore
    }
  }

  /// Check buffer status and take action if needed
  static void _checkBufferStatus() {
    // If we're approaching the buffer limit, force a frame refresh
    if (_currentBufferCount >= _maxBufferCount - 1) {
      _forceBufferRelease();
    }
  }

  /// Force buffer release by scheduling a frame update
  static void _forceBufferRelease({bool immediate = false}) {
    if (immediate) {
      // Immediate frame scheduling and garbage collection hint
      WidgetsBinding.instance.scheduleFrame();

      // Try to trigger native optimization
      _triggerNativeBufferRelease();

      // Reset counter after forcing release
      if (_currentBufferCount > 0) {
        _currentBufferCount = 0;
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force update to flush buffers
        WidgetsBinding.instance.scheduleFrame();

        // Try to trigger native optimization
        _triggerNativeBufferRelease();

        // Reduce buffer count after forcing update
        if (_currentBufferCount > 0) {
          _currentBufferCount--;
        }
      });
    }
  }

  /// Trigger native buffer release mechanism if available
  static Future<void> _triggerNativeBufferRelease() async {
    if (!PlatformChecker.isAndroid) return;

    try {
      await _channel.invokeMethod('releaseBuffers');
    } catch (e) {
      // Native method might not be available, ignore
    }
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

  /// Reset all buffers - call when screen is disposed
  static void resetAllBuffers() {
    if (!PlatformChecker.isAndroid) return;
    _currentBufferCount = 0;
    _forceBufferRelease(immediate: true);
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

class _BufferOptimizedWidgetState extends State<_BufferOptimizedWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    BufferQueueManager.registerBufferAcquisition();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BufferQueueManager.registerBufferRelease();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reset buffer management when app goes into background or becomes inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      BufferQueueManager.resetAllBuffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
