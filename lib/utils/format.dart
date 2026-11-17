// formatting helpers
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String compactNumber(double v) =>
    v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.round().toString();
/// Short day labels indexed by DateTime.weekday - 1 (Monday first).
const weekdayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Formats a set of weekdays like "Mon · Thu", in week order.
String formatWeekdays(Set<int> days) {
  final sorted = days.toList()..sort();
  return sorted.map((d) => weekdayShortNames[d - 1]).join(' · ');
}
