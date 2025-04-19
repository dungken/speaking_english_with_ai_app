import 'package:flutter/material.dart';

class AppPageTransitions {
  // Forward navigation (new screen entering)
  static Widget forwardTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(Tween(begin: 0.8, end: 1.0)),
        child: child,
      ),
    );
  }
  
  // Backward navigation (previous screen returning)
  static Widget backwardTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    
    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(Tween(begin: 0.8, end: 1.0)),
        child: child,
      ),
    );
  }
  
  // Modal transition (overlay/dialog)
  static Widget modalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }

  // Fade transition (for less dramatic changes)
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // Define shared page transitions for GoRouter or other navigation
  static PageTransitionsBuilder appPageTransitions() {
    return _AppPageTransitionsBuilder();
  }
}

class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Root route (like first page after splash) - use fade
    if (route.isFirst) {
      return AppPageTransitions.fadeTransition(
        context, animation, secondaryAnimation, child);
    }
    
    // Standard page transition
    return AppPageTransitions.forwardTransition(
      context, animation, secondaryAnimation, child);
  }
}
