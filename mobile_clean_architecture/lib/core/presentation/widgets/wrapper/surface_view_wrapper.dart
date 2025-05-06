import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/platform_checker.dart';
import '../../../utils/rendering/surface_view_optimizer.dart';
import '../../../utils/rendering/buffer_queue_manager.dart';

/// A widget wrapper that optimizes Android SurfaceView rendering to prevent BLASTBufferQueue errors
///
/// This wrapper applies special rendering optimizations when used around widgets that interact with
/// SurfaceViews on Android, such as camera previews, video players, and audio recorders.
///
/// It works by:
/// 1. Isolating the widget tree with RepaintBoundary
/// 2. Applying platform-specific optimizations for Android
/// 3. Managing render resources efficiently during media operations
///
/// Usage example:
/// ```dart
/// SurfaceViewWrapper(
///   isActiveMedia: isRecording, // Set to true when recording or playing media
///   child: MyAudioRecorder(),
/// )
/// ```
class SurfaceViewWrapper extends StatefulWidget {
  /// The child widget to wrap with optimized rendering
  final Widget child;

  /// Whether this wrapper contains active media (recording, playback, etc)
  ///
  /// Setting this to true applies more aggressive optimizations to prevent
  /// BLASTBufferQueue errors during intensive operations
  final bool isActiveMedia;

  const SurfaceViewWrapper({
    Key? key,
    required this.child,
    this.isActiveMedia = false,
  }) : super(key: key);

  @override
  State<SurfaceViewWrapper> createState() => _SurfaceViewWrapperState();
}

class _SurfaceViewWrapperState extends State<SurfaceViewWrapper>
    with WidgetsBindingObserver {
  bool _wasActiveMedia = false;
  Timer? _bufferCleanupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wasActiveMedia = widget.isActiveMedia;

    // Register frame acquisition when active
    if (_wasActiveMedia && PlatformChecker.isAndroid) {
      _registerFrameAcquisition();
    }
  }

  void _registerFrameAcquisition() {
    // Delay acquisition slightly to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BufferQueueManager.registerBufferAcquisition();
        SurfaceViewOptimizer.prepareForSurfaceView();

        // Schedule periodic buffer cleanup
        _startPeriodicCleanup();
      }
    });
  }

  void _startPeriodicCleanup() {
    _bufferCleanupTimer?.cancel();
    _bufferCleanupTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && widget.isActiveMedia) {
        // Force a buffer refresh
        BufferQueueManager.registerBufferRelease();
        BufferQueueManager.registerBufferAcquisition();
      }
    });
  }

  @override
  void didUpdateWidget(SurfaceViewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle changes in activity state
    if (!_wasActiveMedia && widget.isActiveMedia) {
      if (PlatformChecker.isAndroid) {
        _registerFrameAcquisition();
      }
      _wasActiveMedia = true;
    } else if (_wasActiveMedia && !widget.isActiveMedia) {
      if (PlatformChecker.isAndroid) {
        _releaseFrames();
      }
      _wasActiveMedia = false;
    }
  }

  void _releaseFrames() {
    // Cancel cleanup timer
    _bufferCleanupTimer?.cancel();
    _bufferCleanupTimer = null;

    // Release buffers
    BufferQueueManager.registerBufferRelease();
    SurfaceViewOptimizer.cleanupAfterSurfaceView();

    // Force a frame to ensure buffers are properly released
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BufferQueueManager.resetAllBuffers();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app goes to background, release all buffers
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_wasActiveMedia && PlatformChecker.isAndroid) {
        _releaseFrames();
      }
    } else if (state == AppLifecycleState.resumed) {
      // When returning to foreground, re-acquire if needed
      if (widget.isActiveMedia &&
          PlatformChecker.isAndroid &&
          _wasActiveMedia) {
        _registerFrameAcquisition();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bufferCleanupTimer?.cancel();

    // Clean up optimizations when the widget is removed
    if (_wasActiveMedia && PlatformChecker.isAndroid) {
      BufferQueueManager.registerBufferRelease();
      SurfaceViewOptimizer.cleanupAfterSurfaceView();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On non-Android platforms, just return the child as is
    if (!PlatformChecker.isAndroid) {
      return widget.child;
    }

    // For Android, apply special optimizations with a deeper isolation approach
    return RepaintBoundary(
      child: ClipRect(
        child: widget.child,
      ),
    );
  }
}
