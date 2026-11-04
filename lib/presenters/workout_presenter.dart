import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutPresenter extends ChangeNotifier {
  WorkoutPresenter._();
  static final WorkoutPresenter instance = WorkoutPresenter._();

  final List<Workout> _workouts = [];

  List<Workout> get workouts => List.unmodifiable(_workouts);

  int get workoutsThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _workouts.where((w) => w.date.isAfter(cutoff)).length;
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  void clear() {
    _workouts.clear();
    notifyListeners();
  }
}