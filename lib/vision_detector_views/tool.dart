import 'dart:math';
import 'pose_detector_view.dart';
import 'package:vector_math/vector_math_64.dart';

class Vector3 {
  final double x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator -(Vector3 other) =>
      Vector3(x - other.x, y - other.y, z - other.z);

  double dot(Vector3 other) =>
      x * other.x + y * other.y + z * other.z;

  double magnitude() => sqrt(x * x + y * y + z * z);

  double angleTo(Vector3 other) {
    final dotProduct = dot(other);
    final magnitudeProduct = magnitude() * other.magnitude();
    return acos(dotProduct / magnitudeProduct) * (180 / pi); // Grad
  }
}

// für 3 Vektoren dann die berechnung
double computeJointAngle({
  required Vector3 a,
  required Vector3 b,
  required Vector3 c,
}) {
  final ab = a - b;
  final cb = c - b;
  return ab.angleTo(cb);
}



double scoreForLateralRaise(double angle) {
  if (angle >= 80 && angle <= 100) return 1.0;
  if (angle >= 60 && angle <= 120) return 0.5;
  return 0.0;
}


Vector3? getLandmarkCoordinates(Iterable entries, String name) {
  try {
    final entry = entries.firstWhere((e) => e.key.name == name);
    final landmark = entry.value;
    return Vector3(landmark.x, landmark.y, landmark.z);
  } catch (e) {
    print("Keypoint '$name' nicht gefunden.");
    return null;
  }
}

//nicht nur wrist zu elbow to shoulder sondern auch richtigen winkel zum oberkörper finden (der wird vlt immer über 100 sein)
// dann bewertung pro frame wenn man eine abfolge erreicht aber denn auch nicht von der abfolge zurück geht
// also eine sequenz vin winkeln die gemacht werden muss