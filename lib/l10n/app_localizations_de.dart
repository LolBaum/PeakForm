// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import '../vision_detector_views/exerciseType.dart';
import '../vision_detector_views/globals.dart';
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PeakForm';

  @override
  String home_hi_user(Object userName) {
    return 'Hi, $userName!';
  }

  @override
  String get home_progress => 'FORTSCHRITT';

  @override
  String get home_level => 'LVL. 10';

  @override
  String get home_last_recording => 'Letzte Aufnahme: ${exerciseTypeToString(mostRecentExercise)}';

  @override
  String get home_record => 'Aufnehmen';

  @override
  String get home_choose_sport => 'Wähle deinen Sport';

  @override
  String get home_sport_tile_title_tennis => 'TENNIS';

  @override
  String get home_sport_tile_title_running => 'LAUFEN';

  @override
  String get home_sport_tile_title_gym => 'GYM';

  @override
  String get home_sport_tile_title_golf => 'GOLF';

  @override
  String get home_sport_tile_subtitle_tennis => 'TECHNIK';

  @override
  String get home_sport_tile_subtitle_running => 'LAUFÖKONOMIE UND DRILLS';

  @override
  String get home_sport_tile_subtitle_gym => 'TECHNIK';

  @override
  String get home_sport_tile_subtitle_golf => 'AUFSCHLÄGE';

  @override
  String get home_charts => 'Diagramme';

  @override
  String get home_settings => 'Einstellungen';

  @override
  String get gym_master_your => 'MEISTER DEINE';

  @override
  String get gym_pose_in_gym => 'POSE IM GYM';

  @override
  String get gym_improve_flexibility =>
      'VERBESSERN SIE FLEXIBILITÄT, STEIGERN\nSIE MOBILITÄT UND FÖRDERN SIE DAS\nWOHLBEFINDEN.';

  @override
  String get gym_course_feedback =>
      'EIN KURS, DER EFFEKTIVES FEEDBACK FÜR\nIHRE KNIEBEUGEN BIETET';

  @override
  String get excercise_lunges_title => 'Lunges';

  @override
  String get excercise_lunges_tagOne => 'Core';

  @override
  String get excercise_lunges_tagTwo => 'Quadrizeps';

  @override
  String get excercise_lunges_tagThree => 'Hamstrings';

  @override
  String get excercise_lunges_executionSteps_One =>
      'Beginne im Stand, deine Füße sind weiter als schulterbreit auseinander';

  @override
  String get excercise_lunges_executionSteps_Two =>
      'Deine Beine sind durchgestreckt, dein Oberkörper aufrecht';

  @override
  String get excercise_lunges_executionSteps_Three =>
      'Deine Hände berühren den Körper nicht';

  @override
  String get excercise_lunges_executionSteps_Four =>
      'Beuge die Knie und komme in einen breiten Ausfallschritt zur Seite, das andere Bein bleibt durchgestreckt';

  @override
  String get excercise_lunges_executionSteps_Five =>
      'Senke die Hüfte bis auf Kniehöhe ab';

  @override
  String get excercise_lunges_executionSteps_Six =>
      'Wechsle bei jeder Wiederholung das Bein';

  @override
  String get excercise_plank_title => 'Planke halten';

  @override
  String get excercise_plank_tagOne => 'Core';

  @override
  String get excercise_plank_tagTwo => 'Becken';

  @override
  String get excercise_plank_executionSteps_One =>
      'Die Ellbogen sind unter den Schultern';

  @override
  String get excercise_plank_executionSteps_Two =>
      'Kopf, Schultern, Hüfte, und Knie bilden eine Linie';

  @override
  String get exercise_screen_execution_subtitle => 'Ausführung';

  @override
  String get exercise_screen_title => 'Ausführung in Detail';

  @override
  String get excercise_running_title => 'Laufen';

  @override
  String get excercise_running_tagOne => 'Waden';

  @override
  String get excercise_running_tagTwo => 'Oberschenkel';

  @override
  String get excercise_running_executionSteps_One =>
      'Fließende Bewegungen, regelmäßige Schritte.';

  @override
  String get excercise_running_executionSteps_Two =>
      'Griffe zur Gleichgewichtshilfe nutzen, nicht abstützen.';

  @override
  String get excercise_gym_title => 'Dumbell Lateral Raises-Ausführung';

  @override
  String get excercise_gym_tagOne => 'Arme';

  @override
  String get excercise_gym_tagTwo => 'Trizeps';

  @override
  String get excercise_gym_executionSteps_One =>
      '⁠Beginne im aufrechten Stand mit einer Kurzhantel in jeder Hand, deine Arme hängen seitlich neben dem Körper';

  @override
  String get excercise_gym_executionSteps_Two =>
      'Spanne dem Rumpf die ganze Zeit über an';

  @override
  String get excercise_gym_executionSteps_Three =>
      'Deine Arme bleiben ausgestreckt.';

  @override
  String get excercise_gym_executionSteps_Four =>
      'Hebe die Arme seitlich auf Schulterhöhe';

  @override
  String get result_title => 'Ergebnis';

  @override
  String get feedback_title => 'Feedback';

  @override
  String get tooltip_good => 'GUT';

  @override
  String get tooltip_bad => 'SCHLECHT';

  @override
  String get result_tips => 'Tipps';

  @override
  String get primary_button_close => 'Beenden';

  @override
  String get tooltip_good_posture =>
      'Aufrechte, nach vorn gerichtete Körperhaltung';

  @override
  String get tooltip_good_breathing => 'Regelmäßige stabile Atmung';

  @override
  String get result_bad_arms =>
      'Arme zu steif oder überschlagen vor dem Körper';

  @override
  String get result_bad_heel => 'Erstes Aufkommen mit der Ferse [00:20min]';

  @override
  String get result_bad_calf => 'Linke Wade zu weit hochgezogen [00:32min]';

  @override
  String get result_tip_midfoot => 'Mit Mittelfuß zuerst aufkommen';

  @override
  String get result_tip_arms => 'Arme locker mitschwingen lassen';

  @override
  String get video_running => 'LAUFEN';

  @override
  String get video_calf => 'WADEN';

  @override
  String get video_thigh => 'OBERSCHENKEL';

  @override
  String get video_duration => 'DURCH. ZEIT';

  @override
  String get video_duration_value => '20MIN';

  @override
  String get video_difficulty => 'SCHWIERIGKEIT';

  @override
  String get video_difficulty_value => 'EINFACH';

  @override
  String get video_intensity => 'INTENSITÄT';

  @override
  String get video_intensity_value => 'NORMAL';

  @override
  String get video_start => 'START';

  @override
  String get video_course_description =>
      'TRAUST DU DAVON, MÜHELOSER, SCHNELLER UND VERLETZUNGSFREIER ZU LAUFEN? UNSER INNOVATIVER LAUFKURS MACHT ES MÖGLICH! WIR KOMBINIEREN PROFESSIONELLES COACHING MIT DER MODERNSTEN TECHNOLOGIE, UM DEIN LAUFTRAINING AUF EIN VÖLLIG NEUES NIVEAU ZU HEBEN.';

  @override
  String get pose_permission_required => 'Kameraberechtigung erforderlich';

  @override
  String get pose_permission_dialog_title => 'Kameraberechtigung erforderlich';

  @override
  String get pose_permission_dialog_content =>
      'Diese App benötigt Zugriff auf die Kamera, um Posen mit MoveNet zu erkennen. Bitte erteilen Sie die Kameraberechtigung in den Einstellungen.';

  @override
  String get pose_permission_dialog_cancel => 'Abbrechen';

  @override
  String get pose_permission_dialog_settings => 'Einstellungen';

  @override
  String pose_count(Object count) {
    return 'Posen: $count';
  }

  @override
  String pose_confidence(Object confidence) {
    return 'Vertrauen: $confidence%';
  }

  @override
  String get recording_start => 'Aufnahme Starten';

  @override
  String get recording_finish => 'Aufnahme Beenden';

  @override
  String get camera_permission_required => 'Kameraberechtigung erforderlich';

  @override
  String get camera_permission_required_description =>
      'Diese App benötigt Zugriff auf die Kamera. Bitte erteile die Berechtigung in den Einstellungen.';
}
