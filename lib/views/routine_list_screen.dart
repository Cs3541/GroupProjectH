
import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../presenters/routine_presenter.dart';
import 'routine_screen.dart';

class RoutineListScreen extends StatelessWidget {
  RoutineListScreen({super.key});

  final RoutinePresenter _presenter = RoutinePresenter();

  @override
  Widget build(BuildContext context) {
    final List<Routine> routines = _presenter.getAllRoutines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Routines'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.fitness_center),
              ),
              title: Text(routine.name),
              subtitle: Text(
                '${routine.exerciseIds.length} exercises',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutineScreen(routineId: routine.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /*void _showRoutineDetails(
    BuildContext context,
    Routine routine,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(routine.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exercises',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...routine.exerciseIds.map(
                (id) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    id
                        .split('_')
                        .map(
                          (word) => word[0].toUpperCase() +
                              word.substring(1),
                        )
                        .join(' '),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }*/
}
