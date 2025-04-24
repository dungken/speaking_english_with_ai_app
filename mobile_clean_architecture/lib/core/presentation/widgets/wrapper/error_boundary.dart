import 'package:flutter/material.dart';

/// Error boundary widget that catches widget errors and provides recovery options
///
/// This widget wraps around potentially problematic widgets (like those using SurfaceViews)
/// and provides error handling and recovery mechanisms
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.onError,
  }) : super(key: key);
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;
  StackTrace? _stackTrace;
  
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      _handleError(details.exception, details.stack);
    };
  }
  
  void _handleError(Object error, StackTrace? stackTrace) {
    widget.onError?.call(error, stackTrace);
    
    // Only trigger rebuild if the error contains BLASTBufferQueue
    if (error.toString().contains('BLASTBufferQueue')) {
      setState(() {
        _hasError = true;
        _error = error;
        _stackTrace = stackTrace;
      });
      
      // Auto-recover after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _hasError = false;
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}
