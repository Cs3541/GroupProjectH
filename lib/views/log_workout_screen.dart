import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/workout_model.dart';
import '../presenters/workout_presenter.dart';
import '../utils/format.dart';

// SKELETON for the workout logging branch.
//
// Lists logged workouts and has a placeholder button that adds a fake workout that tests the home and progress tabs.
// to do for dewa: replace the FAB with a real form (pick exercise, add
// sets/reps/weight, choose a date, optionally start from a routine)
class LogWorkoutScreen extends StatelessWidget {
  const LogWorkoutScreen({super.key});

  void _addSampleWorkout() {
    final presenter = WorkoutPresenter.instance;
    final n = presenter.workouts.length;
    final weight = 60 + n * 2.5;

    // Spread test workouts over time until they land on today. This should be temporary
    final daysAgo = (10 - n).clamp(0, 10) * 2;

    presenter.addWorkout(
      Workout(
        name: 'Sample workout',
        date: DateTime.now().subtract(Duration(days: daysAgo)),
        exercises: [
          ExerciseEntry(
            name: 'Bench Press',
            sets: [
              WorkoutSet(reps: 8, weight: weight),
              WorkoutSet(reps: 8, weight: weight),
              WorkoutSet(reps: 6, weight: weight + 2.5),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presenter = WorkoutPresenter.instance;

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
        listenable: presenter,
        builder: (context, _) {
          final workouts = presenter.workouts.reversed.toList();

          if (workouts.isEmpty) {
            return const Center(
              child: Text(
                'No workouts logged yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final w = workouts[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(w.name),
                subtitle: Text(
                  '${shortDate(w.date)} • ${w.exercises.length} exercise(s) '
                  '• volume ${compactNumber(w.totalVolume)}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleWorkout, // TO DO: have sample workout open the real log form
        child: const Icon(Icons.add),
      ),
    );
  }
}