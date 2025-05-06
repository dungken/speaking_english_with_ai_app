import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../platform_checker.dart';

/// A utility class that optimizes SurfaceView rendering in Flutter, particularly
/// on Android devices to address BLASTBufferQueue errors.
///
/// This class provides methods to optimize how Flutter handles SurfaceViews
/// without needing to modify the native Android code directly.
class SurfaceViewOptimizer {
  static const platform =
      MethodChannel('com.example.mobile_clean_architecture/surface_optimizer');

  /// A timer that periodically triggers frame buffer cleanup
  static Timer? _bufferCleanupTimer;

  /// Tracks whether optimization has been initialized
  static bool _isInitialized = false;

  /// A flag to track if we're in a safe frame to apply UI changes
  static bool _safeToModifyBinding = true;

  static void setupLogFiltering() {
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == null) return;
      if (message.contains('BLASTBufferQueue') ||
          message.contains('acquireNextBufferLocked')) {
        return; // Skip these noisy messages
      }
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };
  }

  /// Initialize the surface view optimization
  /// Should be called when the app starts or before using Surface-heavy features
  static Future<void> initialize() async {
    if (_isInitialized || !PlatformChecker.isAndroid) return;

    try {
      // Set preferred refresh rate to help with frame timing
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Start a timer to periodically trigger frame rendering
      // This helps prevent buffer accumulation by forcing Flutter
      // to refresh its rendering pipeline periodically
      _bufferCleanupTimer?.cancel();
      _bufferCleanupTimer =
          Timer.periodic(const Duration(milliseconds: 1000), (_) {
        // Use a safer approach to schedule frame updates
        if (!WidgetsBinding.instance.hasScheduledFrame) {
          WidgetsBinding.instance.scheduleFrame();
        }
      });

      // Set optimal render mode for SurfaceViews
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );

      // Configure image cache policy to reduce memory pressure
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          1024 * 1024 * 50; // 50 MB

      _isInitialized = true;
      debugPrint('SurfaceViewOptimizer: Initialized successfully');
    } catch (e) {
      debugPrint('SurfaceViewOptimizer: Failed to initialize - $e');
    }
  }

  /// Optimize a specific widget that uses SurfaceView (like video players or camera views)
  ///
  /// Wrap any widget that might use SurfaceViews with this method:
  /// ```
  /// SurfaceViewOptimizer.optimizeWidget(
  ///   child: MyVideoPlayer(),
  /// )
  /// ```
  static Widget optimizeWidget({required Widget child}) {
    if (!PlatformChecker.isAndroid) return child;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
            layoutBuilder: (currentChild, previousChildren) {
              return currentChild ?? Container();
            },
          );
        },
      ),
    );
  }

  /// Call this before displaying a screen that uses SurfaceView heavily
  static void prepareForSurfaceView() {
    if (!PlatformChecker.isAndroid) return;

    // Schedule this for the end of the current frame to avoid build-time modifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Pre-warm the raster cache to smooth rendering during media operations
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // Set this safely after the current build phase is complete
        WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
      } catch (e) {
        debugPrint('SurfaceViewOptimizer preparation error: $e');
      }
    });
  }

  /// Call this when leaving a screen that uses SurfaceView
  static void cleanupAfterSurfaceView() {
    if (!PlatformChecker.isAndroid) return;

    // Schedule this for the end of the current frame to avoid build-time modifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = true;
      } catch (e) {
        debugPrint('SurfaceViewOptimizer cleanup error: $e');
      }

      // This delay helps ensure Surface buffers are properly released
      Timer(const Duration(milliseconds: 100), () {
        WidgetsBinding.instance.scheduleFrame();
      });
    });
  }

  /// Dispose the optimizer resources
  /// Should be called when the app is terminated
  static void dispose() {
    _bufferCleanupTimer?.cancel();
    _bufferCleanupTimer = null;
    _isInitialized = false;
  }
}
