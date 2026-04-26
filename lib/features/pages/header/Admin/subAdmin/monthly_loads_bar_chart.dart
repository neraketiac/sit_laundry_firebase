import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class MonthlyLoadsBarChart extends StatefulWidget {
  final DateTime currentMonth;
  final bool isMobile;
  final bool isTablet;

  const MonthlyLoadsBarChart({
    super.key,
    required this.currentMonth,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  State<MonthlyLoadsBarChart> createState() => _MonthlyLoadsBarChartState();
}

class _MonthlyLoadsBarChartState extends State<MonthlyLoadsBarChart> {
  late DateTime currentMonth;
  Map<int, int> weeklyLoads = {};
  Map<int, int> dailyLoads = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.currentMonth;
    _loadWeeklyLoads();
  }

  Future<void> _loadWeeklyLoads() async {
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

      weeklyLoads.clear();
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

            final week = _getWeekNumber(jobDate);
            weeklyLoads[week] = (weeklyLoads[week] ?? 0) + finalLoad;
          }
        } catch (e) {
          debugPrint('Error processing job: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading weekly loads: $e');
    }

    setState(() => isLoading = false);
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final day = date.day;

    // Calculate which week this day falls into based on calendar weeks (Sun-Sat)
    int week = 1;
    int dayCounter = 1;

    // First week: from day 1 to the last day of the first week
    int firstWeekEnd = 7 - firstDayOfWeek;
    if (day <= firstWeekEnd) return 1;

    // Subsequent weeks
    dayCounter = firstWeekEnd + 1;
    week = 2;
    while (dayCounter <= day) {
      dayCounter += 7;
      if (dayCounter > day) break;
      week++;
    }

    return week;
  }

  @override
  void didUpdateWidget(MonthlyLoadsBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      currentMonth = widget.currentMonth;
      _loadWeeklyLoads();
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
              '2️⃣ Weekly Loads Bar Chart',
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
              _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxLoads = weeklyLoads.isEmpty
        ? 0
        : weeklyLoads.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      child: Column(
        children: List.generate(5, (index) {
          final week = index + 1;
          final totalLoads = weeklyLoads[week] ?? 0;

          final weekdayLoads = _getWeekdayLoads(week);
          final weekendLoads = _getWeekendLoads(week);

          final weekdayCount = _getWeekdayCount(week);
          final weekendCount = _getWeekendCount(week);

          final avgWeekday =
              weekdayCount > 0 ? weekdayLoads / weekdayCount : 0.0;
          final avgWeekend =
              weekendCount > 0 ? weekendLoads / weekendCount : 0.0;

          final barWidth = maxLoads > 0 ? (totalLoads / maxLoads) * 150 : 0.0;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.isMobile ? 8 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: widget.isMobile ? 60 : 70,
                      child: Text(
                        'Week $week',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isMobile ? 12 : 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: widget.isMobile ? 24 : 28,
                            width: barWidth,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalLoads',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: widget.isMobile ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.isMobile ? 60 : 70,
                  ),
                  child: widget.isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: maxLoads > 0
                                      ? (weekdayLoads / maxLoads) * 100
                                      : 0.0,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$weekdayLoads',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: maxLoads > 0
                                      ? (weekendLoads / maxLoads) * 100
                                      : 0.0,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$weekendLoads',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Avg WD: ${avgWeekday.toStringAsFixed(1)} | WE: ${avgWeekend.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: maxLoads > 0
                                        ? (weekdayLoads / maxLoads) * 120
                                        : 0.0,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$weekdayLoads',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: maxLoads > 0
                                        ? (weekendLoads / maxLoads) * 120
                                        : 0.0,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade400,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$weekendLoads',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                if (!widget.isMobile)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Avg Weekdays: ${avgWeekday.toStringAsFixed(1)} ($weekdayCount days)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Avg Weekends: ${avgWeekend.toStringAsFixed(1)} ($weekendCount days)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  int _getWeekdayLoads(int week) {
    int total = 0;
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    int startDay, endDay;
    if (week == 1) {
      startDay = 1;
      endDay = 7 - firstDayOfWeek;
    } else {
      startDay = (7 - firstDayOfWeek) + (week - 2) * 7 + 1;
      endDay = startDay + 6;
    }

    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    endDay = endDay.clamp(startDay, daysInMonth);

    for (int day = startDay; day <= endDay; day++) {
      final dayOfWeek = (firstDayOfWeek + day - 1) % 7;
      if (dayOfWeek >= 1 && dayOfWeek <= 5) {
        total += dailyLoads[day] ?? 0;
      }
    }

    return total;
  }

  int _getWeekendLoads(int week) {
    int total = 0;
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    int startDay, endDay;
    if (week == 1) {
      startDay = 1;
      endDay = 7 - firstDayOfWeek;
    } else {
      startDay = (7 - firstDayOfWeek) + (week - 2) * 7 + 1;
      endDay = startDay + 6;
    }

    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    endDay = endDay.clamp(startDay, daysInMonth);

    for (int day = startDay; day <= endDay; day++) {
      final dayOfWeek = (firstDayOfWeek + day - 1) % 7;
      if (dayOfWeek == 0 || dayOfWeek == 6) {
        total += dailyLoads[day] ?? 0;
      }
    }

    return total;
  }

  int _getWeekdayCount(int week) {
    int count = 0;
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    int startDay, endDay;
    if (week == 1) {
      startDay = 1;
      endDay = 7 - firstDayOfWeek;
    } else {
      startDay = (7 - firstDayOfWeek) + (week - 2) * 7 + 1;
      endDay = startDay + 6;
    }

    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    endDay = endDay.clamp(startDay, daysInMonth);

    for (int day = startDay; day <= endDay; day++) {
      final dayOfWeek = (firstDayOfWeek + day - 1) % 7;
      if (dayOfWeek >= 1 && dayOfWeek <= 5) {
        count++;
      }
    }

    return count;
  }

  int _getWeekendCount(int week) {
    int count = 0;
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    int startDay, endDay;
    if (week == 1) {
      startDay = 1;
      endDay = 7 - firstDayOfWeek;
    } else {
      startDay = (7 - firstDayOfWeek) + (week - 2) * 7 + 1;
      endDay = startDay + 6;
    }

    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    endDay = endDay.clamp(startDay, daysInMonth);

    for (int day = startDay; day <= endDay; day++) {
      final dayOfWeek = (firstDayOfWeek + day - 1) % 7;
      if (dayOfWeek == 0 || dayOfWeek == 6) {
        count++;
      }
    }

    return count;
  }
}
