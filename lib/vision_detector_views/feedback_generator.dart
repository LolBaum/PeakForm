
import 'package:google_ml_kit_example/vision_detector_views/exerciseType.dart';
import 'package:google_ml_kit_example/vision_detector_views/globals.dart';

Map<String, int> errorCounters_oben = {
  "oben_sehr_gut": 0,
  "oben_gut": 0,
  "oben_zu_niedrig": 0,
  "oben_zu_hoch":0,
};

Map<String, int> errorCounters_static = {
  "nicht_gerade": 0
};

Map<String, int> errorCounters_unten = {
  "unten_zu_hoch": 0,
  "unten_viel_zu_hoch": 0,
  "unten_sehr_gut": 0,
  "unten_gut": 0,
};

List<String> getSummaryFeedback() {
  print("get summary feedback");
  List<String> summary = [];

  //hier die werte zusammenaddieren alle die oben gelistet sind
  int feedback_counter_oben = (errorCounters_oben["oben_sehr_gut"] ?? 0) + (errorCounters_oben["oben_gut"] ?? 0) + (errorCounters_oben["oben_zu_niedrig"] ?? 0) +  (errorCounters_oben["oben_zu_hoch"] ?? 0);
  int feedback_counter_unten = (errorCounters_unten["unten_sehr_gut"] ?? 0) + (errorCounters_unten["unten_gut"] ?? 0) + (errorCounters_unten["unten_viel_zu_hoch"] ?? 0) +  (errorCounters_unten["unten_zu_hoch"] ?? 0);

  /*
  if ((errorCounters_oben["oben_sehr_gut"] ?? 0)/feedback_counter_oben >= 0.8) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Die Höhe bei den Wiederholungen stimmt meistens!");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Deine Arme sind meistens gut ausgestreckt!");
        break;
      case ExerciseType.lunges:
        summary.add("Deine Beine sind meistens richtig ausgestreckt!");
        break;
    }
  }

  if ((errorCounters_oben["oben_gut"] ?? 0) >= 5) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Das wird gut mit den Lateral Raises!");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Gute Bicep Curls insgesamt!");
        break;
      case ExerciseType.lunges:
        summary.add("Deine Lunges sind nicht schlecht!");
        break;
    }
  }*/

  if ((errorCounters_static["nicht_gerade"] ?? 0) >= 5) {
    summary.add("Deine Arme sind öfters nicht ausgestreckt genug");
  }

  if ((errorCounters_oben["oben_zu_niedrig"] ?? 0)/feedback_counter_oben >= 0.6) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Arme nicht weit genug hochgestreckt");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Arme nicht weit genug ausgestreckt beim Runterziehen");
        break;
      case ExerciseType.lunges:
        summary.add("Beine beim Hochgehen etwas mehr ausstrecken");
        break;
    }
  }
  if ((errorCounters_oben["oben_zu_hoch"] ?? 0)/feedback_counter_oben >= 0.3) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Du musst deine Arme nicht höher als 90° zu deinem Körper hochziehen");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Zu starke Streckung beim Runtergehen muss nicht sein");
        break;
      case ExerciseType.lunges:
        summary.add("Du musst deine Beine nicht zu sehr durchstrecken");
        break;
    }
  }

  if ((errorCounters_unten["unten_sehr_gut"] ?? 0)/feedback_counter_unten >= 0.7 && (errorCounters_oben["oben_sehr_gut"] ?? 0)/feedback_counter_oben >= 0.7) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Super Lateral Raises!");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Geile Bicep Curls insgesamt!");
        break;
      case ExerciseType.lunges:
        summary.add("Deine Lunges sind klasse!");
        break;
    }
  }

  if ((errorCounters_unten["unten_gut"] ?? 0)/feedback_counter_unten >= 0.7 && (errorCounters_oben["oben_gut"] ?? 0)/feedback_counter_oben >= 0.7) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Das wird gut mit den Lateral Raises!");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Gute Bicep Curls insgesamt!");
        break;
      case ExerciseType.lunges:
        summary.add("Deine Lunges sind nicht schlecht!");
        break;
    }
  }

  if ((errorCounters_unten["unten zu hoch"] ?? 0)/feedback_counter_unten >= 0.7) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Arme beim Runtergehen näher zum Körper ziehen");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Unterarm näher anziehen");
        break;
      case ExerciseType.lunges:
        summary.add("Weiter Runtergehen - Knie sollte Richtung Boden gehen");
        break;
    }
  }
  if ((errorCounters_unten["unten_viel_zu_hoch"] ?? 0)/feedback_counter_unten >= 0.7) {
    switch (mostRecentExercise){
      case ExerciseType.lateralRaises:
        summary.add("Arme beim Runtergehen deutlich näher an den Körper ziehen");
        break;
      case ExerciseType.bicepCurls:
        summary.add("Unterarm viel näher anziehen");
        break;
      case ExerciseType.lunges:
        summary.add("Viel weiter runtergehen - Knie sollte fast am Boden sein");
        break;
    }
  }
  return summary;
}
