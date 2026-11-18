import 'package:flutter/material.dart';

import '../../../presenters/active_workout_presenter.dart';
import '../../../utils/workout_format.dart';

class RestTimerBar extends StatelessWidget {
  final ActiveWorkoutPresenter presenter;

  const RestTimerBar({super.key, required this.presenter});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: presenter,
      builder: (context, _) {
        return ValueListenableBuilder<int>(
          valueListenable: presenter.restRemaining,
          builder: (context, remaining, _) {
            final running = remaining > 0;
            return Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            running
                                ? 'Rest ${formatSeconds(remaining)}'
                                : 'Rest timer ${formatSeconds(presenter.restDurationSeconds)}',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (running) ...[
                          TextButton(
                            onPressed: () => presenter.addRest(-15),
                            child: const Text('-15s'),
                          ),
                          TextButton(
                            onPressed: () => presenter.addRest(15),
                            child: const Text('+15s'),
                          ),
                          TextButton(
                            onPressed: presenter.skipRest,
                            child: const Text('Skip'),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: presenter.startRest,
                            child: const Text('Start'),
                          ),
                          IconButton(
                            tooltip: 'Set rest length',
                            icon: const Icon(Icons.tune),
                            onPressed: () => _editDuration(context),
                          ),
                        ],
                      ],
                    ),
                    if (running)
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: LinearProgressIndicator(
                          value: (remaining / presenter.restTotalSeconds)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editDuration(BuildContext context) async {
    final seconds = await showDialog<int>(
      context: context,
      builder: (_) => _RestDurationDialog(initial: presenter.restDurationSeconds),
    );
    if (seconds != null) presenter.setRestDuration(seconds);
  }
}

class _RestDurationDialog extends StatefulWidget {
  final int initial;
  const _RestDurationDialog({required this.initial});

  @override
  State<_RestDurationDialog> createState() => _RestDurationDialogState();
}

class _RestDurationDialogState extends State<_RestDurationDialog> {
  static const _presets = [30, 45, 60, 90, 120, 180, 240, 300];

  late int _seconds = widget.initial;
  late final TextEditingController _custom =
      TextEditingController(text: widget.initial.toString());

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest length'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _presets)
                ChoiceChip(
                  label: Text(formatSeconds(p)),
                  selected: _seconds == p,
                  onSelected: (_) => setState(() {
                    _seconds = p;
                    _custom.text = p.toString();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _custom,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Custom (seconds)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() {
              _seconds = int.tryParse(v.trim()) ?? _seconds;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _seconds),
          child: const Text('Save'),
        ),
      ],
    );
  }
}