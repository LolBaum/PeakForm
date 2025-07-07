// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get home_last_recording => 'LETZTE AUFNAHME: TENNIS';

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
  String get recording_finish => 'Aufnahme beenden';
}
