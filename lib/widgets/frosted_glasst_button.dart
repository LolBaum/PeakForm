import '../constants/constants.dart';
import 'package:flutter/material.dart';

class FrostedGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;

  const FrostedGlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool showIconOnly =
        icon != null && (label.isEmpty || label.trim().isEmpty);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: showIconOnly ? null : 90,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white.withAlpha((0.17 * 255).toInt()),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0x7F969696),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Center(
              child: showIconOnly
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 29, horizontal: 22),
                      child: icon,
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSizes.title,
                        fontFamily: 'LeagueSpartan',
                        fontWeight: AppFontWeights.semiBold,
                        height: 1.0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
