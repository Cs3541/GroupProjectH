
import 'package:flutter/material.dart';
import '../models/routine_model.dart';
import '../presenters/routine_presenter.dart';
import 'routine_screen.dart';

class RoutineListScreen extends StatefulWidget {
  const RoutineListScreen({super.key});

  @override
  State<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends State<RoutineListScreen> {
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
        itemCount: routines.length + 1,
        itemBuilder: (context, index) {
          if (index == routines.length) {
            return OutlinedButton.icon(
              onPressed: () => _showAddRoutineDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Routine'),
            );
          }

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
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutineScreen(routineId: routine.id)),
                );
                if (mounted) setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddRoutineDialog(BuildContext context) async {
    var input = '';

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Routine'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Routine name'),
            onChanged: (value) => input = value,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (name == null || name.trim().isEmpty) return;

    setState(() {
      _presenter.addRoutine(name);
    });
  }
}
