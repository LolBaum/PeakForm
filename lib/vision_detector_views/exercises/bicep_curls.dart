import '../tool.dart';

import '../movement_reference.dart';

class BicepCurlReference extends MovementReference {
  bool armsBent = false;
  bool leftArmBent = false;
  bool rightArmBent = false;
  bool leftArmExtended = false;
  bool rightArmExtended = false;

  BicepCurlReference(double upperAngle, double lowerAngle, double tolerance, double minTime)
      : super(upperAngle, lowerAngle, tolerance, minTime);

  @override
  void checkExerciseCycle(double leftAngle, double rightAngle) {
    const double bentThreshold = 20.0;
    const double extendedThreshold = 140.0;

    int leftReps = 0;
    int rightReps = 0;

    leftArmBent = leftAngle < bentThreshold;
    rightArmBent = rightAngle < bentThreshold;
    leftArmExtended = leftAngle > extendedThreshold;
    rightArmExtended = rightAngle > extendedThreshold;

    if (!armsBent && leftArmBent && rightArmBent) {
      armsBent = true;
      print("Beide Unterarme gebeugt!");
    }

    if (armsBent && leftArmExtended && rightArmExtended) {
      armsBent = false;
      reps++;
      print("Arme unten! Wiederholung gezählt! Gesamt: $reps");
    }
  }

}
