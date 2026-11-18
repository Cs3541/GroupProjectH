import 'workout_model.dart';

class ActiveSet {
  static int _nextId = 0;

  final int id;
  double? weight;
  int? reps;
  double? rpe;
  bool completed;

  ActiveSet({this.weight, this.reps, this.rpe, this.completed = false})
      : id = _nextId++;
}

class ActiveExercise {
  static int _nextId = 0;

  final int id;
  String exerciseId;
  String name;
  final List<ActiveSet> sets;

  ActiveExercise({
    required this.exerciseId,
    required this.name,
    List<ActiveSet>? sets,
  })  : id = _nextId++,
        sets = sets ?? [];
}

class ActiveWorkout {
  String name;
  final DateTime startedAt;
  final String? routineId;
  final List<ActiveExercise> exercises = [];

  ActiveWorkout({required this.name, DateTime? startedAt, this.routineId})
      : startedAt = startedAt ?? DateTime.now();

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get completedSets => exercises.fold(
      0, (sum, e) => sum + e.sets.where((s) => s.completed).length);

  Workout toWorkout({required Duration duration}) {
    final entries = <ExerciseEntry>[];
    for (final e in exercises) {
      final done = e.sets
          .where((s) => s.completed)
          .map((s) => WorkoutSet(
                reps: s.reps ?? 0,
                weight: s.weight ?? 0,
                rpe: s.rpe,
              ))
          .toList();
      if (done.isNotEmpty) {
        entries.add(ExerciseEntry(name: e.name, sets: done));
      }
    }
    return Workout(
      name: name,
      date: startedAt,
      exercises: entries,
      duration: duration,
    );
  }
}