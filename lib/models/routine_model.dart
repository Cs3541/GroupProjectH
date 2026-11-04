// planned exercise in a routine
class RoutineExercise {
  final String name;
  final int targetSets;
  final int targetReps;

  const RoutineExercise({
    required this.name,
    this.targetSets = 3,
    this.targetReps = 10,
  });
}

// Template
class Routine {
  final String name;
  final List<RoutineExercise> exercises;

  const Routine({required this.name, this.exercises = const []});
}