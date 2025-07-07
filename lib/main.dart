import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'excercise_screen.dart' show ExcerciseScreen;
import 'result_screen.dart';
import 'package:logger/logger.dart';
import 'package:fitness_app/util/axiom_log_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'package:fitness_app/util/custom_pretty_printer.dart';
import 'l10n/app_localizations.dart';
import 'screens/camera_screen.dart' show CameraScreen;
import 'package:provider/provider.dart';
import 'package:fitness_app/providers/pose_detection_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

late final Logger logger;

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before loading assets
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");
  final axiomApiToken = dotenv.env['AXIOM_API_TOKEN'];
  final axiomDataset = dotenv.env['AXIOM_DATASET'];

  // A safety check to ensure the variables are loaded
  if (axiomApiToken == null || axiomDataset == null) {
    // ignore: avoid_print
    print(
      'FATAL ERROR: .env file not found or variables are not set.',
    );
    return;
  }

  // Initialize the logger with the credentials from .env
  logger = Logger(
    printer: kDebugMode ? CustomPrettyPrinter() : SimplePrinter(),
    output: MultiOutput([
      ConsoleOutput(),
      // Only send to Axiom in production mode
      if (!kDebugMode)
        AxiomLogOutput(
          dataset: axiomDataset,
          apiToken: axiomApiToken,
        ),
    ]),
    filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
  );

  await LoggingService.instance.init(logger);
  LoggingService.instance.setScreenContext("AppStart");
  LoggingService.instance.setUserContext(
      id: dotenv.env['USER_ID'] ?? '123',
      email: dotenv.env['USER_EMAIL'] ?? 'test@test.com',
      username: dotenv.env['USER_NAME'] ?? 'test');

  // Test logging in different modes
  if (kDebugMode) {
    LoggingService.instance
        .i('🔧 Running in DEBUG mode - logs will appear in console');
  } else {
    LoggingService.instance
        .i('🚀 Running in PRODUCTION mode - logs will be sent to Axiom');
  }

  return runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
      ),

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      initialRoute: '/',
      routes: {
        '/': (context) =>
            HomeScreen(userName: dotenv.env['USER_NAME'] ?? 'TestUser'),
        // TODO: refactor naming for running route
        '/video': (context) => FutureBuilder<Uint8List>(
              future: DefaultAssetBundle.of(context)
                  .load('assets/images/thumbnail/thumbnail-running.jpeg')
                  .then((bd) => bd.buffer.asUint8List()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return ExcerciseScreen(
                  title: 'Running',
                  videoAsset: 'assets/videos/running/running.mov',
                  thumbnailBytes: snapshot.data!,
                  exerciseTags: const ['Waden', 'Oberschenkel'],
                  executionSteps: const [
                    'Start with a hip-width stance',
                    'Your toes point slightly outwards',
                    'Always keep your back straight',
                    'Your hands do not touch your head',
                  ],
                  onPlayVideo: () async {
                    final byteData = await DefaultAssetBundle.of(context)
                        .load('assets/videos/running/running.mov');
                    final tempDir = await getTemporaryDirectory();
                    final file = File('${tempDir.path}/running.mov');
                    await file.writeAsBytes(byteData.buffer.asUint8List());
                    await OpenFile.open(file.path);
                  },
                );
              },
            ),
        '/gym': (context) => FutureBuilder<Uint8List>(
              future: DefaultAssetBundle.of(context)
                  .load(
                      'assets/images/thumbnail/thumbnail-dumbbell-lateral-raises.jpeg')
                  .then((bd) => bd.buffer.asUint8List()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                //TODO: Translations of title and execution steps
                return ExcerciseScreen(
                  title: 'Dumbbell Lateral Raises',
                  videoAsset: 'assets/videos/gym/Dumbbell-Lateral-Raises.mov',
                  thumbnailBytes: snapshot.data!,
                  exerciseTags: const ['Arme', 'Trizeps'],
                  executionSteps: const [
                    'Stand with feet shoulder-width apart',
                    'Hold dumbbells at your sides',
                    'Keep your elbows close to your body',
                    'Raise the dumbbells to shoulder height',
                    'Lower the dumbbells back to the starting position',
                    'Repeat for the desired number of reps',
                  ],
                  onPlayVideo: () async {
                    final byteData = await DefaultAssetBundle.of(context)
                        .load('assets/videos/gym/Dumbbell-Lateral-Raises.mov');
                    final tempDir = await getTemporaryDirectory();
                    final file =
                        File('${tempDir.path}/Dumbbell-Lateral-Raises.mov');
                    await file.writeAsBytes(byteData.buffer.asUint8List());
                    await OpenFile.open(file.path);
                  },
                );
              },
            ),
        '/result': (context) {
          final videoPath =
              ModalRoute.of(context)?.settings.arguments as String?;
          final translation = AppLocalizations.of(context)!;
          return ResultScreen(
            goodFeedback: [
              FeedbackItem(
                  label: translation.tooltip_good_posture, timestamp: "00:10"),
              FeedbackItem(label: translation.tooltip_good_breathing),
            ],
            badFeedback: [
              FeedbackItem(
                  label: translation.result_bad_arms, timestamp: "00:20"),
              FeedbackItem(
                  label: translation.result_bad_heel, timestamp: "00:32"),
              FeedbackItem(
                  label: translation.result_bad_calf, timestamp: "00:45"),
            ],
            tips: [
              FeedbackItem(label: translation.result_tip_midfoot),
              FeedbackItem(label: translation.result_tip_arms),
            ],
            videoPath: videoPath,
          );
        },
        // TOOD: refactor naming
        '/pose_detection': (context) => ChangeNotifierProvider(
              create: (_) => PoseDetectionProvider(),
              child: const CameraScreen(),
            ),
      },
    );
  }
}
