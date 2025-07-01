import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/vision_detector_views/tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:circular_buffer/circular_buffer.dart';

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
  //SlidingAverage Score = SlidingAverage(10);
  bool started = false;

  var bufferShoulder_r = CircularBuffer<double>(10);
  Lateral_rises exercise = Lateral_rises();
  MovementReference lateral_rises = MovementReference(180, 10, 10, 1.0);

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DetectorView(
          title: 'Pose Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lateral_rises.dir==direction.up ? "Beide Arme oben!" : "Arme unten",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  "Wiederholungen: ${lateral_rises.reps}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Elbow Angle: ${lateral_rises.secondary_angle}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Right Lateral Angle: ${lateral_rises.angle}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Moving Direction: ${lateral_rises.dir}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                lateral_rises.dir == direction.up ? Text(
                  "Arm ist not straight!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ) : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //int reps = 0;
  // bool armsUp = false;
  // double lateralAngle_r = 0;
  // double elbowAngle_r = 0;
  // double min_r = 180;
  // double max_r = 0;
  // direction dir = direction.down;
  // bool direction_changed = false;
  // DateTime? _lastActionTime;
  // final Duration _cooldown = Duration(milliseconds: 250);
  // int bentArm_count = 0;
  // bool arm_bent = false;





  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    List<TimedPose> recordedPoses = []; // for timestamps

    final poses = await _poseDetector.processImage(inputImage); //hier kommen daten rein
    //final Duration timestamp = camera_view.CameraView.stopwatch.elapsed;

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

        //recordedPoses.add(TimedPose(getPoseName(pose.landmarks.entries.toList(), "rightShoulder"), timestamp));

        Vector2 getLandmarkOrError(String landmarkName, String errorText) {
          Vector2? vec = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), landmarkName);
          if (vec == null) {
            throw Exception(errorText);
          }
          return vec;
        }

        //to be removed
        late Vector2 r_Shoulder;
        late Vector2 r_Elbow;
        late Vector2 r_Wrist;
        late Vector2 r_Hip;

        r_Shoulder = getLandmarkOrError("rightShoulder", "Fehler beim Erkennen der rechten Schulter");
        r_Elbow    = getLandmarkOrError("rightElbow", "Fehler beim Erkennen des rechten Ellenbogens");
        r_Wrist    = getLandmarkOrError("rightWrist", "Fehler beim Erkennen des rechten Handgelenks");
        r_Hip      = getLandmarkOrError("rightHip", "Fehler beim Erkennen der rechten Hüfte");
        exercise.set_new_pose(pose);
        exercise.get_lr_wesh();
        exercise.compute_wesh_joints();
        //print("P_Score: " + Score.average.toString());
        camera_view.CameraView.pose_Stopwatch_activation_bool = exercise.intolerance_t_pose_starter();
        //gucken wie man diesen ausdruck bekommt und dann testen
        if(camera_view.CameraView.pose_Stopwatch_activation_bool){
          if(exercise.evaluation(Score)){
            exercise.state_change();
          }
        }



        //ein init und dann aktuallisieren

        late Vector2 l_Shoulder;
        late Vector2 l_Elbow;
        late Vector2 l_Wrist;
        late Vector2 l_Hip;

        l_Shoulder = getLandmarkOrError("leftShoulder", "Fehler beim Erkennen der linken Schulter");
        l_Elbow = getLandmarkOrError("leftElbow", "Fehler beim Erkennen des linken Ellenbogens");
        l_Wrist = getLandmarkOrError("leftWrist", "Fehler beim Erkennen des linken Handgelenks");
        l_Hip = getLandmarkOrError("leftHip", "Fehler beim Erkennen der linken Hüfte");

        //score wird erst berechnet wenn initial pose gefunden wird
        //scores einfluss kann hier mit der certenty gewichtet werden
        //scoreForLAt rise zu score with tolerances ersätzen

        double r_wes_angl = computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist);
          double r_esh_angl = computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip);
          double l_wes_angl = computeJointAngle_2d(a: l_Shoulder, b: l_Elbow, c: l_Wrist);
          double l_esh_angl = computeJointAngle_2d(a: l_Elbow, b: l_Shoulder, c: l_Hip);

          //die sind besser als esh
          double l_wsh_angl = computeJointAngle_2d(a: l_Hip, b: l_Shoulder, c: l_Wrist);
          double r_wsh_angl = computeJointAngle_2d(a: r_Hip, b: r_Shoulder, c: r_Wrist);


        if (!started){
            double high_intolerance_wesh_r = scorewithTolerances(180, r_wes_angl, 20.0) * scorewithTolerances(90.0, r_wsh_angl, 30.0);
            double high_intolerance_wesh_l = scorewithTolerances(180, l_wes_angl, 20.0) * scorewithTolerances(90.0, l_wsh_angl, 30.0);
            print("intolerance " + (high_intolerance_wesh_l+high_intolerance_wesh_r).toString());
            if((high_intolerance_wesh_l+high_intolerance_wesh_r) > 1.2){
              started = true;
              //camera_view.CameraView._startStopwatch();
              camera_view.CameraView.isStopwatchRunning = true;
            }
          }

          if(started){
            double temp_score_r_wesh = (scorewithTolerances(180, r_wes_angl, 25.0) + scorewithTolerances(90.0, r_wsh_angl, 45.0))/2; //erstmal nur hips
            Score.add(temp_score_r_wesh);
            double temp_score_l_wesh = (scorewithTolerances(180, l_wes_angl, 25.0) + scorewithTolerances(90.0, l_wsh_angl, 45.0))/2; //erstmal nur hips
            Score.add(temp_score_l_wesh);

            print("P_Score: " + (Score.average).toString());
            //print("r_ARM (wes): " + r_wes_angl.toString());
            print("ARM_UP: " + lateral_rises.dir.toString());
            print("r_HIP_WRIST_SHOULDER (wsh): " + r_wsh_angl.toString());
            print("l_HIP_WRIST_SHOULDER (wsh): " + l_wsh_angl.toString());
            //print("r_HIP (esh): " + r_esh_angl.toString());

            lateral_rises.checkLateralRaiseCycle(l_wsh_angl, r_wsh_angl);
            lateral_rises.checkElbowAngle(l_wes_angl, r_wes_angl);

          }


          lateral_rises.update_angles(computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip), r_wes_angl);



          //todo store min / max average angle.
          //if difference ~5 away from value -> change direction


        //TODO: Testen wie sich der Average verhällt

        //prozent an korrektheit averagen

        //wrist unter ellenbogeen für winkelunterscheideung
        // bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
        // likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren



      }
      for(TimedPose p in recordedPoses){
        //print("${p.pose} detected at ${p.timestamp.inMilliseconds} ms\n");
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
