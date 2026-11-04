import 'package:flutter/material.dart';
import '../presenters/routine_presenter.dart';
import 'confirm_delete_dialog.dart';

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

  void _addSampleWorkout() {
    setState(() {
      _routinePresenter.addWorkoutToRoutine(widget.routineId, 'Sample Workout');
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

    final workouts = routine.workoutNames;

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
        itemCount: workouts.length + 1,
        itemBuilder: (context, index) {
          if (index == workouts.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _addSampleWorkout,
                icon: const Icon(Icons.add),
                label: const Text('Add workout'),
              ),
            );
          }

          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(workouts[index]),
          );
        },
      ),
    );
  }
}
