import '../movement_reference.dart';

class LateralRaiseReference extends MovementReference {
  bool armsBent = false;
  bool leftArmBent = false;
  bool rightArmBent = false;
  bool leftArmExtended = false;
  bool rightArmExtended = false;

  LateralRaiseReference(double upperAngle, double lowerAngle, double tolerance, double minTime)
      : super(upperAngle, lowerAngle, tolerance, minTime);

  @override
  void checkExerciseCycle(double leftAngle, double rightAngle) {
    const double raiseThreshold = 85.0;
    const double lowerThreshold = 35.0;

    leftArmBent = leftAngle > raiseThreshold;
    rightArmBent = rightAngle > raiseThreshold;
    leftArmExtended = leftAngle < lowerThreshold;
    rightArmExtended = rightAngle < lowerThreshold;

    if (!armsBent && leftArmBent && rightArmBent) {
      armsBent = true;
      print("Beide Arme oben angekommen!");
    }

    if (armsBent && leftArmExtended && rightArmExtended) {
      armsBent = false;
      reps++;
      print("Arme unten! Wiederholung gezählt! Gesamt: $reps");
    }
  }

}
