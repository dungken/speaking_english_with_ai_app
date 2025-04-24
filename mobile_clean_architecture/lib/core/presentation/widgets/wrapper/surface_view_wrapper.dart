import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/platform_checker.dart';
import '../../../utils/rendering/surface_view_optimizer.dart';

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

class _SurfaceViewWrapperState extends State<SurfaceViewWrapper> {
  @override
  void initState() {
    super.initState();

    // Apply optimizations after the widget is fully initialized,
    // deferring to a microtask to avoid triggering during build phase
    if (widget.isActiveMedia && PlatformChecker.isAndroid) {
      scheduleMicrotask(() {
        // Only apply if the widget is still mounted
        if (mounted) {
          SurfaceViewOptimizer.prepareForSurfaceView();
        }
      });
    }
  }

  @override
  void didUpdateWidget(SurfaceViewWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Apply or remove optimizations when isActiveMedia changes,
    // but defer to post-frame callback to avoid build phase issues
    if (PlatformChecker.isAndroid &&
        widget.isActiveMedia != oldWidget.isActiveMedia) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only apply if the widget is still mounted
        if (!mounted) return;

        if (widget.isActiveMedia) {
          SurfaceViewOptimizer.prepareForSurfaceView();
        } else {
          SurfaceViewOptimizer.cleanupAfterSurfaceView();
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up optimizations when the widget is removed
    // This is safe because dispose happens outside the build phase
    if (widget.isActiveMedia && PlatformChecker.isAndroid) {
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

    // For Android, apply special optimizations using a simpler approach
    // Avoid complex layout builders that might trigger build assertions
    return RepaintBoundary(
      child: widget.child,
    );
  }
}
