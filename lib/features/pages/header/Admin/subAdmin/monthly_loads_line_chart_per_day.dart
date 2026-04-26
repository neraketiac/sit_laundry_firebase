import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class MonthlyLoadsLineChartPerDay extends StatefulWidget {
  final DateTime currentMonth;
  final bool isMobile;
  final bool isTablet;

  const MonthlyLoadsLineChartPerDay({
    super.key,
    required this.currentMonth,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  State<MonthlyLoadsLineChartPerDay> createState() =>
      _MonthlyLoadsLineChartPerDayState();
}

class _MonthlyLoadsLineChartPerDayState
    extends State<MonthlyLoadsLineChartPerDay> {
  late DateTime currentMonth;
  Map<int, int> dailyLoads = {}; // day -> total loads
  bool isLoading = true;

  // Day of week: 0=Sunday, 1=Monday, ..., 6=Saturday
  static const List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  static const Map<int, Color> dayColors = {
    0: Colors.green,
    1: Colors.blue,
    2: Colors.orange,
    3: Colors.purple,
    4: Colors.amber,
    5: Colors.pink,
    6: Colors.black,
  };

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
  void didUpdateWidget(MonthlyLoadsLineChartPerDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      currentMonth = widget.currentMonth;
      _loadMonthlyLoads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: widget.isMobile
            ? const EdgeInsets.all(12)
            : const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4️⃣ Daily Loads by Day of Week',
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
              _buildLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final chartHeight =
        widget.isMobile ? 120.0 : (widget.isTablet ? 140.0 : 150.0);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    // Calculate max loads for scaling
    final maxLoads = dailyLoads.isEmpty
        ? 0
        : dailyLoads.values.reduce((a, b) => a > b ? a : b);

    final yAxisWidth = 35.0;

    return Column(
      children: [
        // Legend
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dayColors[index],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: widget.isMobile ? 9 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Y-axis labels
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
                  width: 7 * (widget.isMobile ? 60.0 : 80.0),
                  height: chartHeight + (widget.isMobile ? 40 : 60),
                  child: CustomPaint(
                    painter: LineChartPerDayPainter(
                      dailyLoads: dailyLoads,
                      maxLoads: maxLoads,
                      chartHeight: chartHeight,
                      firstDayOfWeek: firstDayOfWeek,
                      daysInMonth: daysInMonth,
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

class LineChartPerDayPainter extends CustomPainter {
  final Map<int, int> dailyLoads;
  final int maxLoads;
  final double chartHeight;
  final int firstDayOfWeek;
  final int daysInMonth;
  final bool isMobile;

  static const List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  static const Map<int, Color> dayColors = {
    0: Colors.green,
    1: Colors.blue,
    2: Colors.orange,
    3: Colors.purple,
    4: Colors.amber,
    5: Colors.pink,
    6: Colors.black,
  };

  LineChartPerDayPainter({
    required this.dailyLoads,
    required this.maxLoads,
    required this.chartHeight,
    required this.firstDayOfWeek,
    required this.daysInMonth,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final horizontalGridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    final yScale = maxLoads > 0 ? chartHeight / maxLoads : 0;
    final dayWidth = size.width / 7;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (chartHeight / 4) * i;
      _drawDashedLine(
          canvas, Offset(0, y), Offset(size.width, y), horizontalGridPaint);
    }

    // Draw vertical grid lines (day separators)
    for (int i = 0; i <= 7; i++) {
      final x = i * dayWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, chartHeight),
        gridPaint,
      );
    }

    // Draw lines and points for each day of week
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      final dayColor = dayColors[dayOfWeek]!;
      final linePaint = Paint()
        ..color = dayColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final pointPaint = Paint()
        ..color = dayColor
        ..style = PaintingStyle.fill;

      // Collect all occurrences of this day of week in the month
      final occurrences = <int>[]; // day numbers (1-31)

      for (int day = 1; day <= daysInMonth; day++) {
        final currentDayOfWeek = (firstDayOfWeek + day - 1) % 7;
        if (currentDayOfWeek == dayOfWeek) {
          occurrences.add(day);
        }
      }

      // Draw line connecting all occurrences of this day
      if (occurrences.isNotEmpty) {
        for (int i = 0; i < occurrences.length; i++) {
          final day = occurrences[i];
          final loads = dailyLoads[day] ?? 0;

          // X position: spread occurrences across the day column
          final xOffset = (i + 1) * (dayWidth / (occurrences.length + 1));
          final x = dayOfWeek * dayWidth + xOffset;
          final y = chartHeight - (loads * yScale);

          // Draw point
          canvas.drawCircle(Offset(x, y), isMobile ? 2 : 3, pointPaint);

          // Draw line to next occurrence
          if (i < occurrences.length - 1) {
            final nextDay = occurrences[i + 1];
            final nextLoads = dailyLoads[nextDay] ?? 0;
            final nextXOffset = (i + 2) * (dayWidth / (occurrences.length + 1));
            final nextX = dayOfWeek * dayWidth + nextXOffset;
            final nextY = chartHeight - (nextLoads * yScale);

            canvas.drawLine(Offset(x, y), Offset(nextX, nextY), linePaint);
          }
        }
      }
    }

    // Draw X-axis
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      Paint()..strokeWidth = 1,
    );

    // Draw day labels and occurrence numbers at bottom
    for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
      // Collect occurrences for this day
      final occurrences = <int>[];
      for (int day = 1; day <= daysInMonth; day++) {
        final currentDayOfWeek = (firstDayOfWeek + day - 1) % 7;
        if (currentDayOfWeek == dayOfWeek) {
          occurrences.add(day);
        }
      }

      // Draw day name
      final dayTextPainter = TextPainter(
        text: TextSpan(
          text: dayNames[dayOfWeek],
          style: TextStyle(
            color: dayColors[dayOfWeek],
            fontSize: isMobile ? 8 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      dayTextPainter.layout();
      final baseX = dayOfWeek * dayWidth + dayWidth / 2;
      dayTextPainter.paint(
        canvas,
        Offset(baseX - dayTextPainter.width / 2, chartHeight + 5),
      );

      // Draw occurrence numbers (1st, 2nd, 3rd, 4th, 5th)
      for (int i = 0; i < occurrences.length; i++) {
        final occurrenceNum = i + 1;
        final occurrenceTextPainter = TextPainter(
          text: TextSpan(
            text: '${occurrenceNum}st',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isMobile ? 7 : 8,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        occurrenceTextPainter.layout();

        final xOffset = (i + 1) * (dayWidth / (occurrences.length + 1));
        final x = dayOfWeek * dayWidth + xOffset;

        occurrenceTextPainter.paint(
          canvas,
          Offset(x - occurrenceTextPainter.width / 2, chartHeight + 15),
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
  bool shouldRepaint(LineChartPerDayPainter oldDelegate) => false;
}
