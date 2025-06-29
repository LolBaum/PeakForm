import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/vision_detector_views/tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
//import 'package:circular_buffer/circular_buffer.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';

import 'camera_view.dart' as camera_view;

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  RunningAverage Score = RunningAverage();
  //SlidingAverage Score = SlidingAverage(100);
  bool started = false;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    List<TimedPose> recordedPoses = []; // for timestamps

    final poses = await _poseDetector.processImage(inputImage); //hier kommen daten rein
    final Duration timestamp = camera_view.CameraView.stopwatch.elapsed;

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

      for (Pose pose in poses) {

        /*
        for(int i = 0; i < pose.landmarks.entries.length; i++){
          String name = pose.landmarks.entries.elementAt(i).key.name ;

          double x = pose.landmarks.entries.elementAt(i).value.x ;
          double y = pose.landmarks.entries.elementAt(i).value.y ;
          double z = pose.landmarks.entries.elementAt(i).value.z ;

          print("Key:  ${name}");
          print("X: ${x}");
          print("Y: ${y}");
          print("Z: ${z}");
        }
        */


        //print('${pose.landmarks.keys} at (${pose.landmarks.position.x}, ${landmark.position.y})');
        //pose.landmarks.entries.first.value.x
        //print('${pose.landmarks.keys} at (${pose.landmarks.values.}, ${landmark.position.y})');
        //recordedPoses.add(TimedPose(getPoseName(pose.landmarks.entries.toList(), "rightShoulder"), timestamp));


        //ein init und dann aktuallisieren





        // einmal alles ausführen mit der neuen klasse



        //score wird erst berechnet wenn initial pose gefunden wird
        //scores einfluss kann hier mit der certenty gewichtet werden
        //scoreForLAt rise zu score with tolerances ersätzen


        //TODO: Testen wie sich der Average verhällt

        //prozent an korrektheit averagen

        //wrist unter ellenbogeen für winkelunterscheideung
        // bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
        // likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren



      }
      for(TimedPose p in recordedPoses){
        print("${p.pose} detected at ${p.timestamp.inMilliseconds} ms\n");
      }


    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
