import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'presenters/routine_presenter.dart';
import 'presenters/workout_presenter.dart';

//took like 10 years to format, rough draft of what i think it could look like, feel free to change/edit as needed

class HomeScreen extends StatelessWidget {

  final ValueChanged<int> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final workouts = WorkoutPresenter.instance;
    final routines = RoutinePresenter();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Get Fit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: appColor,
      ),
      body: ListenableBuilder(
        listenable: workouts,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Hello (name)! ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(
                    label: 'This week',
                    value: '${workouts.workoutsThisWeek}',
                  ),
                  _StatCard(
                    label: 'Total workouts',
                    value: '${workouts.workouts.length}',
                  ),
                  _StatCard(
                    label: 'Routines',
                    value: '${routines.getAllRoutines().length}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Log Workout'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.list_alt),
                label: const Text('Routines'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => onNavigate(3),
                icon: const Icon(Icons.show_chart),
                label: const Text('View Progress'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}