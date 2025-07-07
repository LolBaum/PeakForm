import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_app/providers/pose_detection_provider.dart';
import 'package:fitness_app/widgets/frosted_glasst_button.dart';
import 'package:fitness_app/widgets/pose_painter.dart';
import 'package:fitness_app/constants/constants.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

/// Pose Detection Screen State
///
/// This state is responsible for managing the state of the Pose Detection Screen.
/// It also uses the PoseDetectionProvider to manage the camera and pose detection.
/// It also uses the PosePainter to draw the poses on the camera preview.
/// It also uses the FrostedGlassButton to create a frosted glass button.
class _CameraScreenState extends State<CameraScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    LoggingService.instance.i('CameraScreen initialized');
    // Reset detection state so the button always shows 'Start Recording'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PoseDetectionProvider>(context, listen: false);
      provider.stopDetection();
    });
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      _requestPermissions(context);
    }
  }

  /// Request Permissions
  ///
  /// This method is responsible for requesting permissions to use the camera.
  Future<void> _requestPermissions(BuildContext context) async {
    LoggingService.instance.i('Requesting camera permissions');
    final status = await Permission.camera.request();
    if (status.isGranted) {
      LoggingService.instance.i('Camera permission granted');
      setState(() {
        _permissionGranted = true;
      });
      _initializeCamera();
    } else {
      LoggingService.instance.i('Camera permission denied: $status');
      _showPermissionDialog();
    }
  }

  /// Show Permission Dialog
  ///
  /// This method is responsible for showing a dialog to the user to request permissions.
  /// It uses the PermissionHandler to request permissions.
  void _showPermissionDialog() {
    final translation = AppLocalizations.of(context)!;
    LoggingService.instance.i('Showing permission dialog to user');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translation.camera_permission_required),
        content: Text(
          translation.camera_permission_required_description,
        ),
        actions: [
          TextButton(
            onPressed: () {
              LoggingService.instance.i('User cancelled permission request');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              LoggingService.instance
                  .i('User opened app settings for permission');
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  /// Initialize Camera
  ///
  /// This method is responsible for initializing the camera.
  /// It uses the PoseDetectionProvider to initialize the camera.
  Future<void> _initializeCamera() async {
    LoggingService.instance.i('Initializing camera through provider');
    final provider = Provider.of<PoseDetectionProvider>(context, listen: false);
    await provider.initializeCamera();
    LoggingService.instance.i('Camera initialization completed');
  }

  Future<void> _onStartStopDetection(PoseDetectionProvider provider) async {
    if (!provider.isCameraInitialized) return;
    if (provider.isDetecting) {
      provider.stopDetection();
      final file = await provider.stopVideoRecording();
      if (!mounted) return;
      String? videoPath = file?.path;
      Navigator.pushNamed(
        context,
        '/result',
        arguments: videoPath,
      );
    } else {
      provider.startDetection();
      await provider.startVideoRecording();
      if (!mounted) return;
    }
  }

  /// Build
  ///
  /// This method is responsible for building the Pose Detection Screen.
  /// It uses the PoseDetectionProvider to manage the camera and pose detection.
  @override
  Widget build(BuildContext context) {
    // Check if platform supports camera
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return const _PermissionDeniedView();
    }

    return Scaffold(
      body: !_permissionGranted
          ? const _PermissionDeniedView()
          : Consumer<PoseDetectionProvider>(
              builder: (context, provider, child) {
                if (!provider.isCameraInitialized) {
                  return const _LoadingView();
                }
                return Stack(
                  children: [
                    _CameraPreviewWithOverlays(provider: provider),
                    if (!provider.isDetecting &&
                        !provider.hasDetectionBeenStarted)
                      _StatusBar(provider: provider),
                    // Overlay close button at top right, aligned with status bar
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          16, // 16px top padding after SafeArea
                      right: 15, // 15px right padding
                      child: FrostedGlassButton(
                        label: '',
                        onTap: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          'assets/icons/close.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    _StartStopButton(
                      provider: provider,
                      onStartStop: () => _onStartStopDetection(provider),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

//*****COMPONENTS***** //
/// Camera Preview with Overlays
///
/// This widget is responsible for displaying the camera preview with overlays.
/// It uses the PoseDetectionProvider to manage the camera and pose detection.
/// It also uses the PosePainter to draw the poses on the camera preview.
class _CameraPreviewWithOverlays extends StatefulWidget {
  final PoseDetectionProvider provider;
  const _CameraPreviewWithOverlays({required this.provider});

  @override
  State<_CameraPreviewWithOverlays> createState() =>
      _CameraPreviewWithOverlaysState();
}

class _CameraPreviewWithOverlaysState
    extends State<_CameraPreviewWithOverlays> {
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  Offset? _focusPoint;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    final controller = widget.provider.cameraController!;
    controller.getMaxZoomLevel().then((maxZoom) {
      controller.getMinZoomLevel().then((minZoom) {
        setState(() {
          _currentZoom = minZoom;
          _baseZoom = minZoom;
        });
      });
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }

  void _showFocusIndicator(Offset localPosition) {
    setState(() {
      _focusPoint = localPosition;
    });
    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _focusPoint = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.provider.cameraController!;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) async {
                final box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final x = localPosition.dx / box.size.width;
                final y = localPosition.dy / box.size.height;
                _showFocusIndicator(localPosition);
                try {
                  await controller.setFocusPoint(Offset(x, y));
                  await controller.setFocusMode(FocusMode.auto);
                } catch (e) {
                  debugPrint('Focus not supported: $e');
                }
              },
              child: Listener(
                onPointerSignal: (event) {},
                onPointerDown: (_) {
                  _baseZoom = _currentZoom;
                },
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseZoom = _currentZoom;
                  },
                  onScaleUpdate: (details) async {
                    if (details.pointerCount == 2) {
                      final minZoom = await controller.getMinZoomLevel();
                      final maxZoom = await controller.getMaxZoomLevel();
                      double newZoom = (_baseZoom * details.scale).clamp(
                        minZoom,
                        maxZoom,
                      );
                      await controller.setZoomLevel(newZoom);
                      setState(() => _currentZoom = newZoom);
                    }
                  },
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 20,
              top: _focusPoint!.dy - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
              ),
            ),
          if (widget.provider.poses.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: PosePainter(
                  poses: widget.provider.poses,
                  imageSize: Size(
                    controller.value.previewSize!.height,
                    controller.value.previewSize!.width,
                  ),
                ),
              ),
            ),
          if (widget.provider.poses.isNotEmpty)
            _PoseCountOverlay(provider: widget.provider),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final PoseDetectionProvider provider;
  const _StatusBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final showStatusBar =
        !provider.isDetecting && !provider.hasDetectionBeenStarted;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showStatusBar)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 76),
                    child: FrostedGlassButton(
                      label: provider.detectionStatus,
                      onTap: () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartStopButton extends StatelessWidget {
  final PoseDetectionProvider provider;
  final VoidCallback onStartStop;
  const _StartStopButton({required this.provider, required this.onStartStop});

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FrostedGlassButton(
            onTap: onStartStop,
            label: provider.isDetecting
                ? translation.recording_finish
                : translation.recording_start,
          ),
        ),
      ),
    );
  }
}

class _PoseCountOverlay extends StatelessWidget {
  final PoseDetectionProvider provider;
  const _PoseCountOverlay({required this.provider});

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    return Positioned(
      bottom: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha((255 * 0.8).toInt()),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translation.pose_count(provider.poses.length),
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (provider.poses.isNotEmpty)
              Text(
                translation.pose_confidence(
                    (provider.poses.first.confidence * 100).toStringAsFixed(1)),
                style:
                    const TextStyle(color: AppColors.onPrimary, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context) {
    final translation = AppLocalizations.of(context)!;
    return Center(child: Text(translation.pose_permission_required));
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
