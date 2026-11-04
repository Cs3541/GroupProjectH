import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/routine_model.dart';
import '../presenters/routine_presenter.dart';

// SKELETON for routines branch, lets you add a routine and swipe to delete, didnt add too much more you can implement your stuff here.

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  void _showAddRoutineDialog(BuildContext context) {
    String name = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Routine'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Routine name',
            ),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.trim().isNotEmpty) {
                  RoutinePresenter.instance
                      .addRoutine(Routine(name: name.trim()));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final presenter = RoutinePresenter.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        backgroundColor: appColor,
      ),
      body: ListenableBuilder(
        listenable: presenter,
        builder: (context, _) {
          final routines = presenter.routines;

          if (routines.isEmpty) {
            return const Center(
              child: Text(
                'No routines yet,\nTap + to create one',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return Dismissible(
                key: ObjectKey(routine),
                onDismissed: (_) => presenter.removeRoutine(index),
                background: Container(color: Colors.redAccent),
                child: ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(routine.name),
                  subtitle: Text('${routine.exercises.length} exercise(s)'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoutineDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}