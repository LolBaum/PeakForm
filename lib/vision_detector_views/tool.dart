import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_detector_view.dart';
import 'package:vector_math/vector_math_64.dart';

enum direction{up, down}

/*
class MovementReference {
  double upperAngle;
  double lowerAngle;
  double tolerance;
  double minTime;
  bool isConstant;
  bool started;

  MovementReference(this.upperAngle, this.lowerAngle, this.tolerance, this.minTime, this.isConstant);
} */

//pro übung eine liste an toleranzen und winkel erstellen

class Vector3 {
  final double x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator -(Vector3 other) =>
      Vector3(x - other.x, y - other.y, z - other.z);

  double dot(Vector3 other) =>
      x * other.x + y * other.y + z * other.z;

  double magnitude() => sqrt(x * x + y * y + z * z);

  double angleTo(Vector3 other) {
    final dotProduct = dot(other);
    final magnitudeProduct = magnitude() * other.magnitude();
    return acos(dotProduct / magnitudeProduct) * (180 / pi); // Grad
  }
}

class Vector2 {
  final double x, y;

  Vector2(this.x, this.y);

  Vector2 operator -(Vector2 other) =>
      Vector2(x - other.x, y - other.y);

  double dot(Vector2 other) =>
      x * other.x + y * other.y;

  double magnitude() => sqrt(x * x + y * y);

  double angleTo(Vector2 other) {
    final dotProduct = dot(other);
    final magnitudeProduct = magnitude() * other.magnitude();
    return acos(dotProduct / magnitudeProduct) * (180 / pi); // Grad
  }
}

// für 3 Vektoren dann die berechnung
double computeJointAngle_3d({
  required Vector3 a,
  required Vector3 b,
  required Vector3 c,
}) {
  final ab = a - b;
  final cb = c - b;
  return ab.angleTo(cb);
}

double computeJointAngle_2d({
  required Vector2 a,
  required Vector2 b,
  required Vector2 c,
}) {
  final ab = a - b;
  final cb = c - b;
  return ab.angleTo(cb);
}

//soll und ist und differenz

double scoreForLateralRaise_Arm(double angle) {
  if (angle >= 160 && angle <= 180) return 1.0;
  if (angle >= 60 && angle <= 120) return 0.0;
  return 0.0;
}
double scoreForLateralRaise_Hip(double angle) {
  if (angle >= 90-10 && angle <= 100-10) return 1.0;
  if (angle >= 60 && angle <= 120) return 0.0;
  return 0.0;
}




Vector3? getLandmarkCoordinates_3d(List<MapEntry<PoseLandmarkType, PoseLandmark>> entries, String name) {
  try {
    final entry = entries.firstWhere((e) => e.key.name == name);
    final landmark = entry.value;
    return Vector3(landmark.x, landmark.y, landmark.z);
  } catch (e) {
    print(e);
    print("Keypoint '$name' nicht gefunden.");
    return null;
  }
}

Vector2? getLandmarkCoordinates_2d(List<MapEntry<PoseLandmarkType, PoseLandmark>> entries, String name) {
  try {
    final entry = entries.firstWhere((e) => e.key.name == name);
    final landmark = entry.value;
    return Vector2(landmark.x, landmark.y);
  } catch (e) {
    print(e);
    print("Keypoint '$name' nicht gefunden.");
    return null;
  }
}

String getPoseName(List<MapEntry<PoseLandmarkType, PoseLandmark>> entries, String name){
  try {
    final entry = entries.firstWhere((e) => e.key.name == name);
    final landmark = entry.key;
    return landmark.toString();
  } catch (e) {
    print(e);
    print("Keypoint '$name' nicht gefunden.");
    return "";
  }
}

//nicht nur wrist zu elbow to shoulder sondern auch richtigen winkel zum oberkörper finden (der wird vlt immer über 100 sein)
// dann bewertung pro frame wenn man eine abfolge erreicht aber denn auch nicht von der abfolge zurück geht
// also eine sequenz vin winkeln die gemacht werden muss

//!!! für bewertungen win fenster benutzen weil ab einer zeit ändert man nichts mehr vom score
class RunningAverage {
  double _mean = 1.0; // bei 0 oder bei 1 beginnen ?
  int _count = 0;
  //adds and counts
  void add(double value) {
    _mean = _mean + (value - _mean) / (++_count);
  }
  //_mean = (_mean *_count) + value/(++_count);
  double get average => _mean;
  int get count => _count;
}


class SlidingAverage {
  final int windowSize;
  final List<double> _values;
  double _sum;

  SlidingAverage(this.windowSize)
      : _values = List.filled(windowSize, 1.0),
        _sum = windowSize * 1.0;

  void add(double value) {
    // Ältesten Wert entfernen
    _sum -= _values.removeAt(0);

    // Neuen Wert hinzufügen
    _values.add(value);
    _sum += value;
  }

  double get average => _sum / windowSize;
  int get count => _values.length;
}


//die Tolleranz soll bei 45 grad erreicht sein und bis dann stetig fallen
//der cosinus wird bei 90° = 0 also werden die differenzen verdoppelt und ab 45 gecapped
double scorewithTolerances(double target_degree, double real_degree, double tolerance) {
  double difference = (target_degree-real_degree).abs();
  if ((difference > tolerance)||(tolerance == 0)) return 0.0;
  return cos(radians(difference*(90/tolerance)));
}



class TimedPose {
  final String pose;
  final Duration timestamp;

  TimedPose(this.pose, this.timestamp);
}

//static var lar_angels = [95.0, 60.0, 7.0];

//oben:95+-5  unter 96
//mitte:60+-2
//unten:7+-1grad


//klasse zum lesen und Aktualliseren der Daten für die Lateral rises
class Lateral_rises {
  late Pose pose; // wird immer aktualisert

  late Vector2 r_Shoulder;
  late Vector2 r_Elbow;
  late Vector2 r_Wrist;
  late Vector2 r_Hip;


  late Vector2 l_Wrist;
  late Vector2 l_Elbow;
  late Vector2 l_Shoulder;
  late Vector2 l_Hip;

  bool r_w = false;
  bool r_e = false;
  bool r_s = false;
  bool r_h = false;

  bool l_w = false;
  bool l_e = false;
  bool l_s = false;
  bool l_h = false;

  late double r_wes_angl;
  late double r_esh_angl;
  late double l_wes_angl;
  late double l_esh_angl;

  bool started = false;

  //var lar_angels = [95.0, 60.0, 7.0];

  //kalibrieren oberster und unterster winkel

  //messen welcher winkel wirklich erreicht wird
  List<double> lar_angels = List.generate(
      (95 - 15 + 1),             // Anzahl der Elemente
          (i) => 95.0 - i           // 95.0, 94.0, ..., 7.0
  ); //höhere granularität schnellerer ablauf

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

  double r_wesh_score = 0.0;
  double l_wesh_score = 0.0;

  double r_wes_score = 0.0;
  double r_esh_score = 0.0;
  double l_wes_score = 0.0;
  double l_esh_score = 0.0;

  //vlt einfach nur score machen und der guckt selber nach get pose und so

  //init then allways set dann get wesh joint und start bewertung und dann bewertung und zustands veränderung

  //lateral_rises();

  //trotzdem funktion zum aktualisieren

  //set new pose als init aber auch durchgängig
  set_new_pose(Pose p) {
    this.pose = p;
  }

  get_lr_wesh(){

    Vector2? vec_rWrist = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightWrist");
    if(vec_rWrist != null){
      r_Wrist = Vector2(vec_rWrist.x, vec_rWrist.y);
      r_w = true;
    } else {
      print("Fehler beim erkennen des r Handgelenks");
      r_w = false;
    }
    Vector2? vec_rElbow = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightElbow");
    if(vec_rElbow != null){
      r_Elbow = Vector2(vec_rElbow.x, vec_rElbow.y);
      r_e = true;
    } else {
      print("Fehler beim erkennen des r Ellenbogens");
      r_e = false;
    }
    Vector2? vec_rShoulder = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightShoulder");
    if(vec_rShoulder != null){
      r_Shoulder = Vector2(vec_rShoulder.x, vec_rShoulder.y);
      r_s = true;
    } else {
      print("Fehler beim erkennen der r Schulter");
      r_s = false;
    }
    Vector2? vec_rHip = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "rightHip");
    if(vec_rHip != null){
      r_Hip = Vector2(vec_rHip.x, vec_rHip.y);
      r_h = true;
    } else {
      print("Fehler beim erkennen der r Hüfte");
      r_h = false;
    }

    Vector2? vec_lWrist = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftWrist");
    if(vec_lWrist != null){
      l_Wrist = Vector2(vec_lWrist.x, vec_lWrist.y);
      l_w = true;
    } else {
      print("Fehler beim erkennen des l Handgelenks");
      l_w = false;
    }

    Vector2? vec_lElbow = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftElbow");
    if(vec_lElbow != null){
      l_Elbow = Vector2(vec_lElbow.x, vec_lElbow.y);
      l_e = true;
    } else {
      print("Fehler beim erkennen des l Ellenbogens");
      l_e = false;
    }

    Vector2? vec_lShoulder = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftShoulder");
    if(vec_lShoulder != null){
      l_Shoulder = Vector2(vec_lShoulder.x, vec_lShoulder.y);
      l_s = true;
    } else {
      print("Fehler beim erkennen der l Schulter");
      l_s = false;
    }

    Vector2? vec_lHip = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), "leftHip");
    if(vec_lHip != null){
      l_Hip = Vector2(vec_lHip.x, vec_lHip.y);
      l_h = true;
    } else {
      print("Fehler beim erkennen der l Hüfte");
      l_h = false;
    }
  }

  // muss this. davor oder geht es auch so ?
  bool is_wesh(){
    if (r_w && r_e && r_s && r_h && l_w && l_e && l_s && l_h) {
      return true;
    }
    return false;
  }

  compute_wesh_joints(){
    if (!is_wesh()){
      return;
    }
    r_wes_angl = computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist);
    r_esh_angl = computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip);
    l_wes_angl = computeJointAngle_2d(a: l_Shoulder, b: l_Elbow, c: l_Wrist);
    l_esh_angl = computeJointAngle_2d(a: l_Elbow, b: l_Shoulder, c: l_Hip);
  }

  //mit camera_view starten
  // vlt werte als klassen variable machen ?
  bool intolerance_t_pose_starter({tolerance_wes = 20.0, tolerance_esh = 30.0, intolerance = 1.2}){
    if (started) return true;
    if (!is_wesh()) return false;
    double high_intolerance_wesh_r = scorewithTolerances(180, r_wes_angl, tolerance_wes) * scorewithTolerances(90.0, r_esh_angl, tolerance_esh);
    double high_intolerance_wesh_l = scorewithTolerances(180, l_wes_angl, tolerance_wes) * scorewithTolerances(90.0, l_esh_angl, tolerance_esh);
    print("intolerance " + (high_intolerance_wesh_l+high_intolerance_wesh_r).toString());
    if((high_intolerance_wesh_l+high_intolerance_wesh_r) > intolerance){
      started = true;
      //camera_view.CameraView._startStopwatch();
      //camera_view.CameraView.isStopwatchRunning = true;
      //camera_view.CameraView.pose_Stopwatch_activation_bool = true
      //activate_watch = true; //umgeht einigen shit und soft dafür das bei der einmalige init pose die stopuhr mit angeht
      return true;
    }
    return false;
  }

  //mit score zum adden
  //werte hier noch anpassen die toleranzen
  evaluation(Score) {
    if(!started || !is_wesh()) return;
    r_wes_score = scorewithTolerances(180, r_wes_angl, 25.0);
    r_esh_score = scorewithTolerances(lar_angels[angle_status], r_esh_angl, 45.0); //lar_angles war vorher 90.0
    l_wes_score = scorewithTolerances(180, l_wes_angl, 25.0);
    l_esh_score = scorewithTolerances(lar_angels[angle_status], l_esh_angl, 45.0);

    r_wesh_score = (r_wes_score + r_esh_score)/2;
    l_wesh_score = (l_wes_score + l_esh_score)/2;

    print("t_Score: " + r_wesh_score.toString());
    print("t_Score: " + l_wesh_score.toString());

    Score.add(r_wesh_score);
    Score.add(l_wesh_score);

    print("P_Score: " + (Score.average).toString());
    print("r_ARM (wes): " + r_wes_angl.toString());
    print("r_HIP (esh): " + r_esh_angl.toString());
    return true;
  }

  state_change(){

    //erstmal die oberfunktionen ausführen sodass nur noch der aufruf statechange gebraucht wird

    if (angle_status >= lar_angels.length-1){
      angle_up = true;
    } else if (angle_status <= 0) {
      angle_up = false;
      wdhs++;
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