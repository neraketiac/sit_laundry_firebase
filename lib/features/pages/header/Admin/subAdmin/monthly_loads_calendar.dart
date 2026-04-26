import 'package:flutter/material.dart';
import 'monthly_loads_heatmap.dart';
import 'monthly_loads_bar_chart.dart';
import 'monthly_loads_line_chart.dart';
import 'monthly_loads_line_chart_per_day.dart';

class MonthlyLoadsCalendar extends StatelessWidget {
  final DateTime currentMonth;

  const MonthlyLoadsCalendar({
    super.key,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Column(
      children: [
        MonthlyLoadsHeatmap(
          currentMonth: currentMonth,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        const SizedBox(height: 20),
        MonthlyLoadsBarChart(
          currentMonth: currentMonth,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        const SizedBox(height: 20),
        MonthlyLoadsLineChart(
          currentMonth: currentMonth,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        const SizedBox(height: 20),
        MonthlyLoadsLineChartPerDay(
          currentMonth: currentMonth,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
      ],
    );
  }
}
