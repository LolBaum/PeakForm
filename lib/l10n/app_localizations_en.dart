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
  String get excercise_lunges_title => 'Lunges';

  @override
  String get excercise_lunges_tagOne => 'Core';

  @override
  String get excercise_lunges_tagTwo => 'Quadtriceps';

  @override
  String get excercise_lunges_tagThree => 'Hamstrings';

  @override
  String get excercise_lunges_executionSteps_One =>
      'Start in a standing position, with your feet wider than shoulder-width apart.';

  @override
  String get excercise_lunges_executionSteps_Two =>
      'Keep your legs straight and your upper body upright.';

  @override
  String get excercise_lunges_executionSteps_Three =>
      'Ensure your hands are not touching your body.';

  @override
  String get excercise_lunges_executionSteps_Four =>
      'Bend your knees and move into a wide side lunge, keeping the other leg straight.';

  @override
  String get excercise_lunges_executionSteps_Five =>
      'Lower your hips to knee height.';

  @override
  String get excercise_lunges_executionSteps_Six =>
      'Change the leg after each repetition';

  @override
  String get excercise_plank_title => 'Plank Hold';

  @override
  String get excercise_plank_tagOne => 'Core';

  @override
  String get excercise_plank_tagTwo => 'Basin';

  @override
  String get excercise_plank_executionSteps_One =>
      'The elbows are under the shoulders';

  @override
  String get excercise_plank_executionSteps_Two =>
      'Head, shoulders, hips and knees form a line';

  @override
  String get exercise_screen_execution_subtitle => 'Execution';

  @override
  String get exercise_screen_title => 'Execution in Detail';

  @override
  String get excercise_running_title => 'Running';

  @override
  String get excercise_running_tagOne => 'Calves';

  @override
  String get excercise_running_tagTwo => 'Thighs';

  @override
  String get excercise_running_executionSteps_One =>
      'Fluid movements, regular strides.';

  @override
  String get excercise_running_executionSteps_Two =>
      'Use handles for balance, do not lean heavily.';

  @override
  String get excercise_gym_title => 'Dumbbell';

  @override
  String get excercise_gym_tagOne => 'Arms';

  @override
  String get excercise_gym_tagTwo => 'Triceps';

  @override
  String get excercise_gym_executionSteps_One =>
      'Start in an upright position with a dumbbell in each hand, your arms hanging at your sides';

  @override
  String get excercise_gym_executionSteps_Two =>
      'Keep your core engaged at all times';

  @override
  String get excercise_gym_executionSteps_Three => 'Your arms remain extended.';

  @override
  String get excercise_gym_executionSteps_Four =>
      'Raise your arms sideways to shoulder height';

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
  String get primary_button_close => 'Complete';

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
  String get recording_start => 'Start Recording';

  @override
  String get recording_finish => 'Finish Recording';

  @override
  String get camera_permission_required => 'Camera permission required';

  @override
  String get camera_permission_required_description =>
      'This app needs camera access to function. Please grant permission in settings.';
}
