//import 'dart:ffi';
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

//import 'pose_detector_view.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:circular_buffer/circular_buffer.dart';


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
    //print("fuck: " + name + landmark.likelihood.toString()); //likelyhood übergeben ?
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

class SlidingAverage {
  final int windowSize;
  final List<double> _values;
  double _sum;

  SlidingAverage(this.windowSize)
      : _values = List.filled(windowSize, 1.0, growable: true),
        _sum = windowSize * 1.0;

  void add(double value, int weight) {
    for (int i = 0; i < weight; i++) {
      // Ältesten Wert entfernen
      _sum -= _values.removeAt(0);

      // Neuen Wert hinzufügen
      _values.add(value);
      _sum += value;

      if (_sum < 0){
        _sum = 0;
      }
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

enum direction{up, down}
enum directionchange{updown, downup}


// pose als input geben welcher winkel soll in welcher pose sein mit welcher toleranz

//der winkel... und der winkel ... soll diesen Wert in dieser Toleranz haben
//am ende muss eine liste von winkeln true ausgeben

//eine growable ist von winkeln wird übergeben und dann wird die
//funktion auf alle winkeln angewendet die kommen und für die muss alles stimmen


//liste von winkeln und konfig (winkel, Target wert, toleranz)
//wenn auf dem winkel der richtige wert kommt 0.85 dann true
//true werte miteinander verunden
//wenn einmal false gleich abbrechen = und false wird ausgegeben

//scorewithTolerances(target_wes, r_wes_angl, tolerance_wes)

//über add gleich vergleichen und gucken ob geckecket ist

//TODO: Sachen adden und dann apply nutzen mit den werden die man kennt
//und einmal starten lassen

class General_Pose_init {

  bool triggered = false;
  final double treshold;
  bool pose_detected = false;

  General_Pose_init(this.treshold);

  //am anfang jeder detection soll es true sein und sich über die zeit ändern
  //vor aufruf der adds einmal pose detected auf true machen
  //dann adds durchlaufen lassen


  bool add_values_4_init_pose_starter(bool init, double angle, double target, double tolerance) {
    if (!init) {
      return false;
    }
    if (scorewithTolerances(target, angle, tolerance) > treshold) {
      pose_detected = pose_detected & true;
      return true;
    }
    pose_detected = pose_detected & false;
    return false;
  }

  apply() {
    triggered = pose_detected;
  }
}







class Pose_init {
  bool triggered = false;

  double r_wesh_score = 0.0;
  double l_wesh_score = 0.0;

  double r_wes_score = 0.0;
  double r_esh_score = 0.0;
  double l_wes_score = 0.0;
  double l_esh_score = 0.0;


  //MovementReference lateral_rises = MovementReference(180, 10, 10, 1.0);

  /*
  lar_init_pose(bool init, r_wes_angl, r_esh_angl, l_wes_angl, l_esh_angl){
    if (init) return intolerance_t_pose_starter(r_wes_angl: r_wes_angl, r_esh_angl: r_esh_angl, l_wes_angl: l_wes_angl, l_esh_angl: l_esh_angl);
    return;
  }*/

  bool intolerance_t_pose_starter(bool init, {
    double target_wes = 180.0,
    double target_esh = 95.0,
    double tolerance_wes = 25.0,
    double tolerance_esh = 20.0,
    double intolerance = 0.7,

    double r_wes_angl = 0.0,
    double r_esh_angl = 0.0,
    double l_wes_angl = 0.0,
    double l_esh_angl = 0.0,
  }){
    if(!init){
      return false;
    }
    double high_intolerance_wesh_r = scorewithTolerances(target_wes, r_wes_angl, tolerance_wes) * scorewithTolerances(target_esh, r_esh_angl, tolerance_esh);
    double high_intolerance_wesh_l = scorewithTolerances(target_wes, l_wes_angl, tolerance_wes) * scorewithTolerances(target_esh, l_esh_angl, tolerance_esh);
    print("intolerance " + (high_intolerance_wesh_l+high_intolerance_wesh_r/2).toString());
    if((high_intolerance_wesh_l+high_intolerance_wesh_r/2) > intolerance){
      triggered = true;
      return true;
    }
    return false;

  }
}




//wichtig für Lat
//grade sitzen, schulter zurück
//ellenbogen bis ca10-15° halten
//schräg nach vorne
//nicht höher als schulterhöhe
//handgelenke neutral
//kein schultern hochziehen
//kopf bliebt grade

class MovementReference {

  //veralgemeinern das wird nicht genutzt

  double upperAngle;
  double lowerAngle;
  double tolerance;
  double minTime;


  bool session_started = false;
  List<List<dynamic>> feedbacks = [];

  SlidingAverage score = SlidingAverage(1000);

  bool neg_feedback = false;

  double esh_max_angle = 85.0;
  double esh_min_angle = 20.0;

  String esh_dir_change_upper_feedback = " ";
  String esh_dir_change_downer_feedback = " ";

  var esh_buffer_l = CircularBuffer<double>(7);
  var esh_buffer_r = CircularBuffer<double>(7);
  double esh_buffer_average_l = 0;
  double esh_buffer_average_r = 0;

  direction dir = direction.down;
  bool direction_changed = false;
  directionchange dirchange = directionchange.updown;

  DateTime? _lastActionTime;
  final Duration _cooldown = Duration(milliseconds: 125); //vorher 250

  bool was_it_down = false;

  int reps = 0;
  int bent_count = 0;
  bool bent = false;

  double wes_max_angle = 180.0;
  double wes_min_angle = 165.0;
  var wes_buffer_l = CircularBuffer<double>(7);
  var wes_buffer_r = CircularBuffer<double>(7);
  double wes_buffer_average_l = 0;
  double wes_buffer_average_r = 0;

  double min_esh_angle = 180;
  double max_esh_angle = 0;
  String wes_angle_feedback = " ";

  MovementReference(this.upperAngle, this.lowerAngle, this.tolerance, this.minTime);

  //fragen warum secundary angle und warum vorher esh und wes
  //secondary wird nicht genutzt da die einträge von a geglättet werden
  void update_esh_angles(double esh_angle_l, double esh_angle_r){
    esh_buffer_l.add(esh_angle_l);
    esh_buffer_average_l = esh_buffer_l.toList().reduce((a, b) => a + b) / esh_buffer_l.length;

    esh_buffer_r.add(esh_angle_r);
    esh_buffer_average_r = esh_buffer_r.toList().reduce((a, b) => a + b) / esh_buffer_r.length;
    return;
  }

  void update_wes_angles(double wes_angle_l, double wes_angle_r){
    wes_buffer_l.add(wes_angle_l);
    wes_buffer_average_l = wes_buffer_l.toList().reduce((a, b) => a + b) / wes_buffer_l.length;

    wes_buffer_r.add(wes_angle_r);
    wes_buffer_average_r = wes_buffer_r.toList().reduce((a, b) => a + b) / wes_buffer_r.length;
    return;
  }

  //eigentlich leicht anwinkeln
  void checkElbowAngle(){
    double leftAngle = wes_buffer_average_l;
    double rightAngle = wes_buffer_average_r;

    double tolerance = 30.0;
    double lowerTolerance = 180.0 - tolerance;

    score.add(scorewithTolerances(wes_max_angle, leftAngle, 85.0), 1); //vorher 30
    score.add(scorewithTolerances(wes_max_angle, rightAngle, 85.0), 1);
    //score add toleranter machen


    //print("elbow_score: " + scorewithTolerances(wes_max_angle, leftAngle, 30.0).toString());
    //print("elbow_score: " + scorewithTolerances(wes_max_angle, rightAngle, 30.0).toString());

    if(leftAngle < lowerTolerance || rightAngle < lowerTolerance){
      bent_count++;
    } else{
      bent_count = 0;
      bent = false;
      wes_angle_feedback = "good";
      neg_feedback = false;
    }
    if(bent_count > 5){
      wes_angle_feedback = "not straight";
      neg_feedback = true;
      bent = true;
    }
  }

  //veralgemeinern
  //gilt erstmal für beide arme zusammen aber update_angles und direktion am bestem pro arm
  //reps anpassen wenn es rechts und links gezählt werden (oder sich nur auf das höhere beziehen)
  void update_direction_lr(String side){
    double esh_buffer_average = 0.0;
    if (side == 'l') {
      esh_buffer_average = esh_buffer_average_l;
    } else
    if (side == 'r') {
      esh_buffer_average = esh_buffer_average_r;
    } else {
      esh_buffer_average = (esh_buffer_average_l + esh_buffer_average_r)/2;
    }

    if(dir == direction.down){ // Down -> Up
      if (min_esh_angle < esh_buffer_average){ //größer werdende entfernung zum minimum
        direction_changed = true;
        dirchange = directionchange.downup;
        min_esh_angle = 180;
      }else{
        min_esh_angle = esh_buffer_average;
      }
    }
    else{ // up -> down
      if (max_esh_angle > esh_buffer_average){ //größer werdende entfernung zum maximum
        direction_changed = true;
        dirchange = directionchange.updown;
        max_esh_angle = 0;
      }else{
        max_esh_angle = esh_buffer_average;
      }
    }

    if (direction_changed == true){

      if(dirchange == directionchange.updown){
        //haltung ausgleichen mit guter wdh
        score.add(scorewithTolerances(esh_max_angle, esh_buffer_average, 20.0), 10);
        double esh_upper_diff = esh_max_angle - esh_buffer_average;

        //todo:werte tweaken

        //TUDO wasit down wäre überschreibar wenn es gesetzt wurde oder nicht gesezt wurde
        //testen ob gesetzt wurde vorm setzen bei down up

        if (esh_upper_diff < -6.0) {
          esh_dir_change_upper_feedback = side + " zu hoch!";
          neg_feedback = true;
          score.add(0.8,2); //strafpunkt für die gesundheit
           //TODO: problem das wenn man oben hält das es nur countet !!!!!
          if (was_it_down){
            reps++;
          }
        } else
        if (esh_upper_diff < 2.0) {
          esh_dir_change_upper_feedback = side + " super";
          neg_feedback = false;
          if (was_it_down){
            was_it_down = false;
            reps++;
          }
        } else
        if (esh_upper_diff < 6.0) {
          esh_dir_change_upper_feedback = side + " gut";
          neg_feedback = false;
          if (was_it_down){
            was_it_down = false;
            reps++;
          }
        } else
        if (esh_upper_diff < 15.0) {
          esh_dir_change_upper_feedback = side + " noch etwas höher";
          neg_feedback = false;
        } else
        if (esh_upper_diff < 17.0) {
          esh_dir_change_upper_feedback = side + " zu niedrig";
          neg_feedback = true;
        }
      }

      if(dirchange == directionchange.downup){

        score.add(scorewithTolerances(esh_min_angle, esh_buffer_average, 25.0), 10);
        double esh_downer_diff = esh_buffer_average - esh_min_angle;

        //todo:werte tweaken
        //auswertung hier etwas langsamer

        if (esh_downer_diff < 10.0) {
          esh_dir_change_downer_feedback = side + " super";
          if(!was_it_down){
            was_it_down = true;
          }
        } else
        if (esh_downer_diff < 15.0) {
          esh_dir_change_downer_feedback = side + " gut";
          if(!was_it_down){
            was_it_down = true;
          }
        } else
        if (esh_downer_diff < 20.0) {
          esh_dir_change_downer_feedback = side + " weiter runter";
        } else
        if (esh_downer_diff < 25.0) {
          esh_dir_change_downer_feedback = side + " zu hoch";
          neg_feedback = false;
        }
      }
      direction_changed = false;

      //zu schnelle wechsel nicht anerkennen
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
  // eine funktion die checkt ob es negatives feedback gibt und dann sagt
  //funktion die input image speichert zusätzlich zu negativem feedback wenn dieser eintritt
  //bei negativem feedback wird diese funktion aufgerufen und macht ein foto davon
  got_you_in_4k(InputImage inputImage){
    //TODO:adden im speicher und probleme lösen
    //problem verzögerung durch buffer average kann zu einem bild an falscher stelle führen
    //Problem es sollen nicht durchgängig werte aufgenommen werden sonderneinmal pro problem


    //feedback liste erstellen mit jeweils fotos und werten
    feedbacks.add([
      esh_buffer_average_l,
      esh_buffer_average_r,
      esh_dir_change_upper_feedback,
      esh_dir_change_downer_feedback,
      wes_buffer_average_l,
      wes_buffer_average_r,
      wes_angle_feedback,
      inputImage
    ]);
    //timespamp ? auch abspeichern ?

    //print(results[0][0]); // Lateral Raises
    //results[0] ereignis
    return;
  }
}

class Joint_Angle {
  final String first;
  final String second;
  final String third;

  final double certainty = 1.0; //später über Vector2 ausgabe machen
  bool detected = false;
  late double angle = 0.0;

  Joint_Angle({required this.first, required this.second, required this.third});
}

class General_pose_analytics{
  get_angles(Pose pose, Joint_Angle angl) {
    Vector2 point_1;
    Vector2 point_2;
    Vector2 point_3;

    angl.detected = true;

    Vector2? vec_1 = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), angl.first);
    if (vec_1 != null) {
      point_1 = Vector2(vec_1.x, vec_1.y);
    } else {
      print("General_analysis_Error: Fehler beim erkennen des " + angl.first);
      angl.detected = angl.detected & false;
      return;
    }

    Vector2? vec_2 = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), angl.second);
    if (vec_2 != null) {
      point_2 = Vector2(vec_2.x, vec_2.y);
    } else {
      print("General_analysis_Error: Fehler beim erkennen des " + angl.second);
      angl.detected = angl.detected & false;
      return;
    }

    Vector2? vec_3 = getLandmarkCoordinates_2d(
        pose.landmarks.entries.toList(), angl.third);
    if (vec_3 != null) {
      point_3 = Vector2(vec_3.x, vec_3.y);
    } else {
      print("General_analysis_Error: Fehler beim erkennen des " + angl.third);
      angl.detected = angl.detected & false;
      return;
    }

    return computeJointAngle_2d(a: point_1, b: point_2, c: point_3);
  }
  //"elbowAngle": ["shoulderRight", "elbowRight", "wristRight"] input ?
}