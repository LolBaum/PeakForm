import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/providers/pose_detection_provider.dart';

void main() {
  group('PoseDetectionProvider Unit Tests', () {
    late PoseDetectionProvider provider;

    setUp(() {
      provider = PoseDetectionProvider();
    });

    test('PoseDetectionProvider initializes with correct default values', () {
      expect(provider.poses, isEmpty);
      expect(provider.isDetecting, isFalse);
      expect(provider.isCameraInitialized, isFalse);
      expect(provider.isModelLoaded, isFalse);
      expect(provider.detectionStatus, 'Initializing...');
      expect(provider.cameraController, isNull);
    });

    test('PoseDetectionProvider has correct MoveNet constants', () {
      expect(PoseDetectionProvider.inputSize, 192);
      expect(PoseDetectionProvider.numKeypoints, 17);
      expect(PoseDetectionProvider.confidenceThreshold, 0.01);
    });

    test('PoseDetectionProvider can start and stop detection', () {
      // Test start detection without initialization (should fail)
      provider.startDetection();
      expect(provider.detectionStatus, 'Camera or model not ready');
      expect(provider.isDetecting, isFalse);

      // Test stop detection
      provider.stopDetection();
      expect(provider.isDetecting, isFalse);
      expect(provider.detectionStatus, 'Detection stopped');
      expect(provider.poses, isEmpty);
    });

    test('PoseDetectionProvider handles platform support correctly', () {
      // This test assumes we're not running on web
      expect(provider.isPlatformSupported, isTrue);
    });
/*
    test('PoseDetectionProvider state changes are properly managed', () {
      // Test initial state
      expect(provider.isDetecting, isFalse);
      expect(provider.detectionStatus, 'Initializing...');

      // Test state changes
      provider.stopDetection();
      expect(provider.isDetecting, isFalse);
      expect(provider.detectionStatus, 'Detection stopped');
    }); */

    test('PoseDetectionProvider poses list is properly managed', () {
      expect(provider.poses, isEmpty);

      // Simulate adding poses (this would normally happen during detection)
      // Note: We can't directly test pose detection without camera/model
      expect(provider.poses.length, 0);
    });

    test('PoseDetectionProvider getters work correctly', () {
      expect(provider.cameraController, isNull);
      expect(provider.poses, isEmpty);
      expect(provider.isDetecting, isFalse);
      expect(provider.isCameraInitialized, isFalse);
      expect(provider.isModelLoaded, isFalse);
      expect(provider.detectionStatus, isA<String>());
      expect(provider.isPlatformSupported, isA<bool>());
    });
  });

  group('MoveNet Keypoints Tests', () {
    test('MoveNet keypoint indices are correctly defined', () {
      expect(MoveNetKeypoints.nose, 0);
      expect(MoveNetKeypoints.leftEye, 1);
      expect(MoveNetKeypoints.rightEye, 2);
      expect(MoveNetKeypoints.leftEar, 3);
      expect(MoveNetKeypoints.rightEar, 4);
      expect(MoveNetKeypoints.leftShoulder, 5);
      expect(MoveNetKeypoints.rightShoulder, 6);
      expect(MoveNetKeypoints.leftElbow, 7);
      expect(MoveNetKeypoints.rightElbow, 8);
      expect(MoveNetKeypoints.leftWrist, 9);
      expect(MoveNetKeypoints.rightWrist, 10);
      expect(MoveNetKeypoints.leftHip, 11);
      expect(MoveNetKeypoints.rightHip, 12);
      expect(MoveNetKeypoints.leftKnee, 13);
      expect(MoveNetKeypoints.rightKnee, 14);
      expect(MoveNetKeypoints.leftAnkle, 15);
      expect(MoveNetKeypoints.rightAnkle, 16);
    });

    test('MoveNet keypoint indices are within valid range', () {
      final keypoints = [
        MoveNetKeypoints.nose,
        MoveNetKeypoints.leftEye,
        MoveNetKeypoints.rightEye,
        MoveNetKeypoints.leftEar,
        MoveNetKeypoints.rightEar,
        MoveNetKeypoints.leftShoulder,
        MoveNetKeypoints.rightShoulder,
        MoveNetKeypoints.leftElbow,
        MoveNetKeypoints.rightElbow,
        MoveNetKeypoints.leftWrist,
        MoveNetKeypoints.rightWrist,
        MoveNetKeypoints.leftHip,
        MoveNetKeypoints.rightHip,
        MoveNetKeypoints.leftKnee,
        MoveNetKeypoints.rightKnee,
        MoveNetKeypoints.leftAnkle,
        MoveNetKeypoints.rightAnkle,
      ];

      for (final keypoint in keypoints) {
        expect(keypoint, greaterThanOrEqualTo(0));
        expect(keypoint, lessThan(17)); // 17 keypoints total
      }
    });
  });

  group('PoseLandmark Tests', () {
    test('PoseLandmark can be created with valid parameters', () {
      final landmark = PoseLandmark(x: 0.5, y: 0.3, confidence: 0.8);

      expect(landmark.x, 0.5);
      expect(landmark.y, 0.3);
      expect(landmark.confidence, 0.8);
    });

    test('PoseLandmark coordinates are within valid range', () {
      final landmark = PoseLandmark(x: 0.5, y: 0.3, confidence: 0.8);

      expect(landmark.x, greaterThanOrEqualTo(0.0));
      expect(landmark.x, lessThanOrEqualTo(1.0));
      expect(landmark.y, greaterThanOrEqualTo(0.0));
      expect(landmark.y, lessThanOrEqualTo(1.0));
      expect(landmark.confidence, greaterThanOrEqualTo(0.0));
      expect(landmark.confidence, lessThanOrEqualTo(1.0));
    });
  });

  group('Pose Tests', () {
    test('Pose can be created with valid landmarks', () {
      final landmarks = [
        PoseLandmark(x: 0.5, y: 0.3, confidence: 0.8),
        PoseLandmark(x: 0.6, y: 0.4, confidence: 0.9),
      ];

      final pose = Pose(landmarks: landmarks, confidence: 0.85);

      expect(pose.landmarks, equals(landmarks));
      expect(pose.confidence, 0.85);
      expect(pose.landmarks.length, 2);
    });

    test('Pose confidence is within valid range', () {
      final landmarks = [PoseLandmark(x: 0.5, y: 0.3, confidence: 0.8)];
      final pose = Pose(landmarks: landmarks, confidence: 0.85);

      expect(pose.confidence, greaterThanOrEqualTo(0.0));
      expect(pose.confidence, lessThanOrEqualTo(1.0));
    });
  });
}
