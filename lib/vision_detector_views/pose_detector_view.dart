import 'package:camera/camera.dart';
//import 'package:flutter/cupertino.dart';
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
  //var _cameraLensDirection = CameraLensDirection.back;
  var _cameraLensDirection = CameraLensDirection.front;


  Pose_analytics analytics = Pose_analytics();
  LAR_Evaluation eval = LAR_Evaluation();

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
                  "Elbow Angle: ${lateral_rises.wes_buffer_average_l}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Moving Direction: ${lateral_rises.dir}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "average: ${lateral_rises.esh_buffer_average_l}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "uFB: ${lateral_rises.esh_dir_change_upper_feedback}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "dFB: ${lateral_rises.esh_dir_change_downer_feedback}",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                /*
                lateral_rises.dir == direction.up ? Text(
                  "Arm ist not straight!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ) : SizedBox.shrink(),

                 */
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

    //List<TimedPose> recordedPoses = []; // for timestamps

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

        analytics.set_new_pose(pose);
        analytics.get_lr_wesh_points();
        analytics.compute_wesh_joints();


        //bei pausieren wieder in den init zustand bringen
        if(!camera_view.CameraView.pose_Stopwatch_activation_bool){
          eval.triggered = false;
        }
        if(analytics.is_wesh()) {
          eval.session(!camera_view.CameraView.pose_Stopwatch_activation_bool,
              analytics.r_wes_angl, analytics.r_esh_angl, analytics.l_wes_angl,
              analytics.l_esh_angl);
          camera_view.CameraView.pose_Stopwatch_activation_bool =
              eval.triggered;
        }

        if(camera_view.CameraView.pose_Stopwatch_activation_bool){
          //lateral_rises.update_direction_lr('l', lateral_rises.esh_buffer_average_l);
          //lateral_rises.update_direction_lr('r', lateral_rises.esh_buffer_average_r);
          lateral_rises.update_direction_lr('beide', (lateral_rises.esh_buffer_average_l + lateral_rises.esh_buffer_average_r)/2);

          //lateral_rises.checkLateralRaiseCycle(analytics.l_wsh_angl, analytics.r_wsh_angl);
          lateral_rises.checkElbowAngle(analytics.l_wes_angl, analytics.r_wes_angl);

          lateral_rises.update_esh_angles(analytics.l_esh_angl, analytics.r_esh_angl);
        }

        /*
        Todo:
        //durchgängige arm kontrolle und score
        //notes vom handy holen

        //full into KI mit bewegungsablauf oder noch kontrolle haben ?

        //nicht nur wrist zu elbow to shoulder sondern auch richtigen winkel zum oberkörper finden (der wird vlt immer über 100 sein)
        // dann bewertung pro frame wenn man eine abfolge erreicht aber denn auch nicht von der abfolge zurück geht
        // also eine sequenz vin winkeln die gemacht werden muss

        //pro übung eine liste an toleranzen und winkel erstellen
        //unterscheidung linker und rechter arm
        //klassen so verallgemeinern das man mehrere übungen damit machen kann


        */

        //score wird erst berechnet wenn initial pose gefunden wird
        //scores einfluss kann hier mit der certenty gewichtet werden
        //scoreForLAt rise zu score with tolerances ersätzen
        // bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
        // likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren



        //todo store min / max average angle.
        //if difference ~5 away from value -> change direction

      }
      //for(TimedPose p in recordedPoses){
        //print("${p.pose} detected at ${p.timestamp.inMilliseconds} ms\n");
      //}


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
