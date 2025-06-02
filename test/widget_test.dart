// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:peakform/main.dart';

void main() {
  testWidgets('PeakForm app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PeakFormApp());

    // Verify that the home screen loads with the app title.
    expect(find.text('PeakForm'), findsOneWidget);
    expect(find.text('Welcome to PeakForm'), findsOneWidget);

    // Verify that the main feature cards are present.
    expect(find.text('Pose Detection'), findsOneWidget);
    expect(find.text('Exercise Form'), findsOneWidget);
  });
}
