import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/pose_detection_provider.dart';
import '../widgets/pose_painter.dart';

class PoseDetectionScreen extends StatefulWidget {
  const PoseDetectionScreen({super.key});

  @override
  State<PoseDetectionScreen> createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
      _initializeCamera();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to detect poses using MoveNet. Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final provider = Provider.of<PoseDetectionProvider>(context, listen: false);
    await provider.initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    // Check if platform supports camera
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MoveNet Pose Detection'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 24),
                Text(
                  'Mobile Device Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'MoveNet pose detection requires a mobile device with camera access. Please run this app on:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  '📱 Android device\n🍎 iOS device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Web browsers do not support camera-based pose detection with TensorFlow Lite.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoveNet Pose Detection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !_permissionGranted
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Camera permission required'),
                ],
              ),
            )
          : Consumer<PoseDetectionProvider>(
              builder: (context, provider, child) {
                if (!provider.isCameraInitialized) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing MoveNet model...'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          // Camera preview - full screen natural view
                          Positioned.fill(
                            child: CameraPreview(provider.cameraController!),
                          ),
                          // Pose overlay
                          if (provider.poses.isNotEmpty)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: PosePainter(
                                  poses: provider.poses,
                                  imageSize: Size(
                                    provider.cameraController!.value.previewSize!.height,
                                    provider.cameraController!.value.previewSize!.width,
                                  ),
                                ),
                              ),
                            ),
                          // Status overlay
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                provider.detectionStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Pose count and confidence
                          if (provider.poses.isNotEmpty)
                            Positioned(
                              bottom: 100,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Poses: ${provider.poses.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (provider.poses.isNotEmpty)
                                      Text(
                                        'Confidence: ${(provider.poses.first.confidence * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Control buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: provider.isCameraInitialized
                              ? (provider.isDetecting
                                  ? provider.stopDetection
                                  : provider.startDetection)
                              : null,
                          icon: Icon(provider.isDetecting ? Icons.stop : Icons.play_arrow),
                          label: Text(provider.isDetecting ? 'Stop Detection' : 'Start Detection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: provider.isDetecting ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            minimumSize: const Size(200, 50),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 