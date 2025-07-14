import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../util/logging_service.dart';

// MoveNet keypoint indices according to TensorFlow documentation
// https://www.tensorflow.org/hub/tutorials/movenet
class MoveNetKeypoints {
  static const int nose = 0;
  static const int leftEye = 1;
  static const int rightEye = 2;
  static const int leftEar = 3;
  static const int rightEar = 4;
  static const int leftShoulder = 5;
  static const int rightShoulder = 6;
  static const int leftElbow = 7;
  static const int rightElbow = 8;
  static const int leftWrist = 9;
  static const int rightWrist = 10;
  static const int leftHip = 11;
  static const int rightHip = 12;
  static const int leftKnee = 13;
  static const int rightKnee = 14;
  static const int leftAnkle = 15;
  static const int rightAnkle = 16;
}

// Pose landmark structure for MoveNet - output format [y, x, confidence]
class PoseLandmark {
  final double x;
  final double y;
  final double confidence;

  PoseLandmark({required this.x, required this.y, required this.confidence});
}

// Pose structure - shape [1, 1, 17, 3] according to tutorial
class Pose {
  final List<PoseLandmark> landmarks;
  final double confidence;

  Pose({required this.landmarks, required this.confidence});
}

class PoseDetectionProvider extends ChangeNotifier {
  CameraController? _cameraController;
  List<Pose> _poses = [];
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;
  String _detectionStatus = 'Initializing...';
  bool _isProcessing = false;
  XFile? _recordedVideoFile;
  bool _isRecording = false;
  bool _hasDetectionBeenStarted = false;

  // TensorFlow Lite
  Interpreter? _interpreter;

  // Performance tracking
  int _frameCount = 0;
  DateTime _startTime = DateTime.now();

  // Constants for MoveNet SinglePose Lightning model
  static const int inputSize =
      192; // SinglePose Lightning input size: [1, 192, 192, 3]
  static const int numKeypoints = 17;
  static const double confidenceThreshold =
      0.01; // Very low threshold to see all detections

  // Safe logger access that won't crash if global logger isn't initialized
  void _log(String message) {
    try {
      LoggingService.instance.i(message);
    } catch (e) {
      debugPrint('PoseDetectionProvider: $message');
    }
  }

  // Getters
  CameraController? get cameraController => _cameraController;
  List<Pose> get poses => _poses;
  bool get isDetecting => _isDetecting;
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isModelLoaded => _isModelLoaded;
  String get detectionStatus => _detectionStatus;
  bool get isPlatformSupported => !kIsWeb;
  bool get hasDetectionBeenStarted => _hasDetectionBeenStarted;

  // Video recording getters
  XFile? get recordedVideoFile => _recordedVideoFile;
  bool get isRecording => _isRecording;

  // Initialize camera and load MoveNet model
  Future<void> initializeCamera() async {
    _log('Initializing camera and pose detection system');
    _hasDetectionBeenStarted = false;
    try {
      if (!isPlatformSupported) {
        _log('Camera not supported on web platform');
        _detectionStatus = 'Camera not supported on web platform';
        notifyListeners();
        return;
      }

      // Try to load MoveNet model, but continue if it fails
      bool modelLoaded = false;
      try {
        await _loadModel();
        modelLoaded = true;
        _log('MoveNet model loaded successfully');
      } catch (e) {
        _log('Model loading failed: $e - continuing with camera only');
        _detectionStatus = '⚠️ Model loading failed: $e\nCamera preview only.';
        debugPrint('❌ Model loading error (camera will still open): $e');
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _log('No cameras available on device');
        _detectionStatus = 'No cameras available';
        notifyListeners();
        return;
      }

      // Find front camera, fallback to first camera if front not available
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _log('Using camera: ${frontCamera.name} (${frontCamera.lensDirection})');
      debugPrint('📷 Using camera: ${frontCamera.name}');

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;

      if (modelLoaded && kDebugMode) {
        _detectionStatus =
            'MoveNet SinglePose Lightning model loaded and ready!';
        _log('Camera and model initialization completed successfully');
      } else {
        _detectionStatus = 'Camera ready. Pose detection unavailable.';
        _log('Camera initialization completed (model unavailable)');
      }

      debugPrint('✅ Camera initialized (model loaded: $modelLoaded)');
      notifyListeners();
    } catch (e) {
      _log('Camera/model initialization failed: $e');
      _detectionStatus = 'Initialization failed: $e';
      debugPrint('❌ Camera/Model init error: $e');
      notifyListeners();
    }
  }

  // Load MoveNet TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      debugPrint('🤖 Loading MoveNet SinglePose Lightning model...');

      // Load the 3.tflite model (SinglePose Lightning)
      _interpreter = await Interpreter.fromAsset('assets/models/3.tflite');

      // Verify input/output shapes and types
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;
      final inputType = inputTensor.type;
      final outputType = outputTensor.type;

      debugPrint('📐 Model input shape: $inputShape');
      debugPrint('📐 Model output shape: $outputShape');
      debugPrint('🔢 Model input type: $inputType');
      debugPrint('🔢 Model output type: $outputType');

      // Expected SinglePose: input [1, 192, 192, 3], output [1, 1, 17, 3]
      if (inputShape[1] != inputSize || inputShape[2] != inputSize) {
        throw Exception(
          'Invalid model input size. Expected ${inputSize}x$inputSize, got ${inputShape[1]}x${inputShape[2]}',
        );
      }

      // SinglePose output: [1, 1, 17, 3] = 1 person, 17 keypoints, 3 values per keypoint
      if (outputShape.length < 4 ||
          outputShape[2] != numKeypoints ||
          outputShape[3] != 3) {
        debugPrint(
          '⚠️ Unexpected output shape: $outputShape - expected [1, 1, 17, 3]',
        );
      }

      _isModelLoaded = true;
      debugPrint('✅ MoveNet SinglePose Lightning model loaded successfully');
    } catch (e) {
      debugPrint('❌ Model loading error: $e');
      throw Exception('Failed to load MoveNet SinglePose Lightning model: $e');
    }
  }

  // Start detection
  void startDetection() {
    _log('Starting MoveNet pose detection');
    debugPrint('🚀 Starting MoveNet pose detection...');

    if (!isPlatformSupported) {
      _log('Pose detection not supported on web platform');
      _detectionStatus =
          'Pose detection not supported on web. Use Android/iOS device.';
      notifyListeners();
      return;
    }

    if (_cameraController == null || !_isCameraInitialized || !_isModelLoaded) {
      _log('Cannot start detection - camera or model not ready');
      _detectionStatus = 'Camera or model not ready';
      _isDetecting = false;
      _hasDetectionBeenStarted = false;
      notifyListeners();
      return;
    }

    _isDetecting = true;
    _hasDetectionBeenStarted = true;
    notifyListeners();
    _startTime = DateTime.now();
    _frameCount = 0;
    _detectionStatus =
        'MoveNet SinglePose Lightning detecting pose in real-time...';

    // Start camera stream processing
    _cameraController!.startImageStream(_processCameraImage);

    _log('Pose detection started successfully');
    notifyListeners();
  }

  // Stop detection
  void stopDetection() {
    _isDetecting = false;
    notifyListeners();
    _log('Stopping MoveNet pose detection');
    _cameraController?.stopImageStream();
    _detectionStatus = 'Detection stopped';
    _poses = []; // Clear poses when stopping
    debugPrint('🛑 MoveNet pose detection stopped');
    _log('Pose detection stopped successfully');
  }

  // Process camera image with MoveNet SinglePose Lightning inference
  void _processCameraImage(CameraImage image) async {
    if (!_isDetecting || _isProcessing || _interpreter == null) return;

    _isProcessing = true;
    _frameCount++;

    try {
      // Skip frames for better performance - process every 2nd frame
      if (_frameCount % 2 != 0) {
        _isProcessing = false;
        return;
      }

      // Convert YUV420 to RGB and resize
      final imgRgb = _convertYUV420ToRGB(image);
      final resized = img.copyResize(
        imgRgb,
        width: inputSize,
        height: inputSize,
      );

      // Create input tensor [1, 192, 192, 3] with float32 values (0.0-1.0) for SinglePose Lightning
      final inputTensor = Float32List(1 * inputSize * inputSize * 3);
      int index = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputTensor[index++] = pixel.r.toDouble() / 255.0; // Red (0.0-1.0)
          inputTensor[index++] = pixel.g.toDouble() / 255.0; // Green (0.0-1.0)
          inputTensor[index++] = pixel.b.toDouble() / 255.0; // Blue (0.0-1.0)
        }
      }

      // Debug: Print input tensor statistics every 100 frames
      if (_frameCount % 100 == 0) {
        final minVal = inputTensor.reduce(math.min);
        final maxVal = inputTensor.reduce(math.max);
        final avgVal = inputTensor.reduce((a, b) => a + b) / inputTensor.length;
        debugPrint(
          '📊 Input tensor stats: min=$minVal, max=$maxVal, avg=${avgVal.toStringAsFixed(3)}',
        );
      }

      // Reshape to [1, 192, 192, 3] tensor
      final input = inputTensor.reshape([1, inputSize, inputSize, 3]);

      // Prepare output tensor for SinglePose [1, 1, 17, 3]
      var output = List.generate(
        1,
        (index) => List.generate(
          1,
          (index) =>
              List.generate(numKeypoints, (index) => List.filled(3, 0.0)),
        ),
      );

      // Run MoveNet SinglePose Lightning inference
      _interpreter!.run(input, output);

      // Parse output and create poses
      final poses = _parseModelOutput(output);

      _poses = poses;

      // Update performance stats (reduced frequency)
      if (_frameCount % 20 == 0) {
        final now = DateTime.now();
        final elapsed = now.difference(_startTime).inMilliseconds;
        final fps = _frameCount / (elapsed / 1000.0);

        final hasDetection = poses.isNotEmpty;
        final totalKeypoints = poses.isNotEmpty
            ? poses.first.landmarks
                .where((l) => l.confidence > confidenceThreshold)
                .length
            : 0;
        _detectionStatus =
            'SinglePose Lightning: ${fps.toStringAsFixed(1)} FPS | ${hasDetection ? "Person detected" : "No person"}, $totalKeypoints keypoints';

        // Reduced debug output frequency
        if (_frameCount % 100 == 0) {
          debugPrint(
            '🎯 SinglePose frame $_frameCount: ${fps.toStringAsFixed(1)} FPS, ${hasDetection ? "detected" : "no detection"}',
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ MoveNet SinglePose processing error: $e');
      _detectionStatus = 'Processing error: $e';
      notifyListeners();
    } finally {
      _isProcessing = false;
    }
  }

  // Convert YUV420 camera image to RGB
  img.Image _convertYUV420ToRGB(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int ySize = width * height;
    final int uvSize = width * height ~/ 4;

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        if (yIndex < ySize && uvIndex < uvSize) {
          final int yValue = yPlane[yIndex];
          final int uValue = uPlane[uvIndex];
          final int vValue = vPlane[uvIndex];

          // YUV to RGB conversion
          final int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
          final int g =
              (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128))
                  .round()
                  .clamp(0, 255);
          final int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

          rgbImage.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
    }

    return rgbImage;
  }

  // Parse MoveNet model output [1, 1, 17, 3] format
  List<Pose> _parseModelOutput(List<List<List<List<double>>>> outputData) {
    final landmarks = <PoseLandmark>[];

    // Debug: Print raw model output for first few keypoints
    if (_frameCount % 50 == 0) {
      // Every 50 frames to avoid spam
      debugPrint('🔍 Raw model output sample:');
      for (int i = 0; i < math.min(5, numKeypoints); i++) {
        final double y = outputData[0][0][i][0];
        final double x = outputData[0][0][i][1];
        final double confidence = outputData[0][0][i][2];
        debugPrint('  Keypoint $i: y=$y, x=$x, conf=$confidence');
      }
    }

    // Extract keypoints from [1, 1, 17, 3] output
    for (int i = 0; i < numKeypoints; i++) {
      final double y = outputData[0][0][i][0]; // Y coordinate (0-1)
      final double x = outputData[0][0][i][1]; // X coordinate (0-1)
      final double confidence = outputData[0][0][i][2]; // Confidence score

      landmarks.add(PoseLandmark(x: x, y: y, confidence: confidence));
    }

    // Calculate overall pose confidence (average of visible keypoints)
    final visibleLandmarks =
        landmarks.where((l) => l.confidence > confidenceThreshold).toList();
    final poseConfidence = visibleLandmarks.isNotEmpty
        ? visibleLandmarks.map((l) => l.confidence).reduce((a, b) => a + b) /
            visibleLandmarks.length
        : 0.0;

    // Debug: Show detection details every 50 frames
    if (_frameCount % 50 == 0) {
      debugPrint('🎯 Detection details:');
      debugPrint('  Total landmarks: ${landmarks.length}');
      debugPrint(
        '  Visible landmarks (>${confidenceThreshold.toStringAsFixed(2)}): ${visibleLandmarks.length}',
      );
      debugPrint('  Pose confidence: ${poseConfidence.toStringAsFixed(3)}');
      if (visibleLandmarks.isNotEmpty) {
        debugPrint(
          '  Max confidence: ${landmarks.map((l) => l.confidence).reduce(math.max).toStringAsFixed(3)}',
        );
        debugPrint(
          '  Min confidence: ${landmarks.map((l) => l.confidence).reduce(math.min).toStringAsFixed(3)}',
        );
      }
    }

    // Only return pose if we have sufficient keypoints
    if (visibleLandmarks.isNotEmpty) {
      // Only need 1 keypoint for debugging
      debugPrint(
        '✅ Pose detected with ${visibleLandmarks.length} keypoints, confidence: ${poseConfidence.toStringAsFixed(3)}',
      );
      return [Pose(landmarks: landmarks, confidence: poseConfidence)];
    }

    return [];
  }

  // Calculate angle between three points
  double calculateAngle(
    PoseLandmark point1,
    PoseLandmark point2,
    PoseLandmark point3,
  ) {
    final vector1 = Offset(point1.x - point2.x, point1.y - point2.y);
    final vector2 = Offset(point3.x - point2.x, point3.y - point2.y);

    final dot = vector1.dx * vector2.dx + vector1.dy * vector2.dy;
    final mag1 = math.sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy);
    final mag2 = math.sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy);

    final cosAngle = dot / (mag1 * mag2);
    final angle = math.acos(cosAngle.clamp(-1.0, 1.0));

    return angle * 180 / math.pi;
  }

  // Start video recording
  Future<void> startVideoRecording() async {
    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        _isRecording = true;
        notifyListeners();
      } catch (e, stack) {
        _log('Failed to start video recording: $e');
        debugPrint('Failed to start video recording: $e\n$stack');
      }
    }
  }

  // Stop video recording
  Future<XFile?> stopVideoRecording() async {
    if (_cameraController != null && _isRecording) {
      try {
        final file = await _cameraController!.stopVideoRecording();
        _isRecording = false;
        _recordedVideoFile = file;
        notifyListeners();
        return file;
      } catch (e, stack) {
        _log('Failed to stop video recording: $e');
        debugPrint('Failed to stop video recording: $e\n$stack');
      }
    }
    return null;
  }

  @override
  void dispose() {
    _interpreter?.close();
    _cameraController?.dispose();
    super.dispose();
  }
}
