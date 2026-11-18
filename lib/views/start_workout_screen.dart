import 'package:flutter/material.dart';

import '../models/routine_model.dart';
import '../presenters/active_workout_presenter.dart';
import '../presenters/routine_presenter.dart';
import 'active_workout_screen.dart';

class _StartChoice {
  final Routine? routine;
  const _StartChoice(this.routine);
}

Future<void> startWorkoutFlow(BuildContext context) async {
  final choice = await showModalBottomSheet<_StartChoice>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _StartWorkoutSheet(),
  );
  if (choice == null || !context.mounted) return;

  final presenter = ActiveWorkoutPresenter.instance;
  final routine = choice.routine;
  if (routine == null) {
    presenter.startEmptyWorkout();
  } else {
    presenter.startFromRoutine(routine);
  }
  await openActiveWorkout(context);
}

Future<void> openActiveWorkout(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
  );
}

class _StartWorkoutSheet extends StatelessWidget {
  const _StartWorkoutSheet();

  @override
  Widget build(BuildContext context) {
    final routines = RoutinePresenter().getAllRoutines();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Start workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.add)),
              title: const Text('Empty workout'),
              subtitle: const Text('Start fresh and add exercises as you go'),
              onTap: () => Navigator.pop(context, const _StartChoice(null)),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'From a routine',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (routines.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No routines yet. Create one in the Routines tab.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.fitness_center),
                      ),
                      title: Text(routine.name),
                      subtitle: Text('${routine.exercises.length} exercises'),
                      onTap: () =>
                          Navigator.pop(context, _StartChoice(routine)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}