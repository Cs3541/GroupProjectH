import 'package:flutter/material.dart';
import '../presenters/routine_presenter.dart';
import '../presenters/exercise_presenter.dart';

class RoutineScreen extends StatelessWidget {
  final String routineId;

  const RoutineScreen({
    super.key,
    required this.routineId,
  });

  @override
  Widget build(BuildContext context) {
    final routinePresenter = RoutinePresenter();
    final exercisePresenter = ExercisePresenter();

    final routine = routinePresenter.getRoutineById(routineId);

    if (routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Routine Details')),
        body: const Center(
          child: Text('Routine not found.'),
        ),
      );
    }

    final exercises = routine.exerciseIds
        .map((id) => exercisePresenter.getExerciseById(id))
        .whereType<dynamic>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
      ),
      body: exercises.isEmpty
          ? const Center(
              child: Text('No exercises in this routine.'),
            )
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(exercise.name),
                  subtitle: Text([
                    if (exercise.sets != null)
                      '${exercise.sets} sets',
                    if (exercise.reps != null)
                      '${exercise.reps} reps',
                    if (exercise.weight != null)
                      '${exercise.weight} lb',
                    if (exercise.duration != null)
                      '${exercise.duration} seconds',
                    if (exercise.distance != null)
                      '${exercise.distance} meters',
                  ].join(' • ')),
                );
              },
            ),
    );
  }
}