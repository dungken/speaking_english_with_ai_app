import 'dart:async';
import 'package:flutter/material.dart';
import '../platform_checker.dart';
import 'surface_view_optimizer.dart';

/// A lifecycle observer that manages SurfaceView resources throughout the app lifecycle
///
/// This class helps prevent BLASTBufferQueue errors by properly managing
/// rendering resources as the application moves through different lifecycle states
class SurfaceViewLifecycleObserver with WidgetsBindingObserver {
  static final SurfaceViewLifecycleObserver _instance =
      SurfaceViewLifecycleObserver._internal();

  factory SurfaceViewLifecycleObserver() {
    return _instance;
  }

  SurfaceViewLifecycleObserver._internal();

  bool _isInitialized = false;

  /// Initialize the observer and register it with the WidgetsBinding
  void initialize() {
    if (_isInitialized) return;

    // Safe initialization with a microtask to avoid triggering during build
    scheduleMicrotask(() {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      debugPrint('SurfaceViewLifecycleObserver: Initialized');
    });
  }

  /// Set up log filtering to hide known SurfaceView errors
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

  /// Clean up resources when the observer is no longer needed
  void dispose() {
    if (!_isInitialized) return;

    scheduleMicrotask(() {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      debugPrint('SurfaceViewLifecycleObserver: Disposed');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only apply optimizations on Android
    if (!PlatformChecker.isAndroid) return;

    // This method is called by the framework, so schedule our actions safely
    // at the end of the current frame to avoid assertion errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (state) {
        case AppLifecycleState.resumed:
          // App is visible and running in the foreground
          debugPrint('SurfaceViewLifecycleObserver: App resumed');
          SurfaceViewOptimizer.initialize();
          break;

        case AppLifecycleState.inactive:
          // App is inactive, may be entering background
          debugPrint('SurfaceViewLifecycleObserver: App inactive');
          break;

        case AppLifecycleState.paused:
          // App is in the background
          debugPrint('SurfaceViewLifecycleObserver: App paused');
          SurfaceViewOptimizer.cleanupAfterSurfaceView();
          break;

        case AppLifecycleState.detached:
          // App is detached from the UI
          debugPrint('SurfaceViewLifecycleObserver: App detached');
          SurfaceViewOptimizer.dispose();
          break;

        default:
          break;
      }
    });
  }
}
