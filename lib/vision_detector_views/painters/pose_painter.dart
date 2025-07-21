import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';
import '../../constants/constants.dart';
class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this.boneFeedback,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Map<String, String> boneFeedback; // z.B. {'leftUpperArm': 'good', ...}

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = AppColors.blue ;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = AppColors.blue;

    // Helper für Gradient
    Paint gradientPaint(Offset p1, Offset p2, String boneKey) {
      String status = boneFeedback[boneKey] ?? 'default';
      List<Color> colors;
      List<double> stops = [0.0, 1.0];
      if (status == 'good') {
        colors = [const Color(0x87A1EA93), const Color(0xFF71DE86)]; // 53% alpha
      } else if (status == 'bad') {
        colors = [const Color(0x91B32814), const Color(0xFF999999)]; // 57% alpha
      } else {
        colors = [const Color(0x8AFFFFFF), const Color(0xFF999999)]; // 54% alpha
      }
      return Paint()
        ..shader = LinearGradient(
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromPoints(p1, p2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
    }

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, String boneKey) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        final p1 = Offset(
          translateX(joint1.x, size, imageSize, rotation, cameraLensDirection),
          translateY(joint1.y, size, imageSize, rotation, cameraLensDirection),
        );
        final p2 = Offset(
          translateX(joint2.x, size, imageSize, rotation, cameraLensDirection),
          translateY(joint2.y, size, imageSize, rotation, cameraLensDirection),
        );
        canvas.drawLine(p1, p2, gradientPaint(p1, p2, boneKey));
      }

      //Draw arms
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, 'leftUpperArm');
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, 'leftLowerArm');
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, 'rightUpperArm');
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, 'rightLowerArm');

      //Draw Body
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, 'leftTorso');
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, 'rightTorso');

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, 'leftUpperLeg');
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, 'leftLowerLeg');
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, 'rightUpperLeg');
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, 'rightLowerLeg');
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
