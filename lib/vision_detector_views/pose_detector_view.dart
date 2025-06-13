import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/vision_detector_views/tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';

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
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

      double Score = 0;

      for (Pose pose in poses) {
        print("!!!!!!!!!!!!!");

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
        //erstellung der Vectoren für Shoulder,Elbow,Wirst rechts
        late Vector3 r_Shoulder;
        late Vector3 r_Elbow;
        late Vector3 r_Wrist;


        Vector3? vec_rShoulder = getLandmarkCoordinates(pose.landmarks.entries, "rightShoulder");
        if(vec_rShoulder != null){
          r_Shoulder = Vector3(vec_rShoulder.x, vec_rShoulder.y, vec_rShoulder.z);
        } else {
          print("Fehler beim erkennen der Schulter");
        }

        Vector3? vec_rElbow = getLandmarkCoordinates(pose.landmarks.entries, "rightElbow");
        if(vec_rElbow != null){
          r_Elbow = Vector3(vec_rElbow.x, vec_rElbow.y, vec_rElbow.z);
        } else {
          print("Fehler beim erkennen des Ellenbogens");
        }

        Vector3? vec_rWrist = getLandmarkCoordinates(pose.landmarks.entries, "rightWrist");
        if(vec_rWrist != null){
          r_Wrist = Vector3(vec_rWrist.x, vec_rWrist.y, vec_rWrist.z);
        } else {
          print("Fehler beim erkennen des Handgelenks");
        }

        print("Punkte!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

        Score = Score + scoreForLateralRaise(computeJointAngle(a: r_Shoulder, b: r_Elbow, c: r_Wrist));

        print(Score);


        /*
          leftShoulder,
          rightShoulder,
          leftElbow,
          rightElbow,
          leftWrist,
          rightWrist,

          leftPinky,
          rightPinky,
          leftIndex,
          rightIndex,
          leftThumb,
          rightThumb,

          leftHip,
          rightHip,
          leftKnee,
          rightKnee,
          leftAnkle,
          rightAnkle,
          leftHeel,
          rightHeel,
          leftFootIndex,
          rightFootIndex

         */

      }

      //print('${pose.landmarks.keys} at (${pose.landmarks.position.x}, ${landmark.position.y})');

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
