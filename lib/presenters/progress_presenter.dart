import '../models/progress_model.dart';
import 'workout_presenter.dart';

// Turns logged workouts into points for the progress graph

class ProgressPresenter {
  // is true when nothing is logged as placeholder data to be showed
  bool get usingSampleData => WorkoutPresenter.instance.workouts.isEmpty;

  List<ProgressPoint> pointsFor(ProgressRange range) {
    final now = DateTime.now();
    final all = usingSampleData ? _samplePoints(now) : _volumeByDay();

    final days = range.days;
    if (days == null) return all;

    final cutoff = now.subtract(Duration(days: days));
    return all.where((p) => p.date.isAfter(cutoff)).toList();
  }

  // Total volume for each calender day, oldest first
  List<ProgressPoint> _volumeByDay() {
    final byDay = <DateTime, double>{};
    for (final w in WorkoutPresenter.instance.workouts) {
      final day = DateTime(w.date.year, w.date.month, w.date.day);
      byDay[day] = (byDay[day] ?? 0) + w.totalVolume;
    }
    final points = byDay.entries
        .map((e) => ProgressPoint(date: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  // Upward trending data, makes graph visible before loged
  List<ProgressPoint> _samplePoints(DateTime now) {
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: (29 - i) * 3));
      final value = 2000 + i * 60 + ((i * 37) % 5) * 80;
      return ProgressPoint(date: date, value: value.toDouble());
    });
  }
}