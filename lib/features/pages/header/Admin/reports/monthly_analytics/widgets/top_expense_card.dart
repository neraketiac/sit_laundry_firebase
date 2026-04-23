import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class TopExpenseCard extends StatelessWidget {
  final Map<String, int> expenseByEmployee;
  final Map<int, int> expenseByWeek;
  final Map<int, Map<String, int>> employeeByWeek;
  final DateTime currentMonth;
  final String Function(int week) getWeekDateRange;

  const TopExpenseCard({
    super.key,
    required this.expenseByEmployee,
    required this.expenseByWeek,
    required this.employeeByWeek,
    required this.currentMonth,
    required this.getWeekDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = expenseByEmployee.values.fold(0, (s, v) => s + v);
    final monthLabel = DateFormat('MMM yyyy').format(currentMonth);

    // Sort by monthly total descending — all columns follow this order
    final sortedEmployees = expenseByEmployee.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final orderedNames = sortedEmployees.map((e) => e.key).toList();

    final activeWeeks = List.generate(5, (i) => i + 1)
        .where((w) => (employeeByWeek[w] ?? {}).isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Expense — ${DateFormat('MMMM yyyy').format(currentMonth)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (expenseByEmployee.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text('No expenses this month',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ExpenseColumn(
                        title: monthLabel,
                        orderedNames: orderedNames,
                        dataMap: expenseByEmployee,
                        total: totalExpense,
                        accentColor: Colors.orange.shade100,
                        footerColor: Colors.orange.shade50,
                        valueColor: Colors.orange,
                        prefix: '-₱',
                      ),
                      ...activeWeeks.map((week) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _ExpenseColumn(
                              title: 'Week $week\n${getWeekDateRange(week)}',
                              orderedNames: orderedNames,
                              dataMap: employeeByWeek[week] ?? {},
                              total: expenseByWeek[week] ?? 0,
                              accentColor: Colors.orange.shade50,
                              footerColor: Colors.orange.shade50,
                              valueColor: Colors.orange,
                              prefix: '-₱',
                            ),
                          )),
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

class _ExpenseColumn extends StatelessWidget {
  final String title;
  final List<String> orderedNames;
  final Map<String, int> dataMap;
  final int total;
  final Color accentColor;
  final Color footerColor;
  final Color valueColor;
  final String prefix;

  const _ExpenseColumn({
    required this.title,
    required this.orderedNames,
    required this.dataMap,
    required this.total,
    required this.accentColor,
    required this.footerColor,
    required this.valueColor,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Rows — same order as monthly, show 0 if missing
          Expanded(
            child: Column(
              children: orderedNames.map((name) {
                final value = dataMap[name] ?? 0;
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
                        name,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        value == 0 ? '—' : '$prefix${formatCurrency(value)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: value == 0 ? Colors.grey.shade400 : valueColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Footer — always at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: footerColor,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  '$prefix${formatCurrency(total)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
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
