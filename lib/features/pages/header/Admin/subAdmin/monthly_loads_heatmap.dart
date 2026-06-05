import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';

class MonthlyLoadsHeatmap extends StatefulWidget {
  final DateTime currentMonth;
  final bool isMobile;
  final bool isTablet;

  const MonthlyLoadsHeatmap({
    super.key,
    required this.currentMonth,
    this.isMobile = false,
    this.isTablet = false,
  });

  @override
  State<MonthlyLoadsHeatmap> createState() => _MonthlyLoadsHeatmapState();
}

class _MonthlyLoadsHeatmapState extends State<MonthlyLoadsHeatmap> {
  late DateTime currentMonth;
  Map<int, Map<String, int>> dailyLoads =
      {}; // day -> {finalLoadOuter, finalLoadInner, finalLoadForBonus}
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

      // Eligible item IDs for inner calculation
      const Set<int> eligibleItemIds = {
        menuOth155,
        menuOth195,
        menuOth165,
        menuOth125,
        menuOth225,
        menuOth150,
        menuOthW9t10
      };

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
            final finalLoadForBonus = jobModel.finalLoadForBonus ?? 0;
            final finalLoad = jobModel.finalLoad ?? 0;

            if (!dailyLoads.containsKey(day)) {
              dailyLoads[day] = {
                'finalLoadOuter': 0,
                'finalLoadInner': 0,
                'finalLoadForBonus': 0
              };
            }

            // Add to outer (no filter - sum of all finalLoad)
            dailyLoads[day]!['finalLoadOuter'] =
                (dailyLoads[day]!['finalLoadOuter'] ?? 0) + finalLoad;

            // Add to inner (filter by eligible items only)
            int eligibleItemsLoad = 0;
            for (var item in jobModel.items) {
              if (eligibleItemIds.contains(item.itemId)) {
                // Items that count as 2 loads
                if ([menuOth195, menuOth165].contains(item.itemId)) {
                  eligibleItemsLoad += 2;
                } else {
                  // All others = 1 load each
                  eligibleItemsLoad += 1;
                }
              }
            }

            dailyLoads[day]!['finalLoadInner'] =
                (dailyLoads[day]!['finalLoadInner'] ?? 0) + eligibleItemsLoad;

            // Track finalLoadForBonus (no filter)
            dailyLoads[day]!['finalLoadForBonus'] =
                (dailyLoads[day]!['finalLoadForBonus'] ?? 0) +
                    finalLoadForBonus;
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
  void didUpdateWidget(MonthlyLoadsHeatmap oldWidget) {
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
              '1️⃣ Monthly Loads Heatmap',
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
              _buildHeatmap(daysInMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(int daysInMonth) {
    final maxLoads = _getMaxLoads();
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDayOfWeek = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final cellSize = widget.isMobile ? 35.0 : (widget.isTablet ? 45.0 : 50.0);
    final fontSize = widget.isMobile ? 9.0 : (widget.isTablet ? 10.0 : 12.0);

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize - 1,
                      color: (i == 0 || i == 6)
                          ? Colors.red
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._buildWeekRows(
            daysInMonth, firstDayOfWeek, maxLoads, cellSize, fontSize),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Low', Colors.blue.shade100, fontSize - 2),
              const SizedBox(width: 12),
              _buildLegendItem('Med', Colors.blue.shade300, fontSize - 2),
              const SizedBox(width: 12),
              _buildLegendItem('High', Colors.blue.shade500, fontSize - 2),
              const SizedBox(width: 12),
              _buildLegendItem('V.High', Colors.blue.shade700, fontSize - 2),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeekRows(int daysInMonth, int firstDayOfWeek, int maxLoads,
      double cellSize, double fontSize) {
    final weeks = <Widget>[];
    int day = 1;
    int weekNumber = 1;

    while (day <= daysInMonth) {
      final weekDays = <Widget>[];

      if (weekNumber == 1) {
        for (int i = 0; i < firstDayOfWeek; i++) {
          weekDays.add(Expanded(
            child: SizedBox(height: cellSize),
          ));
        }
      }

      for (int i = (weekNumber == 1 ? firstDayOfWeek : 0);
          i < 7 && day <= daysInMonth;
          i++) {
        final dayData = dailyLoads[day];
        final finalLoadOuter = dayData?['finalLoadOuter'] ?? 0;
        final finalLoadInner = dayData?['finalLoadInner'] ?? 0;
        final finalLoadForBonus = dayData?['finalLoadForBonus'] ?? 0;

        // Display: finalLoadOuter(innerValue) where innerValue is finalLoadInner or finalLoadForBonus if =0
        final displayInner =
            finalLoadForBonus == 0 ? finalLoadInner : finalLoadForBonus;

        final cellColor = _getHeatmapColor(finalLoadOuter, maxLoads);
        final isWeekend = i == 0 || i == 6;

        weekDays.add(
          Expanded(
            child: Tooltip(
              message: 'Day $day: $finalLoadOuter($displayInner)',
              child: Container(
                height: cellSize,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isWeekend
                        ? Colors.red
                        : Colors.grey.withValues(alpha: 0.5),
                    width: isWeekend ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        fontSize: fontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: finalLoadOuter > maxLoads * 0.5
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                    if (finalLoadOuter > 0 || displayInner > 0) ...[
                      const SizedBox(height: 1),
                      Text(
                        '$finalLoadOuter($displayInner)',
                        style: TextStyle(
                          fontSize:
                              widget.isMobile ? fontSize - 4 : fontSize - 3,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
        day++;
      }

      while (weekDays.length < 7) {
        weekDays.add(Expanded(
          child: SizedBox(height: cellSize),
        ));
      }

      weeks.add(
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Week $weekNumber',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Row(children: weekDays),
          ],
        ),
      );

      weeks.add(const SizedBox(height: 8));
      weekNumber++;
    }

    return weeks;
  }

  int _getMaxLoads() {
    if (dailyLoads.isEmpty) return 0;
    int maxLoad = 0;
    for (var dayData in dailyLoads.values) {
      final finalLoadOuter = dayData['finalLoadOuter'] ?? 0;
      if (finalLoadOuter > maxLoad) maxLoad = finalLoadOuter;
    }
    return maxLoad;
  }

  Color _getHeatmapColor(int loads, int maxLoads) {
    if (loads == 0) return Colors.grey.shade200;
    if (maxLoads == 0) return Colors.grey.shade200;

    final intensity = loads / maxLoads;

    if (intensity < 0.25) return Colors.blue.shade100;
    if (intensity < 0.5) return Colors.blue.shade300;
    if (intensity < 0.75) return Colors.blue.shade500;
    return Colors.blue.shade700;
  }

  Widget _buildLegendItem(String label, Color color, double fontSize) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: fontSize)),
      ],
    );
  }
}
