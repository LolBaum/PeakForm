import '../constants/constants.dart';
import 'package:flutter/material.dart';

/// A toolbar widget that displays pose status information with a custom title and color.
///
/// This widget creates a visual status element.
/// E.g. "Failed analyzing Pose"
///
/// Attention: The toolbar is positioned relative to the parent widget.
class PoseStatusToolbar extends StatelessWidget {
  final String title;
  final Color color;

  const PoseStatusToolbar(
      {super.key, required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // TODO: Add to constants
          height: 74,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              // TODO: Add to constants
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: 74,
                  decoration: ShapeDecoration(
                    // TODO: Add to constants
                    color: const Color(0xFFFAF9F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: AppFontSizes.title,
                      // TODO: Central place to set font family
                      fontFamily: 'LeagueSpartan',
                      fontWeight: AppFontWeights.semiBold,
                      height: 0.65,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
