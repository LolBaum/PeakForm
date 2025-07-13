import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../exercises/bicep_curls.dart';
import 'tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:circular_buffer/circular_buffer.dart';

import 'detector_view.dart';
import '../exercises/lateral_raise.dart';
import 'movement_reference.dart';
import '../painters/pose_painter.dart';
import '../services/auto_save_service.dart';
import '../services/performance_service.dart';

import 'exerciseType.dart';
import 'camera_view.dart' as camera_view;
import 'direction.dart';

class PoseDetectorView extends StatefulWidget {
  final ExerciseType exerciseType;
  PoseDetectorView({required this.exerciseType});

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
  var _cameraLensDirection = CameraLensDirection.back;

  Pose_analytics analytics = Pose_analytics();
  LAR_Evaluation eval = LAR_Evaluation();

  var bufferShoulder_r = CircularBuffer<double>(10);
  late MovementReference movement;

  @override
  void initState() {
    super.initState();

    if (widget.exerciseType == ExerciseType.lateralRaises) {
      movement = LateralRaiseReference(180, 10, 10, 1.0);
    } else if(widget.exerciseType == ExerciseType.bicepCurls){
      movement = BicepCurlReference(180, 10, 10, 1.0);
    }
  }

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
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
                      "Wiederholungen: ${movement.reps}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      "Straight Arm Angle: ${movement.secondary_angle}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      "Right Lateral Angle: ${movement.angle}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      "Moving Direction: ${movement.dir}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      "Arms bent: ${movement.armsBent}",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _viewSavedScores,
          child: Icon(Icons.history),
          tooltip: 'View Performance History',
          backgroundColor: Colors.blue,
        ),
      );
    }

  Future<void> _viewSavedScores() async {
    double? latestScore = await PerformanceService.getLatestScore();
    List<Map<String, dynamic>> allScoresWithTimestamps = await PerformanceService.getAllScoresWithTimestamps();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Performance History'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Score: ${latestScore?.toStringAsFixed(2) ?? 'None'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Total Sessions: ${allScoresWithTimestamps.length}'),
              SizedBox(height: 10),
              Expanded(
                child: allScoresWithTimestamps.isEmpty
                  ? Center(child: Text('No performance data yet.\n\nStart exercising to see your scores!'))
                  : ListView.builder(
                      itemCount: allScoresWithTimestamps.length,
                      itemBuilder: (context, index) {
                        final scoreData = allScoresWithTimestamps[index];
                        final score = scoreData['score'] as double;
                        final formattedTime = scoreData['formattedTime'] as String;

                        final duration = scoreData['duration'] as String;

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                            backgroundColor: Colors.blue,
                          ),
                          title: Text('Score: ${score.toStringAsFixed(2)}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$formattedTime ${index == 0 ? '(Most Recent)' : ''}'),
                              Text('Duration: $duration',
                                   style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ));
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

        //eval.intolerance_t_pose_starter(); //set triggered
        //camera_view.CameraView.pose_Stopwatch_activation_bool = eval.triggered;

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
        //gucken ob an und aus geht und danach score

        /*
        //gucken wie man diesen ausdruck bekommt und dann testen
        if(camera_view.CameraView.pose_Stopwatch_activation_bool){
          if(eval.evaluation(score)){
            //exercise.state_change();
          }
        } else {
          eval.started = false;
        }
        */



        //score wird erst berechnet wenn initial pose gefunden wird
        //scores einfluss kann hier mit der certenty gewichtet werden
        //scoreForLAt rise zu score with tolerances ersätzen

        movement.checkExerciseCycle(analytics.l_wsh_angl, analytics.r_wsh_angl);


        movement.checkElbowAngle(analytics.l_wes_angl, analytics.r_wes_angl);

        bufferShoulder_r.add(analytics.r_esh_angl);
        print(bufferShoulder_r);
        print(analytics.r_esh_angl);

            //print("P_Score: " + (Score.average).toString());
            AutoSaveService.updateCurrentScore(10); // Todo: Track current score
            //print("r_ARM (wes): " + r_wes_angl.toString());
            //print("r_HIP (esh): " + r_esh_angl.toString());

        movement.update_angles(analytics.r_esh_angl, analytics.r_wes_angl);
        movement.update_direction();

            /*if (angle_status >= lar_angels.length-1){
              angle_up = true;
              wdhs++;
            } else if (angle_status <= 0) {
              angle_up = false;
            }*/


        //todo store min / max average angle.
        //if difference ~5 away from value -> change direction

        //TODO: Testen wie sich der Average verhällt

        //prozent an korrektheit averagen

        //wrist unter ellenbogeen für winkelunterscheideung
        // bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
        // likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren

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
