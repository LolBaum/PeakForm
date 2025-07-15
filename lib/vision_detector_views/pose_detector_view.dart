import 'package:camera/camera.dart';
//import 'package:flutter/cupertino.dart';
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
  var _cameraLensDirection = CameraLensDirection.front; //richtung geändert

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

  General_pose_analytics general_analytics = General_pose_analytics();
  General_Pose_init t_pose = General_Pose_init(0.7);
  General_MovementReference lar = General_MovementReference(1.0, ['r_wes', 'r_esh', 'r_wsh', 'l_wes', 'l_esh', 'l_wsh'], [false, true, true, false, true, true]);
  //liste zum adden hier einfügen... vlt beim init nur feedback ändern...

  Joint_Angle r_wes = Joint_Angle(first: "rightShoulder", second: "rightElbow", third: "rightWrist");
  Joint_Angle r_esh = Joint_Angle(first: "rightHip", second: "rightShoulder", third: "rightElbow");
  Joint_Angle r_wsh = Joint_Angle(first: "rightHip", second: "rightShoulder", third: "rightWrist");

  Joint_Angle l_wes = Joint_Angle(first: "leftShoulder", second: "leftElbow", third: "leftWrist");
  Joint_Angle l_esh = Joint_Angle(first: "leftHip", second: "leftShoulder", third: "leftElbow");
  Joint_Angle l_wsh = Joint_Angle(first: "leftHip", second: "leftShoulder", third: "leftWrist");

  bool all_angls = false;


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
            //color: Colors.black.withOpacity(0.5),
            color: Color.fromARGB(128, 0, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*
                Text(
                  lateral_rises.dir==direction.up ? "Beide Arme oben!" : "Arme unten",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),*/
                Text(
                  "name: ${lar.debug_name}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "angle: ${lar.debug_angle}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "count: ${lar.debug_counter}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "down?: ${lar.debug_was_it_down}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Feedback: ${lar.debug_feedback}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "dir: ${lar.debug_dir}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final poses = await _poseDetector.processImage(inputImage); //hier kommen daten rein

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

        //wenn kein fehler denn kein posenet und kein score
        r_wes.angle = general_analytics.get_angles(pose, r_wes); //wert actuallisieren
        r_esh.angle = general_analytics.get_angles(pose, r_esh);
        r_wsh.angle = general_analytics.get_angles(pose, r_wsh);

        l_wes.angle = general_analytics.get_angles(pose, l_wes);
        l_esh.angle = general_analytics.get_angles(pose, l_esh);
        l_wsh.angle = general_analytics.get_angles(pose, l_wsh);

        all_angls = r_wes.detected & r_esh.detected & r_wsh.detected & l_wes.detected & l_esh.detected & l_wsh.detected;


        //bei pausieren wieder t_posen zustand bringen
        if(!camera_view.CameraView.pose_Stopwatch_activation_bool){
          t_pose.triggered = false;
        }
        //initialisierung am anfang oder wenn noch nicht
        if(all_angls && !t_pose.triggered) {

          t_pose.pose_detected = true; //fals es mal false war soll es testen
          t_pose.add_values_4_init_pose_starter(!camera_view.CameraView.pose_Stopwatch_activation_bool, r_wes.angle, 180, 25);
          t_pose.add_values_4_init_pose_starter(!camera_view.CameraView.pose_Stopwatch_activation_bool, r_esh.angle, 95, 20);

          t_pose.add_values_4_init_pose_starter(!camera_view.CameraView.pose_Stopwatch_activation_bool, l_wes.angle, 180, 25);
          t_pose.add_values_4_init_pose_starter(!camera_view.CameraView.pose_Stopwatch_activation_bool, l_esh.angle, 95, 20);
          t_pose.apply();

          camera_view.CameraView.pose_Stopwatch_activation_bool = t_pose.triggered;

          if(t_pose.triggered){
            lar = General_MovementReference(1.0, ['r_wes', 'r_esh', 'r_wsh', 'l_wes', 'l_esh', 'l_wsh'], [false, true, true, false, true, true]);
          }
        }
        if(camera_view.CameraView.pose_Stopwatch_activation_bool){
          //hier beginnt eine neue session
          //neue werte abspeichern und feedbach abspeichern

          lar.session_started = true;
          lar.update_joint_Buffer('r_wes', r_wes.angle);
          lar.update_joint_Buffer('r_esh', r_esh.angle);
          //lar.update_joint_Buffer('r_wsh', r_wes.angle);
          lar.update_joint_Buffer('l_wes', l_wes.angle);
          lar.update_joint_Buffer('l_esh', l_esh.angle);
          //lar.update_joint_Buffer('l_wsh', l_wes.angle);

          lar.checkStatic_execution('r_wes', 180, 30, 5, 85, 1);
          lar.checkStatic_execution('l_wes', 180, 30, 5, 85, 1);

          //mischregister für repeating machen
          //lar.checkRepeating_execution('r_esh', 85, 20, 20, 25, 10, [-6, 2, 6, 15, 17], [10, 15, 20, 25]);
          lar.checkRepeating_execution('l_esh', 85, 20, 20, 25, 10, [-6, 2, 6, 15, 17], [10, 15, 20, 25]);

          /*
          if(lateral_rises.neg_feedback){
            lateral_rises.got_you_in_4k(inputImage);
          }
          */


        } else {
          //camera detection ist aus und eine session war noch an => abgeschlossen
          //if(lateral_rises.session_started == true){ // oder oben bei t_pose.triggered = false;
          if(lar.session_started == true){
            //sesion wurde beendet
            //für den Score die letzten x sekunden entfernen die man zum abbrechen braucht;
            // und die letzten feedbacks dazu auch
            //feedbackliste abspeichern und score und so
            //lateral_rises.session_started == false;
            lar.session_started == false;
          }
        }
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
