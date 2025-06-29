import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:fitness_app/util/axiom_log_output.dart';

void main() {
  group('AxiomLogOutput Tests', () {
    late AxiomLogOutput axiomLogOutput;

    setUp(() {
      axiomLogOutput = AxiomLogOutput(
        dataset: 'test-dataset',
        apiToken: 'test-token',
      );
    });

    test('AxiomLogOutput can be created with valid parameters', () {
      expect(axiomLogOutput.dataset, 'test-dataset');
      expect(axiomLogOutput.apiToken, 'test-token');
    });

    test('AxiomLogOutput initializes without errors', () async {
      await expectLater(
        axiomLogOutput.init(),
        completes,
      );
    });

    test('AxiomLogOutput destroys without errors', () async {
      await expectLater(
        axiomLogOutput.destroy(),
        completes,
      );
    });

    test('AxiomLogOutput handles empty output events', () async {
      final event = OutputEvent(
        LogEvent(Level.info, 'Test', error: null, stackTrace: null),
        [],
      );

      // Should not throw an error
      expect(() => axiomLogOutput.output(event), returnsNormally);
    });

    test('AxiomLogOutput handles output events with lines', () async {
      final event = OutputEvent(
        LogEvent(Level.info, 'Test', error: null, stackTrace: null),
        ['Test log message'],
      );

      // Should not throw an error
      expect(() => axiomLogOutput.output(event), returnsNormally);
    });

    test('AxiomLogOutput handles multiple log levels', () async {
      final levels = [
        Level.trace,
        Level.debug,
        Level.info,
        Level.warning,
        Level.error,
        Level.fatal,
      ];

      for (final level in levels) {
        final event = OutputEvent(
          LogEvent(level, 'Test', error: null, stackTrace: null),
          ['Test message for $level'],
        );

        // Should not throw an error for any level
        expect(() => axiomLogOutput.output(event), returnsNormally);
      }
    });

    test('AxiomLogOutput handles multiple lines in one event', () async {
      final event = OutputEvent(
        LogEvent(Level.info, 'Test', error: null, stackTrace: null),
        [
          'First line',
          'Second line',
          'Third line',
        ],
      );

      // Should not throw an error
      expect(() => axiomLogOutput.output(event), returnsNormally);
    });

    test('AxiomLogOutput handles special characters in log messages', () async {
      final event = OutputEvent(
        LogEvent(Level.info, 'Test', error: null, stackTrace: null),
        [
          'Message with special chars: !@#\$%^&*()',
          'Message with emojis: rocket phone computer',
          'Message with unicode: αβγδε',
        ],
      );

      // Should not throw an error
      expect(() => axiomLogOutput.output(event), returnsNormally);
    });

    test('AxiomLogOutput handles very long log messages', () async {
      final longMessage = 'A' * 1000; // 1000 character message
      final event = OutputEvent(
        LogEvent(Level.info, 'Test', error: null, stackTrace: null),
        [longMessage],
      );

      // Should not throw an error
      expect(() => axiomLogOutput.output(event), returnsNormally);
    });

    test('AxiomLogOutput can be recreated multiple times', () {
      for (int i = 0; i < 5; i++) {
        final newOutput = AxiomLogOutput(
          dataset: 'dataset-$i',
          apiToken: 'token-$i',
        );

        expect(newOutput.dataset, 'dataset-$i');
        expect(newOutput.apiToken, 'token-$i');
      }
    });
  });
}
