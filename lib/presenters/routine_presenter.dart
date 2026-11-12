import '../models/routine_exercise_model.dart';
import '../models/routine_model.dart';
import 'package:uuid/uuid.dart';

class RoutinePresenter {
  static final List<Routine> _routines = [];

  List<Routine> getAllRoutines() {
    return List.unmodifiable(_routines);
  }

  Routine addRoutine(String name) {
    var id = name.trim().toLowerCase();

    final routine = Routine(id: id, name: name.trim(), exercises: []);
    _routines.add(routine);
    return routine;
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((routine) => routine.id == id);
  }

  RoutineExercise? addExerciseToRoutine(
    String routineId,
    String exerciseId, {
    int? goalSets,
    int? goalReps,
    int? goalWeight,
    double? goalDuration,
    int? goalDistance,
  }) {
    final routine = getRoutineById(routineId);
    if (routine == null) return null;

    const uuid = Uuid();
  
    final routineExercise = RoutineExercise(
      id: uuid.v4(),
      exerciseId: exerciseId,
      goalSets: goalSets,
      goalReps: goalReps,
      goalWeight: goalWeight,
      goalDuration: goalDuration,
      goalDistance: goalDistance,
    );
    routine.exercises.add(routineExercise);
    return routineExercise;
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