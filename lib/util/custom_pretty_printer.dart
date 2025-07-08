import 'package:logger/logger.dart';

class CustomPrettyPrinter extends PrettyPrinter {
  CustomPrettyPrinter()
      : super(
          methodCount: 1,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTime,
        );

  @override
  List<String> log(LogEvent event) {
    if (event.message is Map) {
      final map = event.message as Map;
      final screen = map['screen'] ?? '';
      final msg = map['message'] ?? '';

      final sessionId = map['session_id'] ?? '';
      final userId = map['user_id'] ?? '';
      final contextStr = {
        if (screen.isNotEmpty) '\n"screen": "$screen"',
        if (sessionId.isNotEmpty) '"session_id": "$sessionId"',
        if (userId.isNotEmpty) '"user_id": "$userId"',
      }.join('\n');
      return super.log(LogEvent(
        event.level,
        '[$contextStr\n]\n\n message: $msg',
        error: event.error,
        stackTrace: event.stackTrace,
      ));
    }
    // Fallback to default
    return super.log(event);
  }
}
