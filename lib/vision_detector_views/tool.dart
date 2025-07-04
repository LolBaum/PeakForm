import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_detector_view.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:circular_buffer/circular_buffer.dart';

enum direction{up, down}


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



class SlidingAverage {
  final int windowSize;
  final List<double> _values;
  double _sum;

  SlidingAverage(this.windowSize)
      : _values = List.filled(windowSize, 1.0, growable: true),
        _sum = windowSize * 1.0;

  void add(double value) {
    // Ältesten Wert entfernen
    _sum -= _values.removeAt(0);

    // Neuen Wert hinzufügen
    _values.add(value);
    _sum += value;

    if (_sum < 0){
      _sum = 0;
    }
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

class MovementReference {
  double upperAngle;
  double lowerAngle;
  double tolerance;
  double minTime;
  direction dir = direction.down;
  bool direction_changed = false;
  DateTime? _lastActionTime;
  final Duration _cooldown = Duration(milliseconds: 250);
  var buffer = CircularBuffer<double>(10);
  double angle = 0;
  double secondary_angle = 180;
  double min_r = 180;
  double max_r = 0;
  double average = 0;
  int bent_count = 0;
  bool bent = false;
  int reps = 0;
  bool armsUp = false;

  bool leftArmUp = false;
  bool rightArmUp = false;
  bool leftArmDown = false;
  bool rightArmDown = false;



  MovementReference(this.upperAngle, this.lowerAngle, this.tolerance, this.minTime);

  void checkLateralRaiseCycle(double leftAngle, double rightAngle) {
    const double raiseThreshold = 85.0;
    const double lowerThreshold = 35.0;

    leftArmUp = leftAngle > raiseThreshold;
    rightArmUp = rightAngle > raiseThreshold;
    leftArmDown = leftAngle < lowerThreshold;
    rightArmDown = rightAngle < lowerThreshold;

    if (!armsUp && leftArmUp && rightArmUp) {
      armsUp = true;
      print("Beide Arme oben angekommen!");
    }

    if (armsUp && leftArmDown && rightArmDown) {
      armsUp = false;
      reps++;
      print("Arme unten! Wiederholung gezählt! Gesamt: $reps");
    }
  }

  void checkElbowAngle(double leftAngle, double rightAngle){
    double tolerance = 30.0;
    double lowerTolerance = 180.0 - tolerance;

    //scorewithTolerances(180.0, rightAngle, 20.0);

    if(leftAngle < lowerTolerance || rightAngle < lowerTolerance){
      bent_count++;
    } else{
      bent_count = 0;
      bent = false;
    }

    if(bent_count > 30){
      print("Arm is not straight");
      bent = true;
    }
  }

  void update_angles(double a, double b){
    angle=a;
    secondary_angle=b;
    buffer.add(angle);
    average = buffer.toList().reduce((a, b) => a + b) / buffer.length;
  }

  void update_direction(){
    if(dir == direction.down){ // Down -> Up
      if (min_r < average){
        direction_changed = true;
        min_r = 180;
      }else{
        min_r = average;
      }
    }
    else{ // up -> down
      if (max_r > average){
        direction_changed = true;
        max_r = 0;
      }else{
        max_r = average;
      }
    }

    if (direction_changed == true){
      // TODO: Evaluate the Position
      direction_changed = false;

      final now = DateTime.now();
      if (_lastActionTime == null ||
          now.difference(_lastActionTime!) > _cooldown) {
        if (dir == direction.up){
          dir = direction.down;
        }
        else{
          dir = direction.up;
        }
        _lastActionTime = now;
      }
    }
  }

}





//klasse zum lesen und Aktualliseren der Daten für die Lateral rises
class Pose_analytics {
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

  late double l_wsh_angl;
  late double r_wsh_angl;

  //später punkte übern aufruf angeben

  //var lar_angels = [95.0, 60.0, 7.0];

  //kalibrieren oberster und unterster winkel

  //messen welcher winkel wirklich erreicht wird
  /*
  List<double> lar_angels = List.generate(
      (95 - 15 + 1),             // Anzahl der Elemente
          (i) => 95.0 - i           // 95.0, 94.0, ..., 7.0
  ); //höhere granularität schnellerer ablauf
  */

  //static var lar_angels = [95.0, 60.0, 7.0];

  //oben:95+-5  unter 96
  //mitte:60+-2
  //unten:7+-1grad

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


  //set new pose als init aber auch durchgängig
  set_new_pose(Pose p) {
    this.pose = p;
  }

  /*
  Vector2 getLandmarkOrError(String landmarkName, String errorText) {
    Vector2? vec = getLandmarkCoordinates_2d(pose.landmarks.entries.toList(), landmarkName);
    if (vec == null) {
      throw Exception(errorText);
    }
    return vec;
  }*/

  get_lr_wesh_points() {
    Vector2? vec_rWrist = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "rightWrist");
    if (vec_rWrist != null) {
      r_Wrist = Vector2(vec_rWrist.x, vec_rWrist.y);
      r_w = true;
    } else {
      print("Fehler beim erkennen des r Handgelenks");
      r_w = false;
    }
    Vector2? vec_rElbow = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "rightElbow");
    if (vec_rElbow != null) {
      r_Elbow = Vector2(vec_rElbow.x, vec_rElbow.y);
      r_e = true;
    } else {
      print("Fehler beim erkennen des r Ellenbogens");
      r_e = false;
    }
    Vector2? vec_rShoulder = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "rightShoulder");
    if (vec_rShoulder != null) {
      r_Shoulder = Vector2(vec_rShoulder.x, vec_rShoulder.y);
      r_s = true;
    } else {
      print("Fehler beim erkennen der r Schulter");
      r_s = false;
    }
    Vector2? vec_rHip = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "rightHip");
    if (vec_rHip != null) {
      r_Hip = Vector2(vec_rHip.x, vec_rHip.y);
      r_h = true;
    } else {
      print("Fehler beim erkennen der r Hüfte");
      r_h = false;
    }

    Vector2? vec_lWrist = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "leftWrist");
    if (vec_lWrist != null) {
      l_Wrist = Vector2(vec_lWrist.x, vec_lWrist.y);
      l_w = true;
    } else {
      print("Fehler beim erkennen des l Handgelenks");
      l_w = false;
    }

    Vector2? vec_lElbow = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "leftElbow");
    if (vec_lElbow != null) {
      l_Elbow = Vector2(vec_lElbow.x, vec_lElbow.y);
      l_e = true;
    } else {
      print("Fehler beim erkennen des l Ellenbogens");
      l_e = false;
    }

    Vector2? vec_lShoulder = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "leftShoulder");
    if (vec_lShoulder != null) {
      l_Shoulder = Vector2(vec_lShoulder.x, vec_lShoulder.y);
      l_s = true;
    } else {
      print("Fehler beim erkennen der l Schulter");
      l_s = false;
    }

    Vector2? vec_lHip = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), "leftHip");
    if (vec_lHip != null) {
      l_Hip = Vector2(vec_lHip.x, vec_lHip.y);
      l_h = true;
    } else {
      print("Fehler beim erkennen der l Hüfte");
      l_h = false;
    }
  }

  // muss this. davor oder geht es auch so ?
  bool is_wesh() {
    if (r_w && r_e && r_s && r_h && l_w && l_e && l_s && l_h) {
      return true;
    }
    return false;
  }

  compute_wesh_joints() {
    if (!is_wesh()) {
      return;
    }
    r_wes_angl = computeJointAngle_2d(a: r_Shoulder, b: r_Elbow, c: r_Wrist);
    r_esh_angl = computeJointAngle_2d(a: r_Elbow, b: r_Shoulder, c: r_Hip);
    l_wes_angl = computeJointAngle_2d(a: l_Shoulder, b: l_Elbow, c: l_Wrist);
    l_esh_angl = computeJointAngle_2d(a: l_Elbow, b: l_Shoulder, c: l_Hip);

    l_wsh_angl = computeJointAngle_2d(a: l_Hip, b: l_Shoulder, c: l_Wrist);
    r_wsh_angl = computeJointAngle_2d(a: r_Hip, b: r_Shoulder, c: r_Wrist);
  }

}

// wie richtig machst du die übung ...

class LAR_Evaluation {
  bool triggered = false;
  bool stoped = false;
  bool init = false;

  //int angle_status = 0;
  //bool angle_up = false;
  //int wdhs = 0;

  double r_wesh_score = 0.0;
  double l_wesh_score = 0.0;

  double r_wes_score = 0.0;
  double r_esh_score = 0.0;
  double l_wes_score = 0.0;
  double l_esh_score = 0.0;

  SlidingAverage score = SlidingAverage(100);


  session(bool init, r_wes_angl, r_esh_angl, l_wes_angl, l_esh_angl){
    if (init) return intolerance_t_pose_starter(r_wes_angl: r_wes_angl, r_esh_angl: r_esh_angl, l_wes_angl: l_wes_angl, l_esh_angl: l_esh_angl);
    return evaluation(r_wes_angl: r_wes_angl, r_esh_angl: r_esh_angl, l_wes_angl: l_wes_angl, l_esh_angl: l_esh_angl);
  }

  bool intolerance_t_pose_starter({
    double target_wes = 180.0,
    double target_esh = 95.0,
    double tolerance_wes = 25.0,
    double tolerance_esh = 20.0,
    double intolerance = 0.7,

    double r_wes_angl = 0.0,
    double r_esh_angl = 0.0,
    double l_wes_angl = 0.0,
    double l_esh_angl = 0.0

  }){
    double high_intolerance_wesh_r = scorewithTolerances(target_wes, r_wes_angl, tolerance_wes) * scorewithTolerances(target_esh, r_esh_angl, tolerance_esh);
    double high_intolerance_wesh_l = scorewithTolerances(target_wes, l_wes_angl, tolerance_wes) * scorewithTolerances(target_esh, l_esh_angl, tolerance_esh);
    print("intolerance " + (high_intolerance_wesh_l+high_intolerance_wesh_r/2).toString());
    if((high_intolerance_wesh_l+high_intolerance_wesh_r/2) > intolerance){
      triggered = true;
      return true;
    }
    return false;

  }


  //über die zeit verfolgen ob die arme richtig sind und dann wenn richtungswechsel ist ob dieser im richtigen winkel stattfand (mit einem faktor)
  //auch arm veränderungen bestrafen
  evaluation({
    r_wes_angl = 0.0,
    r_esh_angl = 0.0,
    l_wes_angl = 0.0,
    l_esh_angl = 0.0
  }) {
    //if(!started || !is_wesh()) return;
    r_wes_score = scorewithTolerances(180, r_wes_angl, 25.0);
    //r_esh_score = scorewithTolerances(lar_angels[angle_status], r_esh_angl, 45.0); //lar_angles war vorher 90.0
    l_wes_score = scorewithTolerances(180, l_wes_angl, 25.0);
    //l_esh_score = scorewithTolerances(lar_angels[angle_status], l_esh_angl, 45.0);

    r_wesh_score = (r_wes_score + r_esh_score)/2;
    l_wesh_score = (l_wes_score + l_esh_score)/2;

    score.add(r_wesh_score);
    score.add(l_wesh_score);

    print("P_Score: " + (score.average).toString());
    print("r_ARM (wes): " + r_wes_angl.toString());
    print("r_HIP (esh): " + r_esh_angl.toString());



    return true;
  }

  /*
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

  }*/

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