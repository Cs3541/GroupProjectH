import './routine_exercise_model.dart';

class Routine {
  final String id;
  final String name;
  final List<RoutineExercise> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      exercises: (map['exercises'] as List)
          .map((exercise) => RoutineExercise.fromMap(exercise))
          .toList(),
    );
  }
  
}