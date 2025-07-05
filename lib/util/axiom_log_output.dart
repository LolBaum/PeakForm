import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

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
    await super.init();
  }

  @override
  void output(OutputEvent event) async {
    if (kDebugMode) {
      // Console output will handle logs in debug mode
      return;
    }
    try {
      final uri = Uri.parse('https://api.axiom.co/v1/datasets/$dataset/ingest');
      Map<String, dynamic> logEvent;
      if (event.origin is Map<String, dynamic>) {
        logEvent = Map<String, dynamic>.from(event.origin as Map);
      } else if (event.lines.isNotEmpty) {
        // Try to extract JSON from the log line
        final line = event.lines.first;
        final jsonStart = line.indexOf('{');
        if (jsonStart != -1) {
          final jsonString = line.substring(jsonStart);
          final Map<String, dynamic> logMap = jsonDecode(jsonString);

          // Define which fields belong to user/system context
          const userFields = {
            'user_id',
            'user_email',
            'user_username',
          };
          const systemFields = {
            'os',
            'device_model',
            'os_version',
            'is_physical_device',
            'app_version',
            'build_number',
            'package_name',
            'session_id',
            'brand',
            'hardware',
            'manufacturer',
            'product',
            'android_id',
            'sdk_int',
            'fingerprint',
            'bootloader',
            'board',
            'display',
            'system_name',
            'localized_model',
            'identifier_for_vendor',
            'utsname_machine',
            'utsname_version',
            'utsname_release',
          };

          Map<String, dynamic> userContext = {};
          Map<String, dynamic> systemContext = {};

          // Move fields from logMap to their respective contexts
          for (final key in userFields) {
            if (logMap.containsKey(key)) {
              userContext[key] = logMap.remove(key);
            }
          }
          for (final key in systemFields) {
            if (logMap.containsKey(key)) {
              systemContext[key] = logMap.remove(key);
            }
          }

          logEvent = <String, dynamic>{
            if (userContext.isNotEmpty) 'userContext': userContext,
            if (systemContext.isNotEmpty) 'systemContext': systemContext,
            'message': logMap['message'] ?? '',
          };
        } else {
          logEvent = {'message': event.origin.toString()};
        }
      } else {
        logEvent = {'message': event.origin.toString()};
      }

      logEvent['log_format_version'] = 1;
      logEvent['_time'] = DateTime.now().toUtc().toIso8601String();
      logEvent['level'] = event.level.name;

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body: jsonEncode([logEvent]),
      );
      if (response.statusCode >= 400) {
        debugPrint(
            'Axiom Ingest Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to send log to Axiom: $e');
    }
  }

  @override
  Future<void> destroy() async {
    _client.close();
    await super.destroy();
  }
}

Map<String, dynamic>? extractJsonFromLogLine(String line) {
  final jsonStart = line.indexOf('{');
  if (jsonStart != -1) {
    final jsonString = line.substring(jsonStart);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  return null;
}
