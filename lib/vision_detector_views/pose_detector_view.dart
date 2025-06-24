import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/vision_detector_views/tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

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
  var _cameraLensDirection = CameraLensDirection.front;
  //double Score = 0;
  RunningAverage Score = RunningAverage();

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
        recordedPoses.add(TimedPose(getPoseName(pose.landmarks.entries.toList(), "rightShoulder"), timestamp));

        late Vector2 r_Shoulder;
        late Vector2 r_Elbow;
        late Vector2 r_Wrist;
        late Vector2 r_Hip;

        Vector2? vec_rShoulder = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightShoulder");
        if(vec_rShoulder != null){
          r_Shoulder = Vector2(vec_rShoulder.x, vec_rShoulder.y);
        } else {
          print("Fehler beim erkennen der r Schulter");
        }

        Vector2? vec_rElbow = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightElbow");
        if(vec_rElbow != null){
          r_Elbow = Vector2(vec_rElbow.x, vec_rElbow.y);
        } else {
          print("Fehler beim erkennen des r Ellenbogens");
        }

        Vector2? vec_rWrist = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightWrist");
        if(vec_rWrist != null){
          r_Wrist = Vector2(vec_rWrist.x, vec_rWrist.y);
        } else {
          print("Fehler beim erkennen des r Handgelenks");
        }

        Vector2? vec_rHip = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightHip");
        if(vec_rHip != null){
          r_Hip = Vector2(vec_rHip.x, vec_rHip.y);
        } else {
          print("Fehler beim erkennen der r Hüfte");
        }


        late Vector2 l_Shoulder;
        late Vector2 l_Elbow;
        late Vector2 l_Wrist;
        late Vector2 l_Hip;


        Vector2? vec_lShoulder = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftShoulder");
        if(vec_lShoulder != null){
          l_Shoulder = Vector2(vec_lShoulder.x, vec_lShoulder.y);
        } else {
          print("Fehler beim erkennen der l Schulter");
        }

        Vector2? vec_lElbow = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftElbow");
        if(vec_lElbow != null){
          l_Elbow = Vector2(vec_lElbow.x, vec_lElbow.y);
        } else {
          print("Fehler beim erkennen des l Ellenbogens");
        }

        Vector2? vec_lWrist = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftWrist");
        if(vec_lWrist != null){
          l_Wrist = Vector2(vec_lWrist.x, vec_lWrist.y);
        } else {
          print("Fehler beim erkennen des l Handgelenks");
        }

        Vector2? vec_lHip = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftHip");
        if(vec_lHip != null){
          l_Hip = Vector2(vec_lHip.x, vec_lHip.y);
        } else {
          print("Fehler beim erkennen der l Hüfte");
        }


        bool right_wesh = vec_rWrist != null && vec_rElbow != null && vec_rShoulder != null && vec_rHip != null;
        bool left_wesh = vec_lWrist != null && vec_lElbow != null && vec_lShoulder != null && vec_lHip != null;

        //für left side erweitern die null safety
        if (right_wesh && left_wesh) {
          //Score = Score + (scoreForLateralRaise_Arm(computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist)))*(scoreForLateralRaise_Hip(computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip)));
          //print(Score);
          double temp_score_r = scoreForLateralRaise_Arm(computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist))*scoreForLateralRaise_Hip(computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip));
          Score.add(temp_score_r);
          double temp_score_l = scoreForLateralRaise_Arm(computeJointAngle_2d(a: l_Shoulder, b: l_Elbow, c: l_Wrist))*scoreForLateralRaise_Hip(computeJointAngle_2d(a: l_Elbow, b: l_Shoulder, c: l_Hip));
          Score.add(temp_score_l);
          print(Score.average);
          print("ARM:");
          print(computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist));
          print("HIP");
          print(computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip));
        }

        //TODO: Testen wie sich der Average verhällt



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
