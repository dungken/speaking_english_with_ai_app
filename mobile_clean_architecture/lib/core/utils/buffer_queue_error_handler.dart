import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'rendering/buffer_queue_manager.dart';

/// Handles BLASTBufferQueue errors specifically
///
/// This class provides fallback mechanisms when SurfaceView-related errors occur
class BufferQueueErrorHandler {
  static Timer? _resetTimer;
  static Timer? _cooldownTimer;
  static int _errorCount = 0;
  static const int _maxErrors = 3;
  static bool _cooldownActive = false;

  /// Handles BLASTBufferQueue errors
  static void handleBufferQueueError(
      BuildContext context, String errorMessage) {
    // Only respond to buffer queue errors
    if (errorMessage.contains('BLASTBufferQueue') ||
        errorMessage.contains('acquireNextBuffer') ||
        errorMessage.contains('Can\'t acquire next buffer')) {
      // Don't increment during cooldown to prevent cascading errors
      if (!_cooldownActive) {
        _errorCount++;
      }

      // If we've hit too many errors, provide a more robust reset
      if (_errorCount >= _maxErrors) {
        _performFullReset(context);
      } else {
        _performSoftReset();
      }

      // Start cooldown period
      _startCooldown();
    }
  }

  /// Starts a cooldown period to prevent cascading errors
  static void _startCooldown() {
    _cooldownActive = true;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(seconds: 3), () {
      _cooldownActive = false;
    });
  }

  /// Performs a soft reset for minor buffer issues
  static void _performSoftReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 100), () {
      // Force a frame update to clear buffer queue
      WidgetsBinding.instance.scheduleFrame();

      // Try to reset all buffers
      BufferQueueManager.resetAllBuffers();

      // Provide haptic feedback (subtle indication)
      SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
    });
  }

  /// Performs a full reset for severe buffer issues
  static void _performFullReset(BuildContext context) {
    // Clear the UI state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reset the error count
      _errorCount = 0;

      // Show a brief loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Reset all buffer management
      BufferQueueManager.resetAllBuffers();

      // Reset after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        // First try to recover by closing dialogs
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Remove loading indicator
        }

        // Try to release all resources
        BufferQueueManager.stopMonitoring();

        // Allow frame rebuilding
        WidgetsBinding.instance.scheduleFrame();

        // Restart buffer monitoring
        Future.delayed(const Duration(milliseconds: 100), () {
          BufferQueueManager.startMonitoring();
        });
      });
    });
  }

  /// Resets the error counter (call when app becomes inactive/paused)
  static void resetErrorCount() {
    _errorCount = 0;
    _cooldownActive = false;
  }

  /// Filter BLASTBufferQueue logging errors
  ///
  /// This method can be called from main.dart to suppress these errors globally
  static void filterBLASTBufferQueueErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final String error = details.exceptionAsString();

      // Filter out BLASTBufferQueue errors from logs
      if (error.contains('BLASTBufferQueue') ||
          error.contains('acquireNextBuffer') ||
          error.contains('Can\'t acquire next buffer')) {
        // Instead of logging, trigger a reset
        _performSoftReset();
        return;
      }

      // Forward to default handler for other errors
      FlutterError.presentError(details);
    };
  }
}
