import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/active_workout_model.dart';
import '../models/exercise_model.dart';
import '../presenters/active_workout_presenter.dart';
import '../utils/workout_format.dart';
import 'exercise_list_screen.dart';
import 'widgets/active_set_row.dart';
import 'widgets/rest_timer_bar.dart';

enum _ExerciseAction { swap, remove }

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final ActiveWorkoutPresenter _presenter = ActiveWorkoutPresenter.instance;
  StreamSubscription<void>? _restSub;

  @override
  void initState() {
    super.initState();
    _restSub = _presenter.onRestFinished.listen((_) => _onRestFinished());
  }

  @override
  void dispose() {
    _restSub?.cancel();
    super.dispose();
  }

  void _onRestFinished() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Rest is over - time for your next set!')),
      );
  }

  Future<Exercise?> _pickExercise() {
    return Navigator.push<Exercise>(
      context,
      MaterialPageRoute(builder: (_) => ExerciseListScreen(isSelecting: true)),
    );
  }

  Future<void> _addExercise() async {
    final picked = await _pickExercise();
    if (picked == null || !mounted) return;
    _presenter.addExercise(picked);
  }

  Future<void> _swapExercise(ActiveExercise exercise) async {
    final picked = await _pickExercise();
    if (picked == null || !mounted) return;
    _presenter.swapExercise(exercise, picked);
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _finish() async {
    final workout = _presenter.active;
    if (workout == null) return;

    final done = workout.completedSets;
    final unfinished = workout.totalSets - done;

    final ok = done == 0
        ? await _confirm(
            'Nothing to log',
            "No sets are marked complete, so this workout won't be saved.",
            'Discard',
          )
        : await _confirm(
            'Finish workout?',
            unfinished > 0
                ? '$unfinished unfinished set(s) will not be logged.'
                : 'Save this workout to your log?',
            'Finish',
          );
    if (!ok || !mounted) return;

    _presenter.finish();
    Navigator.pop(context);
  }

  Future<void> _discard() async {
    final ok = await _confirm(
      'Discard workout?',
      'Everything you entered in this workout will be lost.',
      'Discard',
    );
    if (!ok || !mounted) return;
    _presenter.discard();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _presenter,
      builder: (context, _) {
        final workout = _presenter.active;
        if (workout == null) return const Scaffold(body: SizedBox.shrink());

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.name, style: Theme.of(context).textTheme.titleMedium),
                ValueListenableBuilder<Duration>(
                  valueListenable: _presenter.elapsed,
                  builder: (_, elapsed, __) => Text(
                    formatDuration(elapsed),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: _finish, child: const Text('Finish')),
              PopupMenuButton<String>(
                onSelected: (_) => _discard(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'discard', child: Text('Discard workout')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              RestTimerBar(presenter: _presenter),
              Expanded(child: _buildExerciseList(workout)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseList(ActiveWorkout workout) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (workout.exercises.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No exercises yet.\nTap "Add exercise" to get started.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        for (final exercise in workout.exercises) _buildExerciseCard(exercise),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
          child: OutlinedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add exercise'),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(ActiveExercise exercise) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    Widget label(String text) =>
        Expanded(child: Text(text, textAlign: TextAlign.center, style: labelStyle));

    return Card(
      key: ValueKey('exercise-${exercise.id}'),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  PopupMenuButton<_ExerciseAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _ExerciseAction.swap:
                          _swapExercise(exercise);
                        case _ExerciseAction.remove:
                          _presenter.removeExercise(exercise);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _ExerciseAction.swap,
                        child: Text('Swap exercise'),
                      ),
                      PopupMenuItem(
                        value: _ExerciseAction.remove,
                        child: Text('Remove exercise'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Column headers - keep widths in sync with ActiveSetRow.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('SET', textAlign: TextAlign.center, style: labelStyle),
                  ),
                  label('WEIGHT'),
                  const SizedBox(width: 8),
                  label('REPS'),
                  const SizedBox(width: 8),
                  label('RPE'),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < exercise.sets.length; i++)
              ActiveSetRow(
                key: ValueKey('set-row-${exercise.sets[i].id}'),
                index: i,
                exercise: exercise,
                set: exercise.sets[i],
                presenter: _presenter,
              ),
            TextButton.icon(
              onPressed: () => _presenter.addSet(exercise),
              icon: const Icon(Icons.add),
              label: const Text('Add set'),
            ),
          ],
        ),
      ),
    );
  }
}