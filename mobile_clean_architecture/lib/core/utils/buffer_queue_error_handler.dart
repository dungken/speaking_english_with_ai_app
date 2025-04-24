import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Handles BLASTBufferQueue errors specifically
///
/// This class provides fallback mechanisms when SurfaceView-related errors occur
class BufferQueueErrorHandler {
  static Timer? _resetTimer;
  static int _errorCount = 0;
  static const int _maxErrors = 3;
  
  /// Handles BLASTBufferQueue errors
  static void handleBufferQueueError(BuildContext context, String errorMessage) {
    if (errorMessage.contains('BLASTBufferQueue')) {
      _errorCount++;
      
      // If we've hit too many errors, provide a more robust reset
      if (_errorCount >= _maxErrors) {
        _performFullReset(context);
      } else {
        _performSoftReset();
      }
    }
  }
  
  /// Performs a soft reset for minor buffer issues
  static void _performSoftReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 100), () {
      // Force a frame update to clear buffer queue
      WidgetsBinding.instance.scheduleFrame();
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
      
      // Reset after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pop(); // Remove loading indicator
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    });
  }
  
  /// Resets the error counter (call when app becomes inactive/paused)
  static void resetErrorCount() {
    _errorCount = 0;
  }
}
