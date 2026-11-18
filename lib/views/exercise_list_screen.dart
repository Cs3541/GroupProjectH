import 'package:flutter/material.dart';
import '../presenters/exercise_presenter.dart';

class ExerciseListScreen extends StatelessWidget {
  final ExercisePresenter _exercisePresenter = ExercisePresenter();
  final bool isSelecting; // true when opened to pick an exercise

  ExerciseListScreen({super.key, this.isSelecting = false});

  @override
  Widget build(BuildContext context) {
    final exercises = _exercisePresenter.getAllExercises();

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelecting ? 'Choose an Exercise' : 'Exercise List'),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(exercise.name),
            subtitle: Text(exercise.category),
            onTap: isSelecting
                ? () => Navigator.pop(context, exercise) // send it back
                : null,
          );
        },
      ),
    );
  }
}
