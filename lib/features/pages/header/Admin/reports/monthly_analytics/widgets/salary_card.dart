import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class SalaryCard extends StatelessWidget {
  final Map<String, int> salaryByEmployee;
  final Map<int, int> salaryByWeek;
  final Map<int, Map<String, int>> salaryEmployeeByWeek;
  final Map<String, int> expenseByEmployee;
  final Map<int, Map<String, int>> expenseEmployeeByWeek;
  final DateTime currentMonth;
  final String Function(int week) getWeekDateRange;

  const SalaryCard({
    super.key,
    required this.salaryByEmployee,
    required this.salaryByWeek,
    required this.salaryEmployeeByWeek,
    required this.expenseByEmployee,
    required this.expenseEmployeeByWeek,
    required this.currentMonth,
    required this.getWeekDateRange,
  });

  @override
  Widget build(BuildContext context) {
    if (salaryByEmployee.isEmpty) return const SizedBox.shrink();

    final orderedNames = salaryByEmployee.keys.toList()
      ..sort((a, b) =>
          (salaryByEmployee[b] ?? 0).compareTo(salaryByEmployee[a] ?? 0));

    final totalSalary =
        orderedNames.fold(0, (s, e) => s + (salaryByEmployee[e] ?? 0));
    final totalExpense =
        orderedNames.fold(0, (s, e) => s + (expenseByEmployee[e] ?? 0));

    final activeWeeks = List.generate(5, (i) => i + 1)
        .where((w) =>
            (salaryEmployeeByWeek[w] ?? {}).isNotEmpty ||
            (expenseEmployeeByWeek[w] ?? {}).isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary — ${DateFormat('MMMM yyyy').format(currentMonth)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Salary  (+over / -under expense)',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SalaryColumn(
                      title: DateFormat('MMM yyyy').format(currentMonth),
                      orderedNames: orderedNames,
                      salaryMap: salaryByEmployee,
                      expenseMap: expenseByEmployee,
                      totalSalary: totalSalary,
                      totalExpense: totalExpense,
                      accentColor: Colors.indigo.shade100,
                    ),
                    ...activeWeeks.map((w) {
                      final wSalary = orderedNames.fold(
                          0, (s, e) => s + (salaryEmployeeByWeek[w]?[e] ?? 0));
                      final wExpense = orderedNames.fold(
                          0, (s, e) => s + (expenseEmployeeByWeek[w]?[e] ?? 0));
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _SalaryColumn(
                          title: 'Week $w\n${getWeekDateRange(w)}',
                          orderedNames: orderedNames,
                          salaryMap: salaryEmployeeByWeek[w] ?? {},
                          expenseMap: expenseEmployeeByWeek[w] ?? {},
                          totalSalary: wSalary,
                          totalExpense: wExpense,
                          accentColor: Colors.indigo.shade50,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalaryColumn extends StatelessWidget {
  final String title;
  final List<String> orderedNames;
  final Map<String, int> salaryMap;
  final Map<String, int> expenseMap;
  final int totalSalary;
  final int totalExpense;
  final Color accentColor;

  const _SalaryColumn({
    required this.title,
    required this.orderedNames,
    required this.salaryMap,
    required this.expenseMap,
    required this.totalSalary,
    required this.totalExpense,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use absolute value of expense: net = salary - abs(expense)
    final totalExpenseAbsolute = totalExpense.abs();
    final totalDiff = totalSalary - totalExpenseAbsolute;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      // Use Column with spaceBetween so footer always at bottom
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top: header + rows
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              // Rows
              ...orderedNames.map((emp) {
                final salary = salaryMap[emp] ?? 0;
                final expense = expenseMap[emp] ?? 0;
                final expenseAbsolute = expense.abs();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      salary == 0 && expense == 0
                          ? Text('—',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade400))
                          : Wrap(
                              spacing: 4,
                              children: [
                                Text(
                                  salary == 0
                                      ? '₱0'
                                      : '₱${formatCurrency(salary)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: salary == 0
                                        ? Colors.grey.shade400
                                        : Colors.indigo,
                                  ),
                                ),
                                if (expense != 0)
                                  Text(
                                    '(₱${formatCurrency(expenseAbsolute)})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: expenseAbsolute > salary
                                          ? Colors.red.shade600
                                          : Colors.green.shade600,
                                    ),
                                  ),
                              ],
                            ),
                    ],
                  ),
                );
              }),
            ],
          ),
          // Bottom: footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(
                      '₱${formatCurrency(totalSalary)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                if (totalDiff != 0)
                  Text(
                    '₱${formatCurrency(totalDiff)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: totalDiff < 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
