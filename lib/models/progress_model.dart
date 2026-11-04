//Point on progress graph
class ProgressPoint {
  final DateTime date;
  final double value;

  const ProgressPoint({required this.date, required this.value});
}

// Time window
enum ProgressRange {
  week('1W', 7),
  month('1M', 30),
  threeMonths('3M', 90),
  all('All', null);

  final String label;

  /// Number of days u can look back
  final int? days;

  const ProgressRange(this.label, this.days);
}