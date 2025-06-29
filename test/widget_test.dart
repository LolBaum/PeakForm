// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/home_screen.dart';

void main() {
  // All default tests removed. Add your own widget tests here.

  testWidgets('HomeScreen shows greeting and sections',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: HomeScreen(userName: 'TestUser')));

    // Check for greeting
    expect(find.text('Hi, TestUser!'), findsOneWidget);
    // Check for "Wähle deinen Sport"
    expect(find.text('Wähle deinen Sport'), findsOneWidget);
    // Check for "LETZTE AUFNAHME: TENNIS"
    expect(find.text('LETZTE AUFNAHME: TENNIS'), findsOneWidget);
  });
/*  testWidgets('FitnessApp renders HomeScreen and navigates to /video',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());
    // Should show HomeScreen with Norhene
    expect(find.text('Hi, Norhene!'), findsOneWidget);
    // Tap the LAUFEN tile to navigate to /video
    await tester.tap(find.text('LAUFEN'));
    await tester.pumpAndSettle();
  });*/
}
