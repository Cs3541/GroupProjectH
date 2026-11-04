
import '../models/exercise_model.dart';

class ExercisePresenter {
  final List<Exercise> _exercises = [
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      sets: 3,
      reps: 8,
      weight: 135,
    ),
    Exercise(
      id: 'squat',
      name: 'Squat',
      sets: 3,
      reps: 10,
      weight: 135,
    ),
    Exercise(
      id: 'running',
      name: 'Running',
      duration: 1800,
      distance: 5000,
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      sets: 3,
      duration: 60,
    ),
  ];

  List<Exercise> getAllExercises() {
    return List.unmodifiable(_exercises);
  }

  Exercise? getExerciseById(String id) {
    for (final exercise in _exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }

    return null;
  }
}
