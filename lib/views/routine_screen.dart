import 'package:flutter/material.dart';
import '../presenters/routine_presenter.dart';
import '../presenters/exercise_presenter.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../utils/format.dart';
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

  Widget _buildDayPicker(Routine routine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Days', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(7, (i) {
              final weekday = i + 1; // DateTime.monday == 1
              return FilterChip(
                label: Text(weekdayShortNames[i]),
                selected: routine.days.contains(weekday),
                onSelected: (selected) {
                  final updated = {...routine.days};
                  selected ? updated.add(weekday) : updated.remove(weekday);
                  setState(() {
                    _routinePresenter.setRoutineDays(routine.id, updated);
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
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
        // One extra item at the start for the day picker and one at the end for the add button.
        itemCount: exercises.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return _buildDayPicker(routine);
          index -= 1;

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
