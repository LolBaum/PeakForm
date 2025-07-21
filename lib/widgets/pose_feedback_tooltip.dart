import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// A tooltip widget that displays pose feedback with a custom title and color.
///
/// This widget creates a visual feedback element consisting of a rounded container
/// and text that can be used to provide real-time feedback during pose detection
/// or exercise guidance.
///
/// Attention: The tooltip is positioned relative to the parent widget.
/// The parent widget must be a Positioned widget!
///
/// Example usage:
/// ```dart
/// Positioned(
///   left: x,
///   top: y,
///   child: PoseFeedbackTooltip(
///     title: "Good form!",
///     color: Colors.green,
///   ),
/// ),
/// ```
///
/// Parameters:
/// - [title]: The text to display in the tooltip
/// - [color]: The color of the text
class PoseFeedbackTooltip extends StatelessWidget {
  final String title;
  final Color color;

  const PoseFeedbackTooltip({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          /*width: 159,
          height: 44,*/
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: AppColors.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: AppFontSizes.title,
              fontFamily: 'League Spartan',
              fontWeight: AppFontWeights.semiBold,
              decoration: TextDecoration.none,
              height: 0,
            ),
          ),
        ),

      ],
    );
  }
}
