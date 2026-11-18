import 'package:flutter/material.dart';

import '../../../models/active_workout_model.dart';
import '../../../presenters/active_workout_presenter.dart';
import '../../../utils/workout_format.dart';

class ActiveSetRow extends StatefulWidget {
  final int index;
  final ActiveExercise exercise;
  final ActiveSet set;
  final ActiveWorkoutPresenter presenter;

  const ActiveSetRow({
    super.key,
    required this.index,
    required this.exercise,
    required this.set,
    required this.presenter,
  });

  @override
  State<ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<ActiveSetRow> {
  late final TextEditingController _weight =
      TextEditingController(text: formatDecimal(widget.set.weight));
  late final TextEditingController _reps =
      TextEditingController(text: widget.set.reps?.toString() ?? '');
  late final TextEditingController _rpe =
      TextEditingController(text: formatDecimal(widget.set.rpe));

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _rpe.dispose();
    super.dispose();
  }

  double? _parseDecimal(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  void _save() {
    widget.presenter.updateSet(
      widget.set,
      weight: _parseDecimal(_weight.text),
      reps: int.tryParse(_reps.text.trim()),
      rpe: _parseDecimal(_rpe.text),
    );
  }

  Widget _field(TextEditingController controller, {bool decimal = true}) {
    return Expanded(
      child: TextField(
        controller: controller,
        onChanged: (_) => _save(),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final set = widget.set;

    return Dismissible(
      key: ValueKey('set-${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => widget.presenter.removeSet(widget.exercise, set),
      child: Container(
        color: set.completed ? scheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text('${widget.index + 1}', textAlign: TextAlign.center),
            ),
            _field(_weight),
            const SizedBox(width: 8),
            _field(_reps, decimal: false),
            const SizedBox(width: 8),
            _field(_rpe),
            SizedBox(
              width: 48,
              child: IconButton(
                tooltip: set.completed ? 'Mark incomplete' : 'Mark complete',
                icon: Icon(
                  set.completed
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                onPressed: () => widget.presenter.toggleSetCompleted(set),
              ),
            ),
          ],
        ),
      ),
    );
  }
}