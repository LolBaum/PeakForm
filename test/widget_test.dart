// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:fitness_app/home_screen.dart';
import 'package:fitness_app/providers/pose_detection_provider.dart';
import 'package:fitness_app/frosted_glasst_button.dart';

void main() {
  // Initialize logger for testing
  setUpAll(() {
    Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
      output: ConsoleOutput(),
    );
  });

  group('HomeScreen Tests', () {
    testWidgets('HomeScreen shows greeting and sections',
        (WidgetTester tester) async {
      // Build the widget and trigger a frame
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userName: 'TestUser'),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pumpAndSettle();

      // Check for greeting
      expect(find.text('Hi, TestUser!'), findsOneWidget);

      // Check for "Wähle deinen Sport"
      expect(find.text('Wähle deinen Sport'), findsOneWidget);

      // Check for "LETZTE AUFNAHME: TENNIS"
      expect(find.text('LETZTE AUFNAHME: TENNIS'), findsOneWidget);

      // Check for sport tiles
      expect(find.text('TENNIS'), findsOneWidget);
      expect(find.text('LAUFEN'), findsOneWidget);
      expect(find.text('GYM'), findsOneWidget);
      expect(find.text('GOLF'), findsOneWidget);
    });

    testWidgets('HomeScreen shows correct user name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userName: 'John'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hi, John!'), findsOneWidget);
      expect(find.text('Hi, TestUser!'), findsNothing);
    });

    testWidgets('HomeScreen has circular icon buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userName: 'TestUser'),
        ),
      );

      await tester.pumpAndSettle();

      // Check for circular icon buttons (charts and settings)
      expect(find.byType(Icon), findsWidgets);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('HomeScreen has Aufnehmen button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userName: 'Norhene'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aufnehmen'), findsOneWidget);
    });

/*
    testWidgets('HomeScreen sport tiles are tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(userName: 'Norhene'),
        ),
      );

      await tester.pumpAndSettle();

      // Test tapping on LAUFEN tile (which has a route)
      await tester.tap(find.text('LAUFEN'));
      await tester.pumpAndSettle();

      // Should navigate to video screen
      expect(find.text('LAUFEN'), findsOneWidget); // Still visible in video screen
    });
  });*/
/*
  group('VideoScreen Tests', () {
    testWidgets('VideoScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('LAUFEN'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.text('SCHRITT 1 VON 3'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    });

    testWidgets('VideoScreen has back button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('VideoScreen has exercise tags',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('WADEN'), findsOneWidget);
      expect(find.text('OBERSCHENKEL'), findsOneWidget);
    });

    testWidgets('VideoScreen START button is tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      // Button should still be visible after tap
      expect(find.text('START'), findsOneWidget);
    });
  });

  group('GymScreen Tests', () {
    testWidgets('GymScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GymScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MEISTER DEINE'), findsOneWidget);
      expect(find.text('POSE IM GYM'), findsOneWidget);
      expect(find.text('Back Squat'), findsOneWidget);
      expect(find.text('Front Squat'), findsOneWidget);
      expect(find.text('Hip Thrusts'), findsOneWidget);
      expect(find.text('Mobilität'), findsOneWidget);
    });

    testWidgets('GymScreen has filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GymScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lower Body'), findsOneWidget);
      expect(find.text('Equipment'), findsOneWidget);
      expect(find.text('Abs'), findsOneWidget);
      expect(find.text('Brust'), findsOneWidget);
      expect(find.text('Rücken'), findsOneWidget);
      expect(find.text('Arme'), findsOneWidget);
      expect(find.text('Po'), findsOneWidget);
    });

    testWidgets('GymScreen has back button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GymScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('GymScreen exercise buttons are tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GymScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Back Squat'));
      await tester.pumpAndSettle();

      // Button should still be visible after tap
      expect(find.text('Back Squat'), findsOneWidget);
    });
  });

  group('ResultScreen Tests', () {
    testWidgets('ResultScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ergebnis'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('Tipps'), findsOneWidget);
      expect(find.text('Weiter'), findsOneWidget);
    });

    testWidgets('ResultScreen has good feedback section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('GUT'), findsOneWidget);
      expect(find.text('Aufrechte, nach vorn gerichtete Körperhaltung'), findsOneWidget);
      expect(find.text('Regelmäßige stabile Atmung'), findsOneWidget);
    });

    testWidgets('ResultScreen has bad feedback section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SCHLECHT'), findsOneWidget);
      expect(find.text('Arme zu steif oder überschlagen vor dem Körper'), findsOneWidget);
    });

    testWidgets('ResultScreen has tips section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mit Mittelfuß zuerst aufkommen'), findsOneWidget);
      expect(find.text('Arme locker mitschwingen lassen'), findsOneWidget);
    });

    testWidgets('ResultScreen has back button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('ResultScreen Weiter button is tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      // Button should still be visible after tap
      expect(find.text('Weiter'), findsOneWidget);
    });
  });
*/
    group('PoseDetectionProvider Tests', () {
      test('PoseDetectionProvider initializes correctly', () {
        final provider = PoseDetectionProvider();

        expect(provider.poses, isEmpty);
        expect(provider.isDetecting, isFalse);
        expect(provider.isCameraInitialized, isFalse);
        expect(provider.isModelLoaded, isFalse);
        expect(provider.detectionStatus, 'Initializing...');
        expect(provider.isPlatformSupported, isTrue); // Assuming not web
      });

      test('PoseDetectionProvider can start and stop detection', () {
        final provider = PoseDetectionProvider();

        // Test start detection (should fail without camera initialization)
        provider.startDetection();
        expect(provider.detectionStatus, 'Camera or model not ready');

        // Test stop detection
        provider.stopDetection();
        expect(provider.isDetecting, isFalse);
        expect(provider.detectionStatus, 'Detection stopped');
      });

      test('PoseDetectionProvider has correct constants', () {
        expect(PoseDetectionProvider.inputSize, 192);
        expect(PoseDetectionProvider.numKeypoints, 17);
        expect(PoseDetectionProvider.confidenceThreshold, 0.01);
      });
    });

    group('FrostedGlassButton Tests', () {
      testWidgets('FrostedGlassButton displays correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrostedGlassButton(
                onTap: () {},
                child: const Text('Test Button'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('FrostedGlassButton is tappable',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrostedGlassButton(
                onTap: () {
                  tapped = true;
                },
                child: const Text('Test Button'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Test Button'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('FrostedGlassButton with icon displays correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FrostedGlassButton(
                onTap: () {},
                child: const Icon(Icons.close),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });
  });
}
