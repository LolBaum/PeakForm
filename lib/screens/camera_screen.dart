import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:peakform/frosted_glasst_button.dart';

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
    final firstCamera = widget.cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize().then((_) {
      _controller.setFocusMode(FocusMode.auto);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (_isRecording) {
      try {
        final XFile videoFile = await _controller.stopVideoRecording();
        setState(() => _isRecording = false);
        if (mounted) {
          Navigator.of(context).pop(videoFile.path);
        }
      } catch (e) {
        debugPrint("Error on canceling the Recoridng: $e");
      }
    } else {
      try {
        await _controller.startVideoRecording();
        setState(() => _isRecording = true);
      } catch (e) {
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
                    debugPrint("Error on canceling the Recoridng");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Frost-Button gedrückt")),
                    );
                  },
                  child: const Icon(Icons.flash_on, color: Colors.white),
                ),
                FrostedGlassButton(
                  onTap: () => Navigator.of(context).pop(),
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
