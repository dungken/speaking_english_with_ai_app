import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';

class AppAnimations {
  // Standard durations
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 300);
  
  // Default curve
  static const defaultCurve = Curves.easeInOut;
  
  // Fade-in animation
  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: defaultCurve,
      ),
    );
  }
  
  // Slide animation
  static Animation<Offset> slideIn(
    AnimationController controller, {
    Offset begin = const Offset(0.2, 0.0),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: defaultCurve,
      ),
    );
  }
  
  // Scale animation
  static Animation<double> scale(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: defaultCurve,
      ),
    );
  }
  
  // Button press animation
  static Animation<double> buttonPress(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );
  }
  
  // Error state shake animation
  static Animation<double> shake(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: ShakeCurve(count: 2, offset: 3),
      ),
    );
  }

  // Success animation
  static Animation<double> success(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }
}

// Custom curve for shake animation
class ShakeCurve extends Curve {
  final int count;
  final double offset;

  ShakeCurve({this.count = 3, this.offset = 5.0});

  @override
  double transform(double t) {
    return sin(count * 2 * pi * t) * offset * (1 - t);
  }
}

// Animation builder wrapper for common animations
class AnimatedBuilder extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;
  final bool animate;
  final Offset? slideOffset;

  const AnimatedBuilder({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.animationType = AnimationType.fadeIn,
    this.animate = true,
    this.slideOffset,
  }) : super(key: key);

  @override
  State<AnimatedBuilder> createState() => _AnimatedBuilderState();
}

class _AnimatedBuilderState extends State<AnimatedBuilder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.animationType) {
      case AnimationType.fadeIn:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
      case AnimationType.slideIn:
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      case AnimationType.scaleIn:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      case AnimationType.combined:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.child,
            ),
          ),
        );
    }
  }
}

enum AnimationType {
  fadeIn,
  slideIn,
  scaleIn,
  combined,
}
