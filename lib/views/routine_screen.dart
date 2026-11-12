import 'package:flutter/material.dart';
import '../presenters/routine_presenter.dart';
import '../presenters/exercise_presenter.dart';
import '../models/exercise_model.dart';
import 'confirm_delete_dialog.dart';
import 'exercise_list_screen.dart';

class RoutineScreen extends StatefulWidget {
  final String routineId;

  const RoutineScreen({
    super.key,
    required this.routineId,
  });

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final RoutinePresenter _routinePresenter = RoutinePresenter();
  final ExercisePresenter _exercisePresenter = ExercisePresenter();

  Future<void> _addExercise() async {
    final selected = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseListScreen(isSelecting: true),
      ),
    );

    // null if the user hit back without picking anything
    if (selected == null || !mounted) return;

    setState(() {
      _routinePresenter.addExerciseToRoutine(widget.routineId, selected.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final routine = _routinePresenter.getRoutineById(widget.routineId);

    if (routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Routine Details')),
        body: const Center(
          child: Text('Routine not found.'),
        ),
      );
    }

    final exercises = routine.exercises;

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete routine',
            onPressed: () async {
              if (await confirmDeleteRoutine(context, routine)) {
                _routinePresenter.deleteRoutine(routine.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        // One extra item at the end for the add button.
        itemCount: exercises.length + 1,
        itemBuilder: (context, index) {
          if (index == exercises.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add exercise'),
              ),
            );
          }

          final routineExercise = exercises[index];
          final exercise = _exercisePresenter.getExerciseById(routineExercise.exerciseId);
          final exerciseName = exercise?.name ?? 'Unknown exercise';
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(exerciseName),
          );

        },
      ),
    );
  }
}
