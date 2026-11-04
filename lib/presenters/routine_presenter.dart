import '../models/routine_model.dart';

class RoutinePresenter {
  static final List<Routine> _routines = [
    Routine(
      id: 'full_body',
      name: 'Full Body Workout',
      workoutNames: ['bench_press', 'squat', 'plank'],
    ),
    Routine(
      id: 'cardio',
      name: 'Cardio Routine',
      workoutNames: ['running'],
    ),
  ];

  List<Routine> getAllRoutines() {
    return List.unmodifiable(_routines);
  }

  Routine addRoutine(String name) {
    var id = name.trim().toLowerCase();

    final routine = Routine(id: id, name: name.trim(), workoutNames: []);
    _routines.add(routine);
    return routine;
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((routine) => routine.id == id);
  }

  void addWorkoutToRoutine(String routineId, String workoutName) {
    getRoutineById(routineId)?.workoutNames.add(workoutName);
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