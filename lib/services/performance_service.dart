import 'package:shared_preferences/shared_preferences.dart';

class PerformanceService {
  // Save a score with current timestamp
  static Future<void> saveScore(double score) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save the score with current timestamp as key
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setDouble('score_$timestamp', score);
    
    // Also save as "latest_score" for easy access
    await prefs.setDouble('latest_score', score);
    
    print('Score saved: $score');
  }

  // Save a score with duration and current timestamp
  static Future<void> saveScoreWithDuration(double score, String duration) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save the score and duration with current timestamp as key
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setDouble('score_$timestamp', score);
    await prefs.setString('duration_$timestamp', duration);
    
    // Also save as "latest_score" for easy access
    await prefs.setDouble('latest_score', score);
    
    print('Score and duration saved: $score, $duration');
  }

  // Get the latest score
  static Future<double?> getLatestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('latest_score');
  }

  // Get all saved scores with timestamps and durations
  static Future<List<Map<String, dynamic>>> getAllScoresWithTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    
    List<Map<String, dynamic>> scores = [];
    for (String key in keys) {
      if (key.startsWith('score_')) {
        double? score = prefs.getDouble(key);
        if (score != null) {
          // Extract timestamp from key (format: 'score_1234567890123')
          String timestampStr = key.substring(6); // Remove 'score_' prefix
          int timestamp = int.tryParse(timestampStr) ?? 0;
          
          // Try to get corresponding duration
          String? duration = prefs.getString('duration_$timestampStr');
          
          scores.add({
            'score': score,
            'timestamp': timestamp,
            'formattedTime': _formatTimestamp(timestamp),
            'duration': duration ?? 'N/A', // Default to 'N/A' if no duration saved
          });
        }
      }
    }
    
    // Sort by timestamp (newest first)
    scores.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    
    return scores;
  }

  // Get all saved scores (simple version for backwards compatibility)
  static Future<List<double>> getAllScores() async {
    final scoresWithTimestamps = await getAllScoresWithTimestamps();
    return scoresWithTimestamps.map((item) => item['score'] as double).toList();
  }
  
  // Format timestamp to dd.mm - HH:MM
  static String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day.$month - $hour:$minute';
  }
} 