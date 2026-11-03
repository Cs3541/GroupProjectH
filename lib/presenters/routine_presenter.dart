import '../models/routine_model.dart';

class RoutinePresenter {
  static final List<Routine> _routines = [
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

  Routine addRoutine(String name) {
    var id = name.trim().toLowerCase();

    final routine = Routine(id: id, name: name.trim(), exerciseIds: []);
    _routines.add(routine);
    return routine;
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((routine) => routine.id == id);
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