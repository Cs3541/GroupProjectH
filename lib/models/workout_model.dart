// 1 set of 1 exercise
class WorkoutSet {
  final int reps;
  final double weight;

  final double? rpe;

  const WorkoutSet({required this.reps, required this.weight, this.rpe});

  double get volume => reps * weight;
}

// 1 exercise in a workout
class ExerciseEntry {
  final String name;
  final List<WorkoutSet> sets;

  const ExerciseEntry({required this.name, this.sets = const []});

  double get volume => sets.fold(0, (sum, s) => sum + s.volume);
}

class Workout {
  final String name;
  final DateTime date;
  final List<ExerciseEntry> exercises;

  final Duration duration;

  const Workout({
    required this.name,
    required this.date,
    this.exercises = const [],
    this.duration = Duration.zero,
  });

  double get totalVolume => exercises.fold(0, (sum, e) => sum + e.volume);
}