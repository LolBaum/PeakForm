import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController controller;
  late Interpreter interpreter;
  bool startDetecting = false;

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });

    loadModel();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: CameraPreview(
        controller
      ),
    );
  }

  Future<void> loadModel() async{
    interpreter = await Interpreter.fromAsset('assets/movenet.tflite');
    print("HIER DAS MODELL:");
    print(interpreter);

    controller.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    try {
      // Convert YUV420 to RGB and resize
      final imgRgb = _convertYUV420ToRGB(image);
      final resized = img.copyResize(imgRgb, width: inputSize, height: inputSize);

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

      // Reshape to [1, 192, 192, 3] tensor
      final input = inputTensor.reshape([1, inputSize, inputSize, 3]);

      // Prepare output tensor for SinglePose [1, 1, 17, 3]
      var output = List.generate(1, (index) =>
          List.generate(1, (index) =>
              List.generate(numKeypoints, (index) =>
                  List.filled(3, 0.0))));

      // Run MoveNet SinglePose Lightning inference
      _interpreter!.run(input, output);

      // Parse output and create poses
      final poses = _parseModelOutput(output);

      _poses = poses;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ MoveNet SinglePose processing error: $e');
      _detectionStatus = 'Processing error: $e';
      notifyListeners();
    }
  }

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
          final int g = (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128)).round().clamp(0, 255);
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
    if (_frameCount % 50 == 0) { // Every 50 frames to avoid spam
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

      landmarks.add(PoseLandmark(
        x: x,
        y: y,
        confidence: confidence,
      ));
    }

    // Calculate overall pose confidence (average of visible keypoints)
    final visibleLandmarks = landmarks.where((l) => l.confidence > confidenceThreshold).toList();
    final poseConfidence = visibleLandmarks.isNotEmpty
        ? visibleLandmarks.map((l) => l.confidence).reduce((a, b) => a + b) / visibleLandmarks.length
        : 0.0;

    // Only return pose if we have sufficient keypoints
    if (visibleLandmarks.isNotEmpty) { // Only need 1 keypoint for debugging
      debugPrint('✅ Pose detected with ${visibleLandmarks.length} keypoints, confidence: ${poseConfidence.toStringAsFixed(3)}');
      return [Pose(landmarks: landmarks, confidence: poseConfidence)];
    }

    return [];
  }

  // Calculate angle between three points
  double calculateAngle(PoseLandmark point1, PoseLandmark point2, PoseLandmark point3) {
    final vector1 = Offset(point1.x - point2.x, point1.y - point2.y);
    final vector2 = Offset(point3.x - point2.x, point3.y - point2.y);

    final dot = vector1.dx * vector2.dx + vector1.dy * vector2.dy;
    final mag1 = math.sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy);
    final mag2 = math.sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy);

    final cosAngle = dot / (mag1 * mag2);
    final angle = math.acos(cosAngle.clamp(-1.0, 1.0));

    return angle * 180 / math.pi;
  }
}
