import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_screen.dart' show VideoScreen;
import 'gym_screen.dart' show GymScreen;
import 'result_screen.dart';
import 'package:logger/logger.dart';
import 'package:fitness_app/util/axiom_log_output.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitness_app/util/logging_service.dart';
import 'package:fitness_app/util/custom_pretty_printer.dart';
import 'l10n/app_localizations.dart';

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
        '/video': (context) => const VideoScreen(),
        '/gym': (context) => const GymScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}
