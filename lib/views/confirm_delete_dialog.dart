import 'package:flutter/material.dart';
import '../models/routine_model.dart';

Future<bool> confirmDeleteRoutine(BuildContext context, Routine routine) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
