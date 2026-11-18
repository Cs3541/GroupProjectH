
import '../models/exercise_model.dart';

class ExercisePresenter {
  final List<Exercise> _exercises = [
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      category: 'Strength',
    ),
    Exercise(
      id: 'squat',
      name: 'Squat',
      category: 'Strength',
    ),
    Exercise(
      id: 'running',
      name: 'Running',
      category: 'Cardio',
    ),
    Exercise(
      id: 'plank',
      name: 'Plank',
      category: 'Core',
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
