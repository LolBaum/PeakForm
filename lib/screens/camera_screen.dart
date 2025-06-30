import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/frosted_glasst_button.dart';
import 'package:fitness_app/util/logging_service.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    LoggingService.instance
        .i('CameraScreen initialized with ${widget.cameras.length} cameras');
    final firstCamera = widget.cameras.first;
    LoggingService.instance
        .i('Using camera: ${firstCamera.name} (${firstCamera.lensDirection})');
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      LoggingService.instance.i('Camera controller initialized successfully');
      _controller.setFocusMode(FocusMode.auto);
    });
  }

  @override
  void dispose() {
    LoggingService.instance.i('CameraScreen disposed');
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_controller.value.isInitialized) {
      LoggingService.instance
          .i('Cannot toggle recording - camera not initialized');
      return;
    }
    if (_isRecording) {
      LoggingService.instance.i('Stopping video recording');
      try {
        final XFile videoFile = await _controller.stopVideoRecording();
        setState(() => _isRecording = false);
        LoggingService.instance
            .i('Video recording stopped successfully: ${videoFile.path}');
        if (mounted) {
          Navigator.of(context).pop(videoFile.path);
        }
      } catch (e) {
        LoggingService.instance.i('Error stopping video recording: $e');
        debugPrint("Error on canceling the Recoridng: $e");
      }
    } else {
      LoggingService.instance.i('Starting video recording');
      try {
        await _controller.startVideoRecording();
        setState(() => _isRecording = true);
        LoggingService.instance.i('Video recording started successfully');
      } catch (e) {
        LoggingService.instance.i('Error starting video recording: $e');
        debugPrint("Error on start of the recording: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [CameraPreview(_controller), _buildOverlayUI()],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildOverlayUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FrostedGlassButton(
                  onTap: () {
                    LoggingService.instance.i('Flash button pressed');
                    debugPrint("Error on canceling the Recoridng");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Frost-Button gedrückt")),
                    );
                  },
                  child: const Icon(Icons.flash_on, color: Colors.white),
                ),
                FrostedGlassButton(
                  onTap: () {
                    LoggingService.instance
                        .i('Close button pressed - exiting camera screen');
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            _buildRecordingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton() {
    if (_isRecording) {
      return FrostedGlassButton(
        onTap: _toggleRecording,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            "Finish Recording",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _toggleRecording,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
          ),
        ),
      );
    }
  }
}
