import 'dart:async';
import 'performance_service.dart';

class AutoSaveService {
  static double? _currentScore;
  static double? _lastSavedScore;
  static DateTime? _lastUpdateTime;
  
  // Track current score during exercise (doesn't save yet)
  static void updateCurrentScore(double score) {
    _currentScore = score;
    _lastUpdateTime = DateTime.now();
    print('Score tracked: ${score.toStringAsFixed(3)} at ${_lastUpdateTime!.toLocal()}');
  }
  
  // Save score and duration when stopwatch is paused/stopped
  static Future<void> saveScoreOnPause(Duration workoutDuration) async {
    print('=== SAVE ATTEMPT ===');
    print('Current score: $_currentScore');
    print('Workout duration: ${workoutDuration.inSeconds} seconds');
    print('Last saved score: $_lastSavedScore');
    print('Last update time: $_lastUpdateTime');
    
    if (_currentScore != null) {
      // Format duration as MM:SS
      final minutes = workoutDuration.inMinutes.toString().padLeft(2, '0');
      final seconds = (workoutDuration.inSeconds % 60).toString().padLeft(2, '0');
      final durationFormatted = '$minutes:$seconds';

      await PerformanceService.saveScoreWithDuration(_currentScore!, durationFormatted);
      _lastSavedScore = _currentScore;
      print('✅ Workout completed! Score: ${_currentScore!.toStringAsFixed(3)}, Duration: $durationFormatted');

    } else {
      print('❌ No current score to save - may need to exercise longer');
    }
  }
  
  // Get current tracked score (for debugging purposes only - print on terminal)
  static double? getCurrentScore() {
    return _currentScore;
  }

}