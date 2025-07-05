// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PeakForm';

  @override
  String home_hi_user(Object userName) {
    return 'Hi, $userName!';
  }

  @override
  String get home_progress => 'PROGRESS';

  @override
  String get home_level => 'LVL. 10';

  @override
  String get home_last_recording => 'LAST RECORDING: TENNIS';

  @override
  String get home_record => 'Record';

  @override
  String get home_choose_sport => 'Choose your sport';

  @override
  String get home_sport_tile_title_tennis => 'TENNIS';

  @override
  String get home_sport_tile_title_running => 'RUNNING';

  @override
  String get home_sport_tile_title_gym => 'GYM';

  @override
  String get home_sport_tile_title_golf => 'GOLF';

  @override
  String get home_sport_tile_subtitle_tennis => 'TECHNIQUE';

  @override
  String get home_sport_tile_subtitle_running => 'RUNNING ECONOMY AND DRILLS';

  @override
  String get home_sport_tile_subtitle_gym => 'TECHNIQUE';

  @override
  String get home_sport_tile_subtitle_golf => 'SERVES';

  @override
  String get home_charts => 'Charts';

  @override
  String get home_settings => 'Settings';

  @override
  String get gym_master_your => 'MASTER YOUR';

  @override
  String get gym_pose_in_gym => 'POSE IN THE GYM';

  @override
  String get gym_improve_flexibility =>
      'IMPROVE FLEXIBILITY, INCREASE MOBILITY, AND PROMOTE WELL-BEING.';

  @override
  String get gym_course_feedback =>
      'A COURSE THAT PROVIDES EFFECTIVE FEEDBACK FOR YOUR SQUATS';

  @override
  String get result_title => 'Result';

  @override
  String get feedback_title => 'Feedback';

  @override
  String get tooltip_good => 'GOOD';

  @override
  String get tooltip_bad => 'BAD';

  @override
  String get result_tips => 'Tips';

  @override
  String get result_continue => 'Continue';

  @override
  String get tooltip_good_posture => 'Upright, forward-facing posture';

  @override
  String get tooltip_good_breathing => 'Regular, stable breathing';

  @override
  String get result_bad_arms =>
      'Arms too stiff or crossed in front of the body';

  @override
  String get result_bad_heel => 'First contact with the heel [00:20min]';

  @override
  String get result_bad_calf => 'Left calf raised too high [00:32min]';

  @override
  String get result_tip_midfoot => 'Land with the midfoot first';

  @override
  String get result_tip_arms => 'Let your arms swing loosely';

  @override
  String get video_running => 'RUNNING';

  @override
  String get video_calf => 'CALF';

  @override
  String get video_thigh => 'THIGH';

  @override
  String get video_duration => 'DURATION';

  @override
  String get video_duration_value => '20MIN';

  @override
  String get video_difficulty => 'DIFFICULTY';

  @override
  String get video_difficulty_value => 'EASY';

  @override
  String get video_intensity => 'INTENSITY';

  @override
  String get video_intensity_value => 'NORMAL';

  @override
  String get video_start => 'START';

  @override
  String get video_course_description =>
      'DO YOU WANT TO RUN MORE EASILY, FASTER, AND WITH FEWER INJURIES? OUR INNOVATIVE RUNNING COURSE MAKES IT POSSIBLE! WE COMBINE PROFESSIONAL COACHING WITH THE LATEST TECHNOLOGY TO TAKE YOUR RUNNING TRAINING TO A WHOLE NEW LEVEL.';

  @override
  String get pose_permission_required => 'Camera permission required';

  @override
  String get pose_permission_dialog_title => 'Camera Permission Required';

  @override
  String get pose_permission_dialog_content =>
      'This app needs camera access to detect poses using MoveNet. Please grant camera permission in settings.';

  @override
  String get pose_permission_dialog_cancel => 'Cancel';

  @override
  String get pose_permission_dialog_settings => 'Settings';

  @override
  String pose_count(Object count) {
    return 'Poses: $count';
  }

  @override
  String pose_confidence(Object confidence) {
    return 'Confidence: $confidence%';
  }

  @override
  String get recording_finish => 'Finish Recording';
}
