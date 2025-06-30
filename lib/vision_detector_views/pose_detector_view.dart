import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit_example/vision_detector_views/tool.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
//import 'package:circular_buffer/circular_buffer.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';
import '../services/auto_save_service.dart';
import '../services/performance_service.dart';

import 'camera_view.dart' as camera_view;

//var lar_angels = [95.0, 60.0, 7.0];



List<double> lar_angels = List.generate(
    (95 - 7 + 1),             // Anzahl der Elemente
    (i) => 95.0 - i           // 95.0, 94.0, ..., 7.0
);

/*
double lar_min = 7.0;
double lar_max = 95.0;
double lar_step = 1.0;

int length = ((lar_max - lar_min) / lar_step).abs().floor() + 1;

List<double> lar_angels = List.generate(
    length,
        (i) => lar_step > 0 ? lar_min + i * lar_step : lar_max + i * lar_step
).where((v) => lar_step > 0 ? v <= lar_max : v >= lar_min).toList();
*/


int angle_status = 0;
bool angle_up = false;
int wdhs = 0;

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
  bool started = false;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetectorView(
        title: 'Pose Detector',
        customPaint: _customPaint,
        text: _text,
        onImage: _processImage,
        initialCameraLensDirection: _cameraLensDirection,
        onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
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
      ),
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
        //

        bool right_wesh = vec_rWrist != null && vec_rElbow != null && vec_rShoulder != null && vec_rHip != null;
        bool left_wesh = vec_lWrist != null && vec_lElbow != null && vec_lShoulder != null && vec_lHip != null;

        //score wird erst berechnet wenn initial pose gefunden wird
        //scores einfluss kann hier mit der certenty gewichtet werden
        //scoreForLAt rise zu score with tolerances ersätzen
        if (right_wesh && left_wesh) {
          double r_wes_angl = computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist);
          double r_esh_angl = computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip);
          double l_wes_angl = computeJointAngle_2d(a: l_Shoulder, b: l_Elbow, c: l_Wrist);
          double l_esh_angl = computeJointAngle_2d(a: l_Elbow, b: l_Shoulder, c: l_Hip);

          if (!started){
            double high_intolerance_wesh_r = scorewithTolerances(180, r_wes_angl, 20.0) * scorewithTolerances(90.0, r_esh_angl, 30.0);
            double high_intolerance_wesh_l = scorewithTolerances(180, l_wes_angl, 20.0) * scorewithTolerances(90.0, l_esh_angl, 30.0);
            print("intolerance " + (high_intolerance_wesh_l+high_intolerance_wesh_r).toString());
            if((high_intolerance_wesh_l+high_intolerance_wesh_r) > 1.2){
              started = true;
              //camera_view.CameraView._startStopwatch();
              //camera_view.CameraView.isStopwatchRunning = true;
              camera_view.CameraView.pose_Stopwatch_activation_bool = true; //umgeht einigen shit und soft dafür das bei der einmalige init pose die stopuhr mit angeht
            }
          }

          if(started){
            double r_wes_score = scorewithTolerances(180, r_wes_angl, 25.0);
            double r_esh_score = scorewithTolerances(lar_angels[angle_status], r_esh_angl, 45.0); //lar_angles war vorher 90.0
            double l_wes_score = scorewithTolerances(180, l_wes_angl, 25.0);
            double l_esh_score = scorewithTolerances(lar_angels[angle_status], l_esh_angl, 45.0);

            double temp_score_r_wesh = (r_wes_score + r_esh_score)/2;
            double temp_score_l_wesh = (l_wes_score + l_esh_score)/2;

            Score.add(temp_score_r_wesh);
            Score.add(temp_score_l_wesh);

            print("P_Score: " + (Score.average).toString());
            AutoSaveService.updateCurrentScore(Score.average); // Track current score
            print("r_ARM (wes): " + r_wes_angl.toString());
            print("r_HIP (esh): " + r_esh_angl.toString());


            if (angle_status >= lar_angels.length-1){
              angle_up = true;
              wdhs++;
            } else if (angle_status <= 0) {
              angle_up = false;
            }


            if (r_esh_score >= 0.7) { //toleranzen einstellen und für links das selbe
              if (angle_up){
                angle_status--;
              } else {
                angle_status++;
              }
            }

            print("angle_Status: " + angle_status.toString());
            print("wdhs: " + wdhs.toString());

          }


        }

        //TODO: Testen wie sich der Average verhällt

        //prozent an korrektheit averagen

        //wrist unter ellenbogeen für winkelunterscheideung
        // bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
        // likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren

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
