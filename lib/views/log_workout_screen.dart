import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../presenters/active_workout_presenter.dart';
import '../presenters/workout_presenter.dart';
import '../utils/format.dart';
import '../utils/workout_format.dart';
import 'start_workout_sheet.dart';

class LogWorkoutScreen extends StatelessWidget {
  const LogWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = WorkoutPresenter.instance;
    final active = ActiveWorkoutPresenter.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        backgroundColor: appColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: presenter.clear,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([presenter, active]),
        builder: (context, _) {
          final workouts = presenter.workouts.reversed.toList();

          return Column(
            children: [
              if (active.hasActiveWorkout)
                _InProgressBanner(presenter: active),
              Expanded(
                child: workouts.isEmpty
                    ? const Center(
                        child: Text(
                          'No workouts logged yet.\nTap "Start workout" to begin.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final w = workouts[index];
                          final duration = w.duration.inSeconds > 0
                              ? ' • ${formatDuration(w.duration)}'
                              : '';
                          return ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(w.name),
                            subtitle: Text(
                              '${shortDate(w.date)} • ${w.exercises.length} exercise(s) '
                              '• volume ${compactNumber(w.totalVolume)}$duration',
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: ListenableBuilder(
        listenable: active,
        builder: (context, _) {
          final inProgress = active.hasActiveWorkout;
          return FloatingActionButton.extended(
            onPressed: () => inProgress
                ? openActiveWorkout(context)
                : startWorkoutFlow(context),
            icon: Icon(inProgress ? Icons.play_arrow : Icons.add),
            label: Text(inProgress ? 'Continue workout' : 'Start workout'),
          );
        },
      ),
    );
  }
}

class _InProgressBanner extends StatelessWidget {
  final ActiveWorkoutPresenter presenter;
  const _InProgressBanner({required this.presenter});

  @override
  Widget build(BuildContext context) {
    final workout = presenter.active;
    if (workout == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: ListTile(
        leading: const Icon(Icons.timer),
        title: Text('${workout.name} in progress'),
        subtitle: ValueListenableBuilder<Duration>(
          valueListenable: presenter.elapsed,
          builder: (_, elapsed, __) => Text(
            '${formatDuration(elapsed)} • '
            '${workout.completedSets}/${workout.totalSets} sets done',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openActiveWorkout(context),
      ),
    );
  }
}