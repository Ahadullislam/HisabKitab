import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // Durations
  static const fast    = Duration(milliseconds: 200);
  static const medium  = Duration(milliseconds: 350);
  static const slow    = Duration(milliseconds: 600);
  static const verySlow= Duration(milliseconds: 900);

  // Curves
  static const standard    = Curves.easeInOut;
  static const decelerate  = Curves.decelerate;
  static const spring      = Curves.elasticOut;
  static const smoothSpring= Curves.easeOutBack;

  // Page transitions
  static Widget fadeSlideTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}