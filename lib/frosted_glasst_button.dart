import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassButton extends StatelessWidget {
  final Widget child;

  final VoidCallback onTap;

  const FrostedGlassButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(((255 * 0.2).round())),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Colors.white.withAlpha((255 * 0.3).round()),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
