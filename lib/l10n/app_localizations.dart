import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PeakForm'**
  String get appTitle;

  /// No description provided for @home_hi_user.
  ///
  /// In en, this message translates to:
  /// **'Hi, {userName}!'**
  String home_hi_user(Object userName);

  /// No description provided for @home_progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get home_progress;

  /// No description provided for @home_level.
  ///
  /// In en, this message translates to:
  /// **'LVL. 10'**
  String get home_level;

  /// No description provided for @home_last_recording.
  ///
  /// In en, this message translates to:
  /// **'LAST RECORDING: TENNIS'**
  String get home_last_recording;

  /// No description provided for @home_record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get home_record;

  /// No description provided for @home_choose_sport.
  ///
  /// In en, this message translates to:
  /// **'Choose your sport'**
  String get home_choose_sport;

  /// No description provided for @home_sport_tile_title_tennis.
  ///
  /// In en, this message translates to:
  /// **'TENNIS'**
  String get home_sport_tile_title_tennis;

  /// No description provided for @home_sport_tile_title_running.
  ///
  /// In en, this message translates to:
  /// **'RUNNING'**
  String get home_sport_tile_title_running;

  /// No description provided for @home_sport_tile_title_gym.
  ///
  /// In en, this message translates to:
  /// **'GYM'**
  String get home_sport_tile_title_gym;

  /// No description provided for @home_sport_tile_title_golf.
  ///
  /// In en, this message translates to:
  /// **'GOLF'**
  String get home_sport_tile_title_golf;

  /// No description provided for @home_sport_tile_subtitle_tennis.
  ///
  /// In en, this message translates to:
  /// **'TECHNIQUE'**
  String get home_sport_tile_subtitle_tennis;

  /// No description provided for @home_sport_tile_subtitle_running.
  ///
  /// In en, this message translates to:
  /// **'RUNNING ECONOMY AND DRILLS'**
  String get home_sport_tile_subtitle_running;

  /// No description provided for @home_sport_tile_subtitle_gym.
  ///
  /// In en, this message translates to:
  /// **'TECHNIQUE'**
  String get home_sport_tile_subtitle_gym;

  /// No description provided for @home_sport_tile_subtitle_golf.
  ///
  /// In en, this message translates to:
  /// **'SERVES'**
  String get home_sport_tile_subtitle_golf;

  /// No description provided for @home_charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get home_charts;

  /// No description provided for @home_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get home_settings;

  /// No description provided for @gym_master_your.
  ///
  /// In en, this message translates to:
  /// **'MASTER YOUR'**
  String get gym_master_your;

  /// No description provided for @gym_pose_in_gym.
  ///
  /// In en, this message translates to:
  /// **'POSE IN THE GYM'**
  String get gym_pose_in_gym;

  /// No description provided for @gym_improve_flexibility.
  ///
  /// In en, this message translates to:
  /// **'IMPROVE FLEXIBILITY, INCREASE MOBILITY, AND PROMOTE WELL-BEING.'**
  String get gym_improve_flexibility;

  /// No description provided for @gym_course_feedback.
  ///
  /// In en, this message translates to:
  /// **'A COURSE THAT PROVIDES EFFECTIVE FEEDBACK FOR YOUR SQUATS'**
  String get gym_course_feedback;

  /// No description provided for @result_title.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result_title;

  /// No description provided for @feedback_title.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback_title;

  /// No description provided for @tooltip_good.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get tooltip_good;

  /// No description provided for @tooltip_bad.
  ///
  /// In en, this message translates to:
  /// **'BAD'**
  String get tooltip_bad;

  /// No description provided for @result_tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get result_tips;

  /// No description provided for @result_continue.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get result_continue;

  /// No description provided for @tooltip_good_posture.
  ///
  /// In en, this message translates to:
  /// **'Upright, forward-facing posture'**
  String get tooltip_good_posture;

  /// No description provided for @tooltip_good_breathing.
  ///
  /// In en, this message translates to:
  /// **'Regular, stable breathing'**
  String get tooltip_good_breathing;

  /// No description provided for @result_bad_arms.
  ///
  /// In en, this message translates to:
  /// **'Arms too stiff or crossed in front of the body'**
  String get result_bad_arms;

  /// No description provided for @result_bad_heel.
  ///
  /// In en, this message translates to:
  /// **'First contact with the heel [00:20min]'**
  String get result_bad_heel;

  /// No description provided for @result_bad_calf.
  ///
  /// In en, this message translates to:
  /// **'Left calf raised too high [00:32min]'**
  String get result_bad_calf;

  /// No description provided for @result_tip_midfoot.
  ///
  /// In en, this message translates to:
  /// **'Land with the midfoot first'**
  String get result_tip_midfoot;

  /// No description provided for @result_tip_arms.
  ///
  /// In en, this message translates to:
  /// **'Let your arms swing loosely'**
  String get result_tip_arms;

  /// No description provided for @video_running.
  ///
  /// In en, this message translates to:
  /// **'RUNNING'**
  String get video_running;

  /// No description provided for @video_calf.
  ///
  /// In en, this message translates to:
  /// **'CALF'**
  String get video_calf;

  /// No description provided for @video_thigh.
  ///
  /// In en, this message translates to:
  /// **'THIGH'**
  String get video_thigh;

  /// No description provided for @video_duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get video_duration;

  /// No description provided for @video_duration_value.
  ///
  /// In en, this message translates to:
  /// **'20MIN'**
  String get video_duration_value;

  /// No description provided for @video_difficulty.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY'**
  String get video_difficulty;

  /// No description provided for @video_difficulty_value.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get video_difficulty_value;

  /// No description provided for @video_intensity.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY'**
  String get video_intensity;

  /// No description provided for @video_intensity_value.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get video_intensity_value;

  /// No description provided for @video_start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get video_start;

  /// No description provided for @video_course_description.
  ///
  /// In en, this message translates to:
  /// **'DO YOU WANT TO RUN MORE EASILY, FASTER, AND WITH FEWER INJURIES? OUR INNOVATIVE RUNNING COURSE MAKES IT POSSIBLE! WE COMBINE PROFESSIONAL COACHING WITH THE LATEST TECHNOLOGY TO TAKE YOUR RUNNING TRAINING TO A WHOLE NEW LEVEL.'**
  String get video_course_description;

  /// No description provided for @pose_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get pose_permission_required;

  /// No description provided for @pose_permission_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get pose_permission_dialog_title;

  /// No description provided for @pose_permission_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'This app needs camera access to detect poses using MoveNet. Please grant camera permission in settings.'**
  String get pose_permission_dialog_content;

  /// No description provided for @pose_permission_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pose_permission_dialog_cancel;

  /// No description provided for @pose_permission_dialog_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pose_permission_dialog_settings;

  /// No description provided for @pose_count.
  ///
  /// In en, this message translates to:
  /// **'Poses: {count}'**
  String pose_count(Object count);

  /// No description provided for @pose_confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}%'**
  String pose_confidence(Object confidence);

  /// No description provided for @recording_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish Recording'**
  String get recording_finish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
