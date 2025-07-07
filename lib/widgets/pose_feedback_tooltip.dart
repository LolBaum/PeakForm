import 'package:flutter/material.dart';
import 'package:fitness_app/constants/constants.dart';

/// A tooltip widget that displays pose feedback with a custom title and color.
///
/// This widget creates a visual feedback element consisting of a rounded container
/// and text that can be used to provide real-time feedback during pose detection
/// or exercise guidance.
///
/// Example usage:
/// ```dart
/// PoseFeedbackTooltip(
///   title: "Good form!",
///   color: Colors.green,
/// )
/// ```
///
/// Parameters:
/// - [title]: The text to display in the tooltip
/// - [color]: The color of the text
/// - [x]: The x position of the tooltip
/// - [y]: The y position of the tooltip
class PoseFeedbackTooltip extends StatelessWidget {
  final String title;
  final Color color;
  final double x;
  final double y;

  const PoseFeedbackTooltip({
    super.key,
    required this.title,
    required this.color,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 159,
          height: 44,
          decoration: ShapeDecoration(
            color: AppColors.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: AppFontSizes.title,
            fontFamily: 'League Spartan',
            fontWeight: AppFontWeights.semiBold,
            height: 0.78,
          ),
        ),
      ],
    );
  }
}
