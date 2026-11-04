// formatting helpers
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String compactNumber(double v) =>
    v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.round().toString();