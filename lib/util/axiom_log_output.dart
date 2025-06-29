import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AxiomLogOutput extends LogOutput {
  final String dataset;
  final String apiToken;
  final http.Client _client;

  AxiomLogOutput({
    required this.dataset,
    required this.apiToken,
  }) : _client = http.Client();

  @override
  Future<void> init() async {
    // You could perform setup here, but it's not needed for this simple case.
    await super.init();
  }

  @override
  void output(OutputEvent event) async {
    try {
      final uri = Uri.parse('https://api.axiom.co/v1/datasets/$dataset/ingest');

      // Axiom expects an array of JSON objects.
      // Each object must have a "_time" field.
      final logEvents = event.lines.map((line) {
        return {
          '_time': DateTime.now().toUtc().toIso8601String(),
          'level': event.level.name,
          'message': line,
        };
      }).toList();

      if (logEvents.isEmpty) {
        return;
      }

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body: jsonEncode(logEvents),
      );

      if (response.statusCode >= 400) {
        // If logging fails, print to console to notify the developer.
        // Don't throw an error that could crash the app.
        // ignore: avoid_print
        print(
          'Axiom Ingest Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to send log to Axiom: $e');
    }
  }

  @override
  Future<void> destroy() async {
    _client.close();
    super.destroy();
  }
}
