import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../frosted_glasst_button.dart';
import '../result_screen.dart';
import '../services/auto_save_service.dart';

import '/util/logging_service.dart';
import 'package:flutter/foundation.dart';
import 'pose_detector_view.dart';
import '../constants/constants.dart';
import 'feedback_generator.dart';

final List<FeedbackItem> exampleGoodFeedback = [
  FeedbackItem(label: "Gute Haltung während der Übung", timestamp: "00:10"),
  FeedbackItem(label: "Atmung stimmt"),
  FeedbackItem(label: "Saubere Ausführung"),
];

final List<FeedbackItem> exampleBadFeedback = [
  FeedbackItem(label: "Arme zu weit unten", timestamp: "00:20"),
  FeedbackItem(label: "Ferse hebt sich", timestamp: "00:32"),
  FeedbackItem(label: "Wade nicht angespannt", timestamp: "00:45"),
];

final List<FeedbackItem> exampleTips = [
  FeedbackItem(label: "Versuche den Mittelfuß stärker aufzusetzen"),
  FeedbackItem(label: "Arme während der Übung etwas höher halten"),
];


CameraController? _cameraController;
//----------
XFile? _recordedVideoFile;
bool _isRecording = false;
bool _hasDetectionBeenStarted = false;

CameraController? get cameraController => _cameraController;

// Video recording getters
XFile? get recordedVideoFile => _recordedVideoFile;
bool get isRecording => _isRecording;
//----------
class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
        this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  static final Stopwatch stopwatch = Stopwatch();
  static Timer? stopwatchTimer;
  static String stopwatchTime = '00:00:00';
  static bool isStopwatchRunning = false;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  static bool pose_Stopwatch_activation_bool = false;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  bool _isProcessingEnabled = false;
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool _changingCameraLens = false;

  // FPS tracking variables
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _currentFps = 0.0;

  // Stopwatch variables
//  Stopwatch _stopwatch = Stopwatch();
//  Timer? _stopwatchTimer;
//  String _stopwatchTime = '00:00:00';
//  bool _isStopwatchRunning = false;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }

    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    CameraView.stopwatchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? Center(
                    child: const Text('Changing camera lens'),
                  )
                : CameraPreview(
                    _controller!,
                    child: widget.customPaint,
                  ),
          ),
          _backButton(),
          _switchLiveCameraToggle(),
/*
          _detectionViewModeToggle(),
*/
/*
          _zoomControl(),
*/
/*
          _exposureControl(),
*/
          //_fpsDisplay(),
          _stopwatchDisplay(),
          _captureButton(),
        ],
      ),
    );
  }

  Widget _backButton() => Positioned(
        top: 40,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            //backgroundColor: Colors.black54,
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
              color: Colors.green,
            ),
          ),
        ),
      );

  /*Widget _detectionViewModeToggle() => Positioned(
        bottom: 8,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: widget.onDetectorViewModeChanged,
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.photo_library_outlined,
              size: 25,
              color: lime,
            ),
          ),
        ),
      );*/

  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 8,
        right: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS
                  ? Icons.flip_camera_ios_outlined
                  : Icons.flip_camera_android_outlined,
              size: 25,
              color: Colors.green
            ),
          ),
        ),
      );

  Widget _zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

/*
  Widget _exposureControl() => Positioned(
        top: 45,
        right: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 250,
          ),
          child: Column(children: [
            Container(
              width: 55,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentExposureOffset.toStringAsFixed(1)}x',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await _controller?.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            )
          ]),
        ),
      );
*/

  Widget _fpsDisplay() => Positioned(
        top: 40,
        left: 70,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Text(
            'FPS: ${_currentFps.toStringAsFixed(1)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // Expose the controller globally so recording helpers can use it
      _cameraController = _controller;
      _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    if (!_isProcessingEnabled) return;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    
    // Update FPS calculation
    _updateFps();
    _pose_Stopwatch_activation(); //vlt hier probieren ?
    
    widget.onImage(inputImage);
  }

  void _updateFps() {
    _frameCount++;
    final now = DateTime.now();
    final timeDiff = now.difference(_lastFpsUpdate).inMilliseconds;
    
    // Update FPS every 500ms for smoother display
    if (timeDiff >= 500) {
      _currentFps = (_frameCount * 1000) / timeDiff;
      _frameCount = 0;
      _lastFpsUpdate = now;
      
      // Update UI
      if (mounted) {
        setState(() {});
        //_pose_Stopwatch_activation(); //ganz nasty einfach rein
      }
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  // Stopwatch methods
  void _startStopwatch() {
    if (!CameraView.isStopwatchRunning) {
      CameraView.stopwatch.reset();
      CameraView.stopwatch.start();
      CameraView.isStopwatchRunning = true;
      CameraView.stopwatchTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        if (mounted) {
          setState(() {
            _updateStopwatchDisplay();
          });
        }
      });
    }
  }

  String getFormattedStopwatchTimestamp() {
    final elapsed = CameraView.stopwatch.elapsed;

    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return "$minutes:$seconds:$milliseconds"; // Beispiel: 00:45:23
  }


  void _pose_Stopwatch_activation() {
    if (CameraView.pose_Stopwatch_activation_bool) {
      _startStopwatch();
      //CameraView.pose_Stopwatch_activation_bool = false;
    }
  }

  void _pauseStopwatch() {
    print('🔽 STOPWATCH PAUSED - Elapsed time: ${CameraView.stopwatch.elapsed}');
    if (CameraView.isStopwatchRunning) {
      CameraView.stopwatch.stop();
      CameraView.isStopwatchRunning = false;
      CameraView.stopwatchTimer?.cancel();

      // Save score when workout is paused
      _saveWorkoutScore();
    }
  }

  void _saveWorkoutScore() async {
    print('💾 Attempting to save workout score...');
    print('Current tracked score: ${AutoSaveService.getCurrentScore()}');

    // Save the workout score with duration when stopwatch is paused
    try {
      await AutoSaveService.saveScoreOnPause(CameraView.stopwatch.elapsed);
    } catch (e) {
      print('❌ Could not save workout score: $e');
    }
  }

  void _resetStopwatch() {
    print('🔄 STOPWATCH RESET - Elapsed time: ${CameraView.stopwatch.elapsed}');
    // Save score before resetting
    if (CameraView.stopwatch.elapsed.inSeconds > 0) {
      print('Saving score before reset...');
      _saveWorkoutScore();
    }

    CameraView.stopwatch.reset();
    CameraView.isStopwatchRunning = false;
    CameraView.stopwatchTimer?.cancel();
    CameraView.stopwatchTime = '00:00:00';
    if (mounted) {
      setState(() {});
    }
  }

  void _updateStopwatchDisplay() {
    final elapsed = CameraView.stopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = ((elapsed.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    CameraView.stopwatchTime = '$minutes:$seconds:$milliseconds';
  }

  Widget _stopwatchDisplay() => Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              CameraView.stopwatchTime,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'League Spartan',
              ),
            ),
          ),
        ),
      );

  /*Widget _stopwatchControls() => Positioned(
        top: 150,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Start/Pause button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                *//*child: FloatingActionButton(
                  heroTag: "stopwatch_start_pause",
                  onPressed: CameraView.isStopwatchRunning ? _pauseStopwatch : _startStopwatch, //das hier triggern über eine globale variableüber tdetector view
                  backgroundColor: CameraView.isStopwatchRunning ? Colors.orange : Colors.green,
                  *//**//*child: Icon(
                    CameraView.isStopwatchRunning ? Icons.pause : Icons.play_arrow,
                    size: 25,
                    color: Colors.white,
                  ),*//**//*
                ),*//*
              ),
            ),
            // Reset button

            //Reset Button
            *//*Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: FloatingActionButton(
                  heroTag: "stopwatch_reset",
                  onPressed: _resetStopwatch,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.stop,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),*//*
          ],
        ),
      );*/

  Widget _captureButton() => Positioned(
    bottom: 40,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FrostedGlassButton(
          onTap: () async {
            // Toggle processing (start/stop workout)
            setState(() {
              _isProcessingEnabled = !_isProcessingEnabled;
            });
            if(!_isProcessingEnabled){
              _pauseStopwatch();
              final List<String> summarySentences = getSummaryFeedback();
              for (final sentence in summarySentences) {
                tips.add(FeedbackItem(label: sentence));
              }

              // Finish recording and obtain the file
              final recordedFile = await stopVideoRecording();
              final String? videoPath = recordedFile?.path;

              if (!mounted) return;

              // Navigate to results screen with the recorded video
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    goodFeedback: goodFeedback,
                    badFeedback: badFeedback,
                    tips: tips,
                    videoPath: videoPath, // Could be null if recording failed
                    score: (score * 100).round(),
                  ),
                ),
              );
              _resetStopwatch();
            } else{
              _startStopwatch();
              await startVideoRecording();
            }
          },
          child: Center(
            child: Text(
              _isProcessingEnabled ? 'Stopp' : 'Start',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

        ),
      ),
    ),
  );

  void _log(String message) {
    try {
      LoggingService.instance.i(message);
    } catch (e) {
      debugPrint('PoseDetectionProvider: $message');
    }
  }

  // Start video recording
  Future<void> startVideoRecording() async {
    if (_cameraController == null || _isRecording) return;

    try {
      // 1. Stop any existing image stream (required by the camera plugin).
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }

      // 2. Start recording **and** request frames via the callback so pose
      //    detection can continue while the video is being captured.
      await _cameraController!.startVideoRecording(
        onAvailable: (cameraImage) {
          // Re-use the same processing pipeline that live mode uses.
          _processCameraImage(cameraImage);
        },
      );

      _isRecording = true;
    } catch (e, stack) {
      _log('Failed to start video recording: $e');
      debugPrint('Failed to start video recording: $e\n$stack');
    }
  }

  // Stop video recording
  Future<XFile?> stopVideoRecording() async {
    if (_cameraController != null && _isRecording) {
      try {
        final file = await _cameraController!.stopVideoRecording();
        _isRecording = false;
        _recordedVideoFile = file;
        //notifyListeners();
        return file;
      } catch (e, stack) {
        _log('Failed to stop video recording: $e');
        debugPrint('Failed to stop video recording: $e\n$stack');
      }
    }
    return null;
  }

}



