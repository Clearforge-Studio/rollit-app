import 'package:flutter/material.dart';

PageRouteBuilder<T> slideTransition<T>(Widget widget) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Animation<double> curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      final offsetAnimation = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
