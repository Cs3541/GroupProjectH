import '../presenters/photo_presenter.dart';
import 'photo_upload_screen.dart';
import 'photo_gallery_screen.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/progress_model.dart';
import '../presenters/progress_presenter.dart';
import '../presenters/workout_presenter.dart';
import '../utils/format.dart';


// Main Progress Screen
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressPresenter _presenter = ProgressPresenter();

  final PhotoPresenter _photoPresenter = PhotoPresenter();

  ProgressRange _range = ProgressRange.threeMonths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: appColor,
      ),
 
      body: ListenableBuilder(
        listenable: WorkoutPresenter.instance,

        builder: (context, _) {
          final points = _presenter.pointsFor(_range);

          return ListView(
            padding: const EdgeInsets.all(16),

            children: [

              // Progress range selector
              SegmentedButton<ProgressRange>(
                segments: [
                  for (final r in ProgressRange.values)
                    ButtonSegment(
                      value: r,
                      label: Text(r.label),
                    ),
                ],

                selected: {_range},

                onSelectionChanged: (s) {
                  setState(() {
                    _range = s.first;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Total volume chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Total volume',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (_presenter.usingSampleData)
                        const Text(
                          'Sample data, log a workout to see yours!!!!!',
                          style: TextStyle(fontSize: 12),
                        ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 260,

                        child: points.isEmpty
                            ? const Center(
                                child: Text(
                                  'No data in this range',
                                ),
                              )
                            : _LineChart(
                                points: points,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress summary
              if (points.length >= 2)
                _SummaryRow(points: points),

              const SizedBox(height: 16),

              // Progress photos
              _PhotosCard(
                presenter: _photoPresenter,
              ),

              const SizedBox(height: 16),

              // Personal records
              const Card(
                child: ListTile(
                  leading: Icon(Icons.emoji_events),
                  title: Text('Personal records'),
                  subtitle: Text('Coming soon'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Progress Summary
class _SummaryRow extends StatelessWidget {
  final List<ProgressPoint> points;

  const _SummaryRow({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final first = points.first.value;
    final last = points.last.value;

    final change = first == 0
        ? 0.0
        : (last - first) / first * 100;

    final sign = change >= 0 ? '+' : '';

    return Row(
      children: [
        _MiniStat(
          label: 'Latest',
          value: compactNumber(last),
        ),

        _MiniStat(
          label: 'Change',
          value: '$sign${change.toStringAsFixed(0)}%',
        ),

        _MiniStat(
          label: 'Sessions',
          value: '${points.length}',
        ),
      ],
    );
  }
}

// Individual Summary Statistic
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),

          child: Column(
            children: [

              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Progress Line Chart
class _LineChart extends StatelessWidget {
  final List<ProgressPoint> points;

  const _LineChart({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,

      painter: _LineChartPainter(
        points: points,
        lineColor: Theme.of(context).colorScheme.primary,
        gridColor: Colors.black12,
        textColor: Colors.black87,
      ),
    );
  }
}

// Line Chart Painter
class _LineChartPainter extends CustomPainter {
  final List<ProgressPoint> points;

  final Color lineColor;
  final Color gridColor;
  final Color textColor;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
  });

  static const double _left = 44;
  static const double _right = 8;
  static const double _top = 8;
  static const double _bottom = 24;

  // Draw chart text
  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    bool rightAlign = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = offset.dx;

    if (rightAlign) dx -= tp.width;
    if (center) dx -= tp.width / 2;

    tp.paint(
      canvas,
      Offset(
        dx,
        offset.dy - tp.height / 2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(
      _left,
      _top,
      size.width - _right,
      size.height - _bottom,
    );

    // Calculate Y range
    var minY = points
        .map((p) => p.value)
        .reduce((a, b) => a < b ? a : b);

    var maxY = points
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final pad = (maxY - minY) * 0.1;

    minY -= pad;
    maxY += pad;

    final minX = points.first.date
        .millisecondsSinceEpoch.toDouble();

    final maxX = points.last.date
        .millisecondsSinceEpoch.toDouble();

    final xSpan = (maxX - minX) == 0
        ? 1.0
        : (maxX - minX);

    // Convert data points into chart coordinates
    Offset toOffset(ProgressPoint p) {
      final x = points.length == 1
          ? chart.center.dx
          : chart.left +
              (p.date.millisecondsSinceEpoch - minX) /
                  xSpan *
                  chart.width;

      final y = chart.bottom -
          (p.value - minY) /
              (maxY - minY) *
              chart.height;

      return Offset(x, y);
    }

    // Horizontal grid lines and Y labels
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;

      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        gridPaint,
      );

      final value = maxY - (maxY - minY) * i / 3;

      _drawText(
        canvas,
        compactNumber(value),
        Offset(chart.left - 6, y),
        rightAlign: true,
      );
    }

    // Draw line connecting points
    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final o = toOffset(points[i]);

      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw data point circles
    final dotPaint = Paint()
      ..color = lineColor;

    for (final p in points) {
      canvas.drawCircle(
        toOffset(p),
        3,
        dotPaint,
      );
    }

    // X-axis date labels
    if (points.length == 1) {
      _drawText(
        canvas,
        shortDate(points.first.date),
        Offset(chart.center.dx, size.height - 8),
        center: true,
      );
    } else {
      _drawText(
        canvas,
        shortDate(points.first.date),
        Offset(chart.left, size.height - 8),
      );

      _drawText(
        canvas,
        shortDate(points.last.date),
        Offset(chart.right, size.height - 8),
        rightAlign: true,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _LineChartPainter oldDelegate,
  ) {
    return oldDelegate.points != points;
  }
}

// Progress Photo Card
class _PhotosCard extends StatefulWidget {
  final PhotoPresenter presenter;

  const _PhotosCard({
    required this.presenter,
  });

  @override
  State<_PhotosCard> createState() => _PhotosCardState();
}

class _PhotosCardState extends State<_PhotosCard> {

  // Open photo upload screen
  Future<void> openUploadScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoUploadScreen(
          presenter: widget.presenter,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // Open photo gallery
  void openGalleryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoGalleryScreen(
          presenter: widget.presenter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.presenter.getAllPhotos().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Progress photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              count == 0
                  ? 'Add a photo to start tracking your progress'
                  : '$count photo${count == 1 ? '' : 's'} saved',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                // Add photo button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: openUploadScreen,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add photo'),
                  ),
                ),

                const SizedBox(width: 12),

                // Gallery button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: count == 0
                        ? null
                        : openGalleryScreen,

                    icon: const Icon(Icons.photo_library),

                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}