class RoutineExercise {
  final String id;
  final String exerciseId;
  final int? goalSets;
  final int? goalReps;
  final int? goalWeight;
  final double? goalDuration; // in seconds
  final int? goalDistance; // in meters

  RoutineExercise({
    required this.id,
    required this.exerciseId,
    this.goalSets,
    this.goalReps,
    this.goalWeight,
    this.goalDuration,
    this.goalDistance,
  });

  Map<String, dynamic> toMap() {
    return {
      'routineExerciseId': id,
      'exerciseId': exerciseId,
      'goalSets': goalSets,
      'goalReps': goalReps,
      'goalWeight': goalWeight,
      'goalDuration': goalDuration,
      'goalDistance': goalDistance,
    };
  }

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['routineExerciseId'],
      exerciseId: map['exerciseId'],
      goalSets: map['goalSets'],
      goalReps: map['goalReps'],
      goalWeight: map['goalWeight'],
      goalDuration: map['goalDuration'],
      goalDistance: map['goalDistance'],
    );
  }
}