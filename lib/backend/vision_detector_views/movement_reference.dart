import 'package:circular_buffer/circular_buffer.dart';
import 'direction.dart';

class MovementReference {
  double upperAngle;
  double lowerAngle;
  double tolerance;
  double minTime;
  direction dir = direction.down;
  bool direction_changed = false;
  DateTime? _lastActionTime;
  final Duration _cooldown = Duration(milliseconds: 250);
  var buffer = CircularBuffer<double>(10);
  double angle = 0;
  double secondary_angle = 180;
  double min_r = 180;
  double max_r = 0;
  double average = 0;
  int bent_count = 0;
  bool bent = false;
  int reps = 0;
  bool armsBent = false;

  bool leftArmBent = false;
  bool rightArmBent = false;
  bool leftArmExtended = false;
  bool rightArmExtended = false;

  MovementReference(this.upperAngle, this.lowerAngle, this.tolerance, this.minTime);

  void checkExerciseCycle(double leftAngle, double rightAngle) {
  }

  void checkElbowAngle(double leftAngle, double rightAngle){
    double tolerance = 30.0;
    double lowerTolerance = 180.0 - tolerance;

    //scorewithTolerances(180.0, rightAngle, 20.0);

    if(leftAngle < lowerTolerance || rightAngle < lowerTolerance){
      bent_count++;
    } else{
      bent_count = 0;
      bent = false;
    }

    if(bent_count > 30){
      print("Arm is not straight");
      bent = true;
    }
  }

  void update_angles(double a, double b){
    angle=a;
    secondary_angle=b;
    buffer.add(angle);
    average = buffer.toList().reduce((a, b) => a + b) / buffer.length;
  }

  void update_direction(){
    if(dir == direction.down){ // Down -> Up
      if (min_r < average){
        direction_changed = true;
        min_r = 180;
      }else{
        min_r = average;
      }
    }
    else{ // up -> down
      if (max_r > average){
        direction_changed = true;
        max_r = 0;
      }else{
        max_r = average;
      }
    }

    if (direction_changed == true){
      // TODO: Evaluate the Position
      direction_changed = false;

      final now = DateTime.now();
      if (_lastActionTime == null ||
          now.difference(_lastActionTime!) > _cooldown) {
        if (dir == direction.up){
          dir = direction.down;
        }
        else{
          dir = direction.up;
        }
        _lastActionTime = now;
      }
    }
  }

}
