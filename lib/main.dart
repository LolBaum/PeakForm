import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart' show VideoScreen;
import 'gym_screen.dart' show GymScreen;
import 'result_screen.dart';
import 'package:logger/logger.dart';
import 'package:fitness_app/util/axiom_log_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    printer: PrettyPrinter(
      methodCount: 1, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat:
          DateTimeFormat.onlyTime, // Should each log print contain a timestamp
    ),
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

  logger.i('Logger initialized successfully.');

  // Test logging in different modes
  if (kDebugMode) {
    logger.i('🔧 Running in DEBUG mode - logs will appear in console');
  } else {
    logger.i('🚀 Running in PRODUCTION mode - logs will be sent to Axiom');
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(userName: 'Norhene'),
        '/video': (context) => const VideoScreen(),
        '/gym': (context) => const GymScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
