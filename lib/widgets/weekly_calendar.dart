import 'package:flutter/material.dart';
import '../presenters/workout_presenter.dart';
import '../presenters/routine_presenter.dart';
import '../utils/format.dart';

class WeeklyCalendar extends StatefulWidget {
  final WorkoutPresenter workouts;

  const WeeklyCalendar({
    super.key,
    required this.workouts,
  });

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  DateTime selectedDate = DateTime.now();

  final RoutinePresenter routines = RoutinePresenter();

  // Check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // Navigate to the previous or next week
  void changeWeek(int direction) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day + (7 * direction),
      );
    });
  }

  // Select a routine to schedule on the selected weekday
  Future<void> scheduleRoutine() async {
    final date = selectedDate;

    final availableRoutines = routines.getAllRoutines().where(
      (routine) => !routine.days.contains(date.weekday),
    ).toList();

    if (availableRoutines.isEmpty) {
      final message = routines.getAllRoutines().isEmpty
          ? 'Create a routine in the Routines tab first.'
          : 'All routines are already scheduled for this weekday.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final routineId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(
            'Schedule for ${weekdayShortNames[date.weekday - 1]}',
          ),
          children: [
            for (final routine in availableRoutines)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(dialogContext, routine.id);
                },
                child: Text(routine.name),
              ),
          ],
        );
      },
    );

    if (!mounted || routineId == null) return;

    final routine = routines.getRoutineById(routineId);
    if (routine == null) return;

    // Keep existing weekdays and add the selected one
    final updatedDays = {...routine.days};
    updatedDays.add(date.weekday);

    setState(() {
      routines.setRoutineDays(routineId, updatedDays);
    });
  }

  // Remove a routine from the selected weekday
  void removePlannedRoutine(String routineId) {
    final routine = routines.getRoutineById(routineId);

    if (routine == null) return;

    final updatedDays = {...routine.days};
    updatedDays.remove(selectedDate.weekday);

    setState(() {
      routines.setRoutineDays(routineId, updatedDays);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // Find Monday and Sunday of the selected week
    final monday = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - (selectedDate.weekday - 1),
    );

    final sunday = DateTime(
      monday.year,
      monday.month,
      monday.day + 6,
    );

    // Routines planned for selected weekday
    final plannedRoutines =
        routines.getRoutinesForDay(selectedDate.weekday);

    // Workouts completed on selected date
    final completedWorkouts = widget.workouts.workouts.where(
      (workout) => isSameDay(workout.date, selectedDate),
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar heading
        const Text(
          'Your Week',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Week navigation
        Row(
          children: [
            IconButton(
              onPressed: () => changeWeek(-1),
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous week',
            ),

            Expanded(
              child: Text(
                '${shortDate(monday)} - ${shortDate(sunday)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            IconButton(
              onPressed: () => changeWeek(1),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next week',
            ),

            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh schedule',
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Monday through Sunday
        Row(
          children: List.generate(7, (index) {
            final date = DateTime(
              monday.year,
              monday.month,
              monday.day + index,
            );

            final selected = isSameDay(date, selectedDate);
            final isToday = isSameDay(date, today);

            final hasPlan =
                routines.getRoutinesForDay(date.weekday).isNotEmpty;

            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context)
                            .colorScheme.primaryContainer
                        : null,
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context)
                                .colorScheme.primary,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekdayShortNames[index],
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (hasPlan)
                        const Icon(
                          Icons.circle,
                          size: 7,
                          color: Colors.green,
                        )
                      else
                        const SizedBox(height: 7),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Planned workouts
        Row(
          children: [
            Expanded(
              child: Text(
                'Planned Workouts - '
                '${shortDate(selectedDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (plannedRoutines.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.event_note),
              title: Text('No routines planned for this day.'),
            ),
          )
        else
          ...plannedRoutines.map((routine) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(routine.name),
                subtitle: Text(
                  '${routine.exercises.length} exercises',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove scheduled routine',
                  onPressed: () {
                    removePlannedRoutine(routine.id);
                  },
                ),
              ),
            );
          }),

        const SizedBox(height: 8),

        // Schedule a routine directly from Home
        OutlinedButton.icon(
          onPressed: scheduleRoutine,
          icon: const Icon(Icons.add),
          label: const Text('Schedule Routine'),
        ),

        const SizedBox(height: 24),

        // Entire weekly plan
        const Text(
          "This Week's Plan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: Column(
            children: List.generate(7, (index) {
              final date = DateTime(
                monday.year,
                monday.month,
                monday.day + index,
              );

              final plannedNames = routines
                  .getRoutinesForDay(date.weekday)
                  .map((routine) => routine.name)
                  .join(', ');

              return ListTile(
                dense: true,
                title: Text(
                  '${weekdayShortNames[index]} ${date.day}',
                ),
                subtitle: Text(
                  plannedNames.isEmpty
                      ? 'No routine planned'
                      : plannedNames,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        // Completed workouts - existing functionality
        Text(
          'Completed Workouts - ${shortDate(selectedDate)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (completedWorkouts.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('No workouts completed on this day.'),
            ),
          )
        else
          ...completedWorkouts.map((workout) {
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(workout.name),
                subtitle: Text(
                  workout.exercises.isEmpty
                      ? 'Workout logged'
                      : '${workout.exercises.length} exercises',
                ),
              ),
            );
          }),
      ],
    );
  }
}