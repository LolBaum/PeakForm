//import 'dart:ffi';
import 'dart:math';
import 'package:google_ml_kit_example/result_screen.dart';
import 'package:google_ml_kit_example/vision_detector_views/pose_detector_view.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

//import 'pose_detector_view.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:circular_buffer/circular_buffer.dart';
import 'camera_view.dart';
import 'feedback_generator.dart';

import '../widgets/pose_feedback_tooltip.dart';

//3D bereich
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
//3D bereich zuende

//2D bereich
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

double computeJointAngle_2d({
  required Vector2 a,
  required Vector2 b,
  required Vector2 c,
}) {
  final ab = a - b;
  final cb = c - b;
  return ab.angleTo(cb);
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
//2D bereich zuende


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

enum direction{up, down}
enum directionchange{updown, downup}

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
}

//init pose setter
class General_Pose_init {

  final double treshold;
  bool triggered = false;
  bool pose_detected = false;

  General_Pose_init(this.treshold);

  bool add_values_4_init_pose_starter(bool init, double angle, double target, double tolerance) {
    if (!init) {
      return false;
    }
    print(scorewithTolerances(target, angle, tolerance).toString());
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

/*
  double wes_max_angle = 180.0;
  double wes_min_angle = 165.0;

  double min_esh_angle = 180;
  double max_esh_angle = 0;
   */
String getFormattedStopwatchTimestamp() {
  final elapsed = CameraView.stopwatch.elapsed;

  final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  final milliseconds = (elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

  return "$minutes:$seconds:$milliseconds";
}


//generalisiert halt
class General_MovementReference {

  bool session_started = false;
  SlidingAverage score = SlidingAverage(1000);
  bool neg_feedback = false;

  DateTime? _lastActionTime;
  final Duration _cooldown = Duration(milliseconds: 125); //vorher 250
  double minTime;

  //List<List<dynamic>> feedbacks = [];
  //mit timestamp ?

  //ab hier debug
  String debug_name = " ";
  String debug_counter = " ";
  String debug_was_it_down = " ";
  String debug_feedback = " ";
  String debug_angle = " ";
  String debug_dir = " ";
  double debug_score = 0;

  //bis hier debug!

  final Map<String, CircularBuffer<double>> body_joint_buffers = {};
  final Map<String, String> body_joint_feedbacks = {};
  final Map<String, int> body_joint_counter = {};
  final Map<String, double> body_joint_max_movement = {};
  final Map<String, double> body_joint_min_movement = {};
  final Map<String, direction> body_joint_movement_dir = {};
  final Map<String, bool> body_joint_was_it_down = {};

  General_MovementReference(this.minTime, List<String> items, List<bool> movement){
    int i = 0;
    for (String name in items){
      if (body_joint_buffers.containsKey(name) && body_joint_feedbacks.containsKey(name) && body_joint_counter.containsKey(name)) {
        print("Buffer '$name' existiert bereits!");
        return;
      }
      body_joint_buffers[name] = CircularBuffer<double>(7);
      body_joint_feedbacks[name] = " ";
      body_joint_counter[name] = 1; // wenn init gleich t_pose ist
      if (movement[i]) {
        body_joint_max_movement[name] = 0;
        body_joint_min_movement[name] = 180;
        body_joint_movement_dir[name] = direction.down;
        body_joint_was_it_down[name] = false;
      }
      i++;
    }
  }

  //zwischenschrittlich
  void update_joint_Buffer(String name, double value) {
    final buffer = body_joint_buffers[name];
    if (buffer != null) {
      buffer.add(value);
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_Buffer_feedback(String name, String feedback) {
    final buffer = body_joint_feedbacks[name];
    if (buffer != null) {
      body_joint_feedbacks[name] = feedback;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_Buffer_counter(String name, int value) {
    final buffer = body_joint_counter[name];
    if (buffer != null) {
      body_joint_counter[name] = value;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_Buffer_max_movement(String name, double value) {
    final buffer = body_joint_max_movement[name];
    if (buffer != null) {
      body_joint_max_movement[name] = value;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_Buffer_min_movement(String name, double value) {
    final buffer = body_joint_min_movement[name];
    if (buffer != null) {
      body_joint_min_movement[name] = value;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_joint_Buffer_movement_dir(String name, direction dir) {
    final buffer = body_joint_movement_dir[name];
    if (buffer != null) {
      body_joint_movement_dir[name] = dir;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }
  void update_joint_Buffer_was_it_down(String name, bool down) {
    final buffer = body_joint_was_it_down[name];
    if (buffer != null) {
      body_joint_was_it_down[name] = down;
    } else {
      print("Kein Buffer mit Namen '$name' gefunden.");
    }
  }

  //zusammenfassen durch hyperfkt ?
  double? getAverage_from_body_joint_buffer(String name) {
    final buffer = body_joint_buffers[name];
    if (buffer == null || buffer.isEmpty) return null; //oder problem printen
    return buffer.toList().reduce((a, b) => a + b)/buffer.length;
  }
  String? getValue_from_body_joint_feedback(String name) {
    final buffer = body_joint_feedbacks[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_feedbacks[name];
  }
  int? getValue_from_body_joint_counter(String name) {
    final buffer = body_joint_counter[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_counter[name];
  }
  double? getValue_from_body_joint_max_movement(String name) {
    final buffer = body_joint_max_movement[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_max_movement[name];
  }
  double? getValue_from_body_joint_min_movement(String name) {
    final buffer = body_joint_min_movement[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_min_movement[name];
  }
  direction? getDirection_from_body_joint(String name) {
    final buffer = body_joint_movement_dir[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_movement_dir[name];
  }
  bool? getValue_from_was_it_down(String name) {
    final buffer = body_joint_was_it_down[name];
    if (buffer == null) return null; //oder problem printen
    return body_joint_was_it_down[name];
  }



  // beim printen der feedbacks über get darauf zugreifen
  //für arme 180, 30, 5, 85, 1
  //für wes links und rechts
  void checkStatic_execution(String name, double target_angle, double tolerance, int counter_tolerance, double score_tolerance, int score_weight){

    final average_angle_probably = getAverage_from_body_joint_buffer(name);
    if (average_angle_probably == null) {
      return;
    }
    double average_angle = average_angle_probably;

    final bent_count_probably = getValue_from_body_joint_counter(name);
    if (bent_count_probably == null) {
      return;
    }
    int bent_count = bent_count_probably;

    score.add(scorewithTolerances(target_angle, average_angle, score_tolerance), score_weight); //vorher 30

    /*
    final debug_feedback_probably = getValue_from_body_joint_feedback(name);
    if (debug_feedback_probably == null) {
      return;
    }
    String feedback = debug_feedback_probably;
    debug_name = name;
    debug_counter = bent_count.toString();
    debug_feedback = feedback;
    debug_angle = average_angle.toString();
    */


    if(average_angle < target_angle-tolerance){
      update_Buffer_counter(name, bent_count+1);
    } else{
      update_Buffer_counter(name, 0);
      update_Buffer_feedback(name, name + " good");
      neg_feedback = false;
      print("good");
    }

    if(bent_count > counter_tolerance){
      update_Buffer_feedback(name, name + " nicht gerade");
      badFeedback.add(FeedbackItem(label: "$name nicht gerade", timestamp: getFormattedStopwatchTimestamp()));
      errorCounters["nicht_gerade"] = (errorCounters["nicht_gerade"] ?? 0) + 1;
      neg_feedback = true;
      print("not straight");
    }
  }


  /*
  double max_angle = 85.0;
  double min_angle = 20.0;
  updown ist 20
  downup ist 25
  weight ist 10
  */
  //tolleranzen einstellbar machen ab wann etwas gut ist oder schlecht oder unzureichend
  //wenn average zwischen links und rechts dann combined Buffer eintrag (also buffer für l und r machen und da denn den durchschnitt der werte rein machen) machen und dann auch feedback auf das eine bekommen
  void checkRepeating_execution(String name, double max_angle, double min_angle, double score_updown_tolerance, double score_downup_tolerance, int score_weight, List<double> upper_tolerances, List<double> downer_tolerances, bool hyper_movement){

    final average_angle_probably = getAverage_from_body_joint_buffer(name);
    if (average_angle_probably == null) {
      return;
    }
    double average_angle = average_angle_probably;

    final max_movement_angle_probably = getValue_from_body_joint_max_movement(name);
    if (max_movement_angle_probably == null) {
      return;
    }
    double max_movement_angle = max_movement_angle_probably;

    final min_movement_angle_probably = getValue_from_body_joint_min_movement(name);
    if (min_movement_angle_probably == null) {
      return;
    }
    double min_movement_angle = min_movement_angle_probably;

    final movement_dir_probably = getDirection_from_body_joint(name);
    if (movement_dir_probably == null) {
      return;
    }
    direction movement_dir = movement_dir_probably;

    final counter_probably = getValue_from_body_joint_counter(name);
    if (counter_probably == null) {
      return;
    }
    int counter = counter_probably;

    final was_it_down_probably = getValue_from_was_it_down(name);
    if (was_it_down_probably == null) {
      return;
    }
    bool was_it_down = was_it_down_probably;


    bool direction_changed = false;
    directionchange dirchange = directionchange.updown;


    //ab hier debug!
    final debug_feedback_probably = getValue_from_body_joint_feedback(name);
    if (debug_feedback_probably == null) {
      return;
    }
    String feedback = debug_feedback_probably;

    debug_name = name;
    debug_counter = counter.toString();
    debug_was_it_down = was_it_down.toString();
    debug_feedback = feedback;
    debug_angle = average_angle.toString();
    debug_dir = movement_dir.toString();
    debug_score = score.average;
    //bis hier debug!


    if(movement_dir == direction.down){ // Down -> Up
      if (min_movement_angle < average_angle){ //größer werdende entfernung zum minimum
        direction_changed = true;
        dirchange = directionchange.downup;
        update_Buffer_min_movement(name, 180);
      }else{
        update_Buffer_min_movement(name, average_angle);
      }
    }
    else{ // up -> down
      if (max_movement_angle > average_angle){ //größer werdende entfernung zum maximum
        direction_changed = true;
        dirchange = directionchange.updown;
        update_Buffer_max_movement(name, 0);
      }else{
        update_Buffer_max_movement(name, average_angle);
      }
    }

    if (direction_changed == true){

      if(dirchange == directionchange.updown){
        //haltung ausgleichen mit guter wdh
        score.add(scorewithTolerances(max_angle, average_angle, score_updown_tolerance), score_weight);
        double esh_upper_diff = max_angle - average_angle;
        //todo: toleranz werte tweaken ?

        if (esh_upper_diff < upper_tolerances[0] && hyper_movement) {
          update_Buffer_feedback(name, name + " zu hoch");
          //bad feedbackadd wenn ne anhal davon kam
          badFeedback.add(FeedbackItem(label: "$name zu hoch", timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["oben_zu_hoch"] = (errorCounters["oben_zu_hoch"] ?? 0) + 1;
          neg_feedback = true;
          score.add(0.8,2); //strafpunkt für die gesundheit
          if (was_it_down){
            update_joint_Buffer_was_it_down(name, false);
            update_Buffer_counter(name, counter+1);
          }
        } else
        if (esh_upper_diff < upper_tolerances[1]) {
          update_Buffer_feedback(name, name + " oben super");
          goodFeedback.add(FeedbackItem(label: "$name oben super",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["oben_sehr_gut"] = (errorCounters["oben_sehr_gut"] ?? 0) + 1;
          neg_feedback = false;
          if (was_it_down){
            update_joint_Buffer_was_it_down(name, false);
            update_Buffer_counter(name, counter+1);
          }
        } else
        if (esh_upper_diff < upper_tolerances[2]) {
          update_Buffer_feedback(name, name + " oben gut");
          goodFeedback.add(FeedbackItem(label: "$name oben gut",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["oben_sehr_gut"] = (errorCounters["oben_sehr_gut"] ?? 0) + 1;
          neg_feedback = false;
          if (was_it_down){
            update_joint_Buffer_was_it_down(name, false);
            update_Buffer_counter(name, counter+1);
          }
        } else
        if (esh_upper_diff < upper_tolerances[3]) {
          update_Buffer_feedback(name, name + " oben noch etwas höher");
          //tips.add(FeedbackItem(label: "$name oben noch etwas höher"));
          badFeedback.add(FeedbackItem(label: "$name oben noch etwas höher",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["oben_zu_niedrig"] = (errorCounters["oben_zu_niedrig"] ?? 0) + 1;

          neg_feedback = false;
        } else
        if (esh_upper_diff < upper_tolerances[4]) {
          update_Buffer_feedback(name, name + " oben zu niedrig");
          badFeedback.add(FeedbackItem(label: "$name zu niedrig",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["oben_zu_niedrig"] = (errorCounters["oben_zu_niedrig"] ?? 0) + 1;

          neg_feedback = true;
        }
      }
      //tolleranz 10, 15,20,25
      if(dirchange == directionchange.downup){

        score.add(scorewithTolerances(min_angle, average_angle, 25.0), 10);
        double esh_downer_diff = average_angle - min_angle;

        //todo: toleranz werte tweaken ? //feedback reaktion noch langsam

        if (esh_downer_diff < downer_tolerances[0]) {
          update_Buffer_feedback(name, name + " unten super");
          goodFeedback.add(FeedbackItem(label: "$name unten super",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["unten_sehr_gut"] = (errorCounters["unten_sehr_gut"] ?? 0) + 1;


          if(!was_it_down){
            update_joint_Buffer_was_it_down(name, true);
          }
        } else
        if (esh_downer_diff < downer_tolerances[1]) {
          update_Buffer_feedback(name, name + " unten gut");
          goodFeedback.add(FeedbackItem(label: "$name unten gut",timestamp: getFormattedStopwatchTimestamp()));
          errorCounters["unten_gut"] = (errorCounters["unten_gut"] ?? 0) + 1;


          if(!was_it_down){
            update_joint_Buffer_was_it_down(name, true);
          }
        } else
        if (esh_downer_diff < downer_tolerances[2]) {
          update_Buffer_feedback(name, name + " unten weiter runter");
          badFeedback.add(FeedbackItem(label: "$name unten weiter runter"));
          errorCounters["unten_zu_hoch"] = (errorCounters["unten_zu_hoch"] ?? 0) + 1;

        } else
        if (esh_downer_diff < downer_tolerances[3]) {
          update_Buffer_feedback(name, name + " unten viel weiter runter");
          badFeedback.add(FeedbackItem(label: "$name unten viel weiter runter"));
          errorCounters["unten_viel_zu_hoch"] = (errorCounters["unten_viel_zu_hoch"] ?? 0) + 1;

          neg_feedback = false;
        }
      }
      direction_changed = false; //abgearbeitet


      //zu schnelle wechsel nicht anerkennen
      final now = DateTime.now();
      if (_lastActionTime == null ||
          now.difference(_lastActionTime!) > _cooldown) {
        if (movement_dir == direction.up){
          update_joint_Buffer_movement_dir(name, direction.down);
        }
        else{
          update_joint_Buffer_movement_dir(name, direction.up);
        }
        _lastActionTime = now;
      }
    }
  }
//eine funktion die checkt ob es negatives feedback gibt und dann sagt
//funktion die input image speichert zusätzlich zu negativem feedback wenn dieser eintritt
//bei negativem feedback wird diese funktion aufgerufen und macht ein foto davon

/*
  got_you_in_4k(InputImage inputImage){
    //TODO:adden im speicher und probleme lösen
    //problem verzögerung durch buffer average kann zu einem bild an falscher stelle führen
    //Problem es sollen nicht durchgängig werte aufgenommen werden sonderneinmal pro problem

    //neg_feedback wieder auf false machen wenn das hier abgeklappert wurde

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

      von allen namen die feedbacks nehmen

    ]);
    //timespamp ? auch abspeichern ?

    //print(results[0][0]); // Lateral Raises
    //results[0] ereignis
    return;
  }*/

}

//wichtig für Lat
//grade sitzen, schulter zurück
//ellenbogen bis ca10-15° halten
//schräg nach vorne
//nicht höher als schulterhöhe
//handgelenke neutral
//kein schultern hochziehen
//kopf bliebt grade


/*
        Todo:
        herausfinden was das starten triggert
        //farben bei neg feedback
        //und dann auch die werte abspeichern in got you in 4k
        //Curls auch machen als einheit erstmal durch stream und mit den veralgemeinerten klassen probieren

        jetzt:
        //notes vom handy


        /*für die zukunft*/
        // dann bewertung pro frame wenn man eine abfolge erreicht aber denn auch nicht von der abfolge zurück geht
        // also eine sequenz vin winkeln die gemacht werden muss

        //pro übung eine liste an toleranzen und winkel erstellen
        //full into KI mit bewegungsablauf oder noch kontrolle haben ?
        */
//scores einfluss kann hier mit der certenty gewichtet werden
//bei geringerer likelyhood mehr tolleranter beim winkel bestimmen
//likelyhood gilt auch für z werte die wir im 2dimensionalen ignorieren