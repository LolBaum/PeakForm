enum ExerciseType {
  lateralRaises,
  bicepCurls,
  pushUps,
  running,
  planks,
  lunges
}

String exerciseTypeToString(ExerciseType type) {
  switch (type) {
    case ExerciseType.lateralRaises:
      return 'Lateral Raises';
    case ExerciseType.bicepCurls:
      return 'Bicep Curls';
    case ExerciseType.pushUps:
      return 'Push Ups';
    default: return 'Placehodler';
  }
}
