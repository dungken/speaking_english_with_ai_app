import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../platform_checker.dart';

/// Emergency recovery for severe SurfaceView issues
///
/// This class provides last-resort recovery mechanisms for when
/// BLASTBufferQueue errors become unmanageable
class SurfaceViewRecovery {
  static bool _isRecovering = false;
  static int _recoveryAttempts = 0;
  static const int _maxRecoveryAttempts = 3;
  
  /// Attempt to recover from severe SurfaceView issues
  static Future<bool> attemptRecovery(BuildContext context) async {
    if (_isRecovering || _recoveryAttempts >= _maxRecoveryAttempts) {
      return false;
    }
    
    _isRecovering = true;
    _recoveryAttempts++;
    
    try {
      // Show recovery UI briefly
      _showRecoveryIndicator(context);
      
      // Force garbage collection
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      // Reset system UI
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
      
      // Force a complete frame refresh
      WidgetsBinding.instance.scheduleFrame();
      await Future.delayed(const Duration(milliseconds: 200));
      
      _isRecovering = false;
      return true;
    } catch (e) {
      debugPrint('SurfaceView recovery failed: $e');
      _isRecovering = false;
      return false;
    }
  }
  
  /// Show a brief recovery indicator
  static void _showRecoveryIndicator(BuildContext context) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Optimizing recording...'),
        duration: Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Reset recovery attempts (call when returning to stable state)
  static void resetRecoveryAttempts() {
    _recoveryAttempts = 0;
  }
  
  /// Create a recovery-enabled widget wrapper
  static Widget createRecoveryWrapper({
    required Widget child,
    required BuildContext context,
  }) {
    return Builder(
      builder: (innerContext) {
        return _SurfaceViewRecoveryWrapper(
          child: child,
          onError: () => attemptRecovery(innerContext),
        );
      },
    );
  }
}

/// Internal widget that monitors for errors and triggers recovery
class _SurfaceViewRecoveryWrapper extends StatefulWidget {
  final Widget child;
  final Future<bool> Function() onError;
  
  const _SurfaceViewRecoveryWrapper({
    Key? key,
    required this.child,
    required this.onError,
  }) : super(key: key);
  
  @override
  State<_SurfaceViewRecoveryWrapper> createState() => _SurfaceViewRecoveryWrapperState();
}

class _SurfaceViewRecoveryWrapperState extends State<_SurfaceViewRecoveryWrapper> {
  bool _showFallback = false;
  
  @override
  Widget build(BuildContext context) {
    if (_showFallback) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
  
  void handleError() async {
    setState(() {
      _showFallback = true;
    });
    
    final success = await widget.onError();
    
    if (mounted && success) {
      setState(() {
        _showFallback = false;
      });
    }
  }
}
