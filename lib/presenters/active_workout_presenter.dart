import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/active_workout_model.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../models/workout_model.dart';
import 'exercise_presenter.dart';
import 'workout_presenter.dart';

class ActiveWorkoutPresenter extends ChangeNotifier {
  ActiveWorkoutPresenter._();
  static final ActiveWorkoutPresenter instance = ActiveWorkoutPresenter._();

  static const int defaultSetCount = 3;

  final ExercisePresenter _exercisePresenter = ExercisePresenter();

  ActiveWorkout? _active;
  ActiveWorkout? get active => _active;
  bool get hasActiveWorkout => _active != null;


  final ValueNotifier<Duration> elapsed = ValueNotifier(Duration.zero);

  final ValueNotifier<int> restRemaining = ValueNotifier(0);

  int restDurationSeconds = 90;
  bool autoStartRest = true;

  final StreamController<void> _restFinished = StreamController.broadcast();

  Stream<void> get onRestFinished => _restFinished.stream;

  Timer? _ticker;
  DateTime? _restEndsAt;
  int _restTotal = 0;

  int get restTotalSeconds => _restTotal > 0 ? _restTotal : restDurationSeconds;

  ActiveWorkout startEmptyWorkout({String? name}) {
    final existing = _active;
    if (existing != null) return existing;
    return _begin(ActiveWorkout(name: name ?? _defaultName()));
  }

  ActiveWorkout startFromRoutine(Routine routine) {
    final existing = _active;
    if (existing != null) return existing;

    final workout = ActiveWorkout(name: routine.name, routineId: routine.id);
    for (final re in routine.exercises) {
      final exercise = _exercisePresenter.getExerciseById(re.exerciseId);
      final count = math.max(1, re.goalSets ?? defaultSetCount);
      workout.exercises.add(ActiveExercise(
        exerciseId: re.exerciseId,
        name: exercise?.name ?? 'Unknown exercise',
        sets: List.generate(
          count,
          (_) => ActiveSet(
            weight: re.goalWeight?.toDouble(),
            reps: re.goalReps,
          ),
        ),
      ));
    }
    return _begin(workout);
  }

  Workout? finish() {
    final a = _active;
    if (a == null) return null;
    final workout =
        a.toWorkout(duration: DateTime.now().difference(a.startedAt));
    _reset();
    if (workout.exercises.isEmpty) return null;
    WorkoutPresenter.instance.addWorkout(workout);
    return workout;
  }

  void discard() => _reset();


  void addExercise(Exercise exercise) {
    final a = _active;
    if (a == null) return;
    a.exercises.add(ActiveExercise(
      exerciseId: exercise.id,
      name: exercise.name,
      sets: [ActiveSet()],
    ));
    notifyListeners();
  }

  void swapExercise(ActiveExercise target, Exercise replacement) {
    target.exerciseId = replacement.id;
    target.name = replacement.name;
    for (final s in target.sets) {
      s.completed = false;
    }
    notifyListeners();
  }

  void removeExercise(ActiveExercise target) {
    _active?.exercises.remove(target);
    notifyListeners();
  }

  void addSet(ActiveExercise exercise) {
    final last = exercise.sets.isEmpty ? null : exercise.sets.last;
    exercise.sets.add(ActiveSet(weight: last?.weight, reps: last?.reps));
    notifyListeners();
  }

  void removeSet(ActiveExercise exercise, ActiveSet set) {
    exercise.sets.remove(set);
    notifyListeners();
  }

  void updateSet(ActiveSet set, {double? weight, int? reps, double? rpe}) {
    set.weight = weight;
    set.reps = reps;
    set.rpe = rpe?.clamp(1, 10).toDouble();
  }

  void toggleSetCompleted(ActiveSet set) {
    set.completed = !set.completed;
    if (set.completed && autoStartRest) startRest();
    notifyListeners();
  }


  void setRestDuration(int seconds) {
    restDurationSeconds = seconds.clamp(5, 3600).toInt();
    notifyListeners();
  }

  void startRest([int? seconds]) {
    if (_active == null) return;
    final secs = seconds ?? restDurationSeconds;
    _restTotal = secs;
    _restEndsAt = DateTime.now().add(Duration(seconds: secs));
    restRemaining.value = secs;
  }

  void addRest(int deltaSeconds) {
    final end = _restEndsAt;
    if (end == null) return;
    _restEndsAt = end.add(Duration(seconds: deltaSeconds));
    _restTotal = math.max(1, _restTotal + deltaSeconds);
    _tick();
  }

  void skipRest() {
    _restEndsAt = null;
    restRemaining.value = 0;
  }


  ActiveWorkout _begin(ActiveWorkout workout) {
    _active = workout;
    _tick();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
    return workout;
  }

  void _tick() {
    final a = _active;
    if (a == null) return;
    elapsed.value = DateTime.now().difference(a.startedAt);

    final end = _restEndsAt;
    if (end != null) {
      final ms = end.difference(DateTime.now()).inMilliseconds;
      if (ms <= 0) {
        _restEndsAt = null;
        restRemaining.value = 0;
        _restFinished.add(null);
      } else {
        restRemaining.value = (ms / 1000).ceil();
      }
    }
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;
    _restEndsAt = null;
    _restTotal = 0;
    _active = null;
    elapsed.value = Duration.zero;
    restRemaining.value = 0;
    notifyListeners();
  }

  String _defaultName() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning workout';
    if (h < 18) return 'Afternoon workout';
    return 'Evening workout';
  }
}