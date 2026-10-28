import '../models/routine_model.dart';

class RoutinePresenter {
  final List<Routine> _routines = [
    Routine(
      id: 'full_body',
      name: 'Full Body Workout',
      exerciseIds: ['bench_press', 'squat', 'plank'],
    ),
    Routine(
      id: 'cardio',
      name: 'Cardio Routine',
      exerciseIds: ['running'],
    ),
  ];

  List<Routine> getAllRoutines() {
    return List.unmodifiable(_routines);
  }

  Routine? getRoutineById(String id) {
    for (final routine in _routines) {
      if (routine.id == id) {
        return routine;
      }
    }

    return null;
  }
}