import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class MonthlyLoadsLineChart extends StatefulWidget {
  final DateTime currentMonth;
  final bool isMobile;
  final bool isTablet;

  const MonthlyLoadsLineChart({
    super.key,
    required this.currentMonth,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  State<MonthlyLoadsLineChart> createState() => _MonthlyLoadsLineChartState();
}

class _MonthlyLoadsLineChartState extends State<MonthlyLoadsLineChart> {
  late DateTime currentMonth;
  Map<int, int> dailyLoads = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.currentMonth;
    _loadMonthlyLoads();
  }

  Future<void> _loadMonthlyLoads() async {
    setState(() => isLoading = true);

    final startDate = DateTime(currentMonth.year, currentMonth.month, 1);
    final endDate = DateTime(currentMonth.year, currentMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1));

    try {
      final doneSnap = await FirebaseService.jobsDoneFirestore
          .collection('Jobs_done')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final completedSnap = await FirebaseFirestore.instance
          .collection('Jobs_completed')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final allDocs = [...doneSnap.docs, ...completedSnap.docs];

      dailyLoads.clear();
      for (var doc in allDocs) {
        try {
          final jobModel = JobModel.fromFirestore(doc.data(), doc.id);
          final dateD = jobModel.dateD;
          if (dateD != null) {
            final jobDate = dateD is Timestamp
                ? (dateD as Timestamp).toDate()
                : (dateD as DateTime);

            final day = jobDate.day;
            final finalLoad = jobModel.finalLoad ?? 0;

            dailyLoads[day] = (dailyLoads[day] ?? 0) + finalLoad;
          }
        } catch (e) {
          debugPrint('Error processing job: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading monthly loads: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  void didUpdateWidget(MonthlyLoadsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      currentMonth = widget.currentMonth;
      _loadMonthlyLoads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    return Card(
      child: Padding(
        padding: widget.isMobile
            ? const EdgeInsets.all(12)
            : const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3️⃣ Daily Loads Line Chart',
              style: TextStyle(
                fontSize: widget.isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: TextStyle(
                fontSize: widget.isMobile ? 11 : 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildLineChart(daysInMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(int daysInMonth) {
    final maxLoads = dailyLoads.isEmpty
        ? 0
        : dailyLoads.values.reduce((a, b) => a > b ? a : b);
    final chartHeight =
        widget.isMobile ? 120.0 : (widget.isTablet ? 140.0 : 150.0);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final yAxisWidth = 35.0;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text('Sun',
                  style: TextStyle(fontSize: widget.isMobile ? 10 : 11)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text('Sat',
                  style: TextStyle(fontSize: widget.isMobile ? 10 : 11)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis labels - aligned with grid lines
            SizedBox(
              width: yAxisWidth,
              height: chartHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final value = maxLoads * (1 - index * 0.25);
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: widget.isMobile ? 8 : 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 4),
            // Chart
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: daysInMonth * (widget.isMobile ? 20.0 : 25.0),
                  height: chartHeight + (widget.isMobile ? 40 : 60),
                  child: CustomPaint(
                    painter: LineChartPainter(
                      dailyLoads: dailyLoads,
                      daysInMonth: daysInMonth,
                      maxLoads: maxLoads,
                      chartHeight: chartHeight,
                      firstDayOfWeek: firstDayOfWeek,
                      isMobile: widget.isMobile,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  final Map<int, int> dailyLoads;
  final int daysInMonth;
  final int maxLoads;
  final double chartHeight;
  final int firstDayOfWeek;
  final bool isMobile;

  LineChartPainter({
    required this.dailyLoads,
    required this.daysInMonth,
    required this.maxLoads,
    required this.chartHeight,
    required this.firstDayOfWeek,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final horizontalGridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    final weekendPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final saturdayPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final xSpacing = size.width / daysInMonth;
    final yScale = maxLoads > 0 ? chartHeight / maxLoads : 0;

    // Draw weekend backgrounds
    for (int i = 1; i <= daysInMonth; i++) {
      final dayOfWeek = (firstDayOfWeek + i - 1) % 7;
      final x = (i - 1) * xSpacing;

      if (dayOfWeek == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, xSpacing, chartHeight),
          weekendPaint,
        );
      } else if (dayOfWeek == 6) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, xSpacing, chartHeight),
          saturdayPaint,
        );
      }
    }

    // Draw horizontal grid lines (dashed)
    for (int i = 0; i <= 4; i++) {
      final y = (chartHeight / 4) * i;
      _drawDashedLine(
          canvas, Offset(0, y), Offset(size.width, y), horizontalGridPaint);
    }

    // Draw vertical grid lines
    for (int i = 0; i <= daysInMonth; i++) {
      final x = i * xSpacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, chartHeight),
        gridPaint,
      );
    }

    // Draw line and points
    for (int i = 1; i <= daysInMonth; i++) {
      final loads1 = dailyLoads[i - 1] ?? 0;
      final loads2 = dailyLoads[i] ?? 0;
      final x1 = (i - 1) * xSpacing;
      final y1 = chartHeight - (loads1 * yScale);
      final x2 = i * xSpacing;
      final y2 = chartHeight - (loads2 * yScale);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawCircle(Offset(x2, y2), isMobile ? 2 : 3, pointPaint);
    }

    // Draw axes
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      Paint()..strokeWidth = 1,
    );

    // Draw day labels and week markers at bottom
    int currentWeek = 1;
    for (int i = 1; i <= daysInMonth; i++) {
      final dayOfWeek = (firstDayOfWeek + i - 1) % 7;
      final x = (i - 1) * xSpacing + xSpacing / 2;

      // Draw day number
      final dayTextPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: (dayOfWeek == 0 || dayOfWeek == 6)
                ? Colors.red
                : Colors.grey.shade700,
            fontSize: isMobile ? 8 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      dayTextPainter.layout();
      dayTextPainter.paint(
        canvas,
        Offset(x - dayTextPainter.width / 2, chartHeight + 5),
      );

      // Draw week label on Sunday
      if (dayOfWeek == 0 && i > 1) {
        currentWeek++;
      }
      if (dayOfWeek == 0) {
        final weekTextPainter = TextPainter(
          text: TextSpan(
            text: 'W$currentWeek',
            style: TextStyle(
              color: Colors.blue,
              fontSize: isMobile ? 7 : 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        weekTextPainter.layout();
        weekTextPainter.paint(
          canvas,
          Offset(x - weekTextPainter.width / 2, chartHeight + 15),
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    double currentDistance = 0;
    while (currentDistance < distance) {
      final nextDistance = (currentDistance + dashWidth).clamp(0.0, distance);
      final p1 = start + direction * currentDistance;
      final p2 = start + direction * nextDistance;
      canvas.drawLine(p1, p2, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => false;
}
