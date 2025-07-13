enum ExerciseType {
  lateralRaises,
  planks,
  lunges,
  bicepCurls,
  pushUps,
  running,
  tennis,
}

String exerciseTypeToString(ExerciseType type) {
  switch (type) {
    case ExerciseType.lateralRaises:
      return 'Lateral Raises';
    case ExerciseType.planks:
      return 'Planks';
    case ExerciseType.lunges:
      return 'Lunges';
    case ExerciseType.bicepCurls:
      return 'Bicep Curls';
    case ExerciseType.pushUps:
      return 'Push Ups';
      default: return "sdbvfsh";
  }
}
