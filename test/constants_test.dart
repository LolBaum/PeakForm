import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/constants/constants.dart';

void main() {
  group('Constants Tests', () {
    test('Color constants are properly defined', () {
      expect(darkGreen, isA<Color>());
      expect(green, isA<Color>());

      // Test that colors are not null
      expect(darkGreen, isNotNull);
      expect(green, isNotNull);
    });
  });
}
