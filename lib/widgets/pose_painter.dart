import 'package:flutter/material.dart';
import '../providers/pose_detection_provider.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  PosePainter({
    required this.poses,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final pose = poses.first;

    // Paint for confident keypoints (green)
    final confidentPointPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    // Paint for all keypoints (blue) - for debugging
    final allPointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6.0
      ..style = PaintingStyle.fill;

    // Paint for skeleton lines
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw ALL keypoints as blue dots (regardless of confidence)
    for (int i = 0; i < pose.landmarks.length; i++) {
      final landmark = pose.landmarks[i];

      // Convert normalized coordinates (0-1) to screen coordinates
      // Mirror X coordinate for front camera (flip horizontally)
      final x = (1.0 - landmark.x) * size.width; // Flip X for front camera
      final y = landmark.y * size.height;

      // Draw blue dot for every keypoint (larger for visibility)
      canvas.drawCircle(Offset(x, y), 6.0, allPointPaint);

      // Draw green dot over blue if confidence is high enough
      if (landmark.confidence > 0.05) {
        canvas.drawCircle(Offset(x, y), 8.0, confidentPointPaint);
      }

      // Debug: Draw keypoint index number
      if (landmark.confidence > 0.01) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 6, y - 6));
      }
    }

    // Draw skeleton connections for confident keypoints only
    _drawSkeleton(canvas, size, pose, linePaint);
  }

  void _drawSkeleton(Canvas canvas, Size size, Pose pose, Paint paint) {
    // Define keypoint connections for human skeleton
    final connections = [
      // Head connections
      [MoveNetKeypoints.nose, MoveNetKeypoints.leftEye],
      [MoveNetKeypoints.nose, MoveNetKeypoints.rightEye],
      [MoveNetKeypoints.leftEye, MoveNetKeypoints.leftEar],
      [MoveNetKeypoints.rightEye, MoveNetKeypoints.rightEar],

      // Torso connections
      [MoveNetKeypoints.leftShoulder, MoveNetKeypoints.rightShoulder],
      [MoveNetKeypoints.leftShoulder, MoveNetKeypoints.leftHip],
      [MoveNetKeypoints.rightShoulder, MoveNetKeypoints.rightHip],
      [MoveNetKeypoints.leftHip, MoveNetKeypoints.rightHip],

      // Left arm
      [MoveNetKeypoints.leftShoulder, MoveNetKeypoints.leftElbow],
      [MoveNetKeypoints.leftElbow, MoveNetKeypoints.leftWrist],

      // Right arm
      [MoveNetKeypoints.rightShoulder, MoveNetKeypoints.rightElbow],
      [MoveNetKeypoints.rightElbow, MoveNetKeypoints.rightWrist],

      // Left leg
      [MoveNetKeypoints.leftHip, MoveNetKeypoints.leftKnee],
      [MoveNetKeypoints.leftKnee, MoveNetKeypoints.leftAnkle],

      // Right leg
      [MoveNetKeypoints.rightHip, MoveNetKeypoints.rightKnee],
      [MoveNetKeypoints.rightKnee, MoveNetKeypoints.rightAnkle],
    ];

    for (final connection in connections) {
      final startIdx = connection[0];
      final endIdx = connection[1];

      if (startIdx < pose.landmarks.length && endIdx < pose.landmarks.length) {
        final start = pose.landmarks[startIdx];
        final end = pose.landmarks[endIdx];

        // Only draw line if both keypoints are confident enough
        if (start.confidence > 0.05 && end.confidence > 0.05) {
          // Mirror X coordinates for front camera
          final startPoint = Offset(
            (1.0 - start.x) * size.width,
            start.y * size.height,
          );
          final endPoint = Offset(
            (1.0 - end.x) * size.width,
            end.y * size.height,
          );

          canvas.drawLine(startPoint, endPoint, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
