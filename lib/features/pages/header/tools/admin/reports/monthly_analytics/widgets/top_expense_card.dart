import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class TopExpenseCard extends StatelessWidget {
  final Map<String, int> expenseByEmployee;
  final Map<int, int> expenseByWeek;
  final Map<int, Map<String, int>> employeeByWeek;
  final DateTime currentMonth;

  const TopExpenseCard({
    super.key,
    required this.expenseByEmployee,
    required this.expenseByWeek,
    required this.employeeByWeek,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = expenseByEmployee.values.fold(0, (s, v) => s + v);
    final monthLabel = DateFormat('MMM yyyy').format(currentMonth);

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month column
                      _ExpenseColumn(
                        title: monthLabel,
                        employees: expenseByEmployee,
                        total: totalExpense,
                        accentColor: Colors.orange.shade100,
                      ),
                      // Week columns
                      ...activeWeeks.map((week) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _ExpenseColumn(
                              title: 'Week $week',
                              employees: employeeByWeek[week] ?? {},
                              total: expenseByWeek[week] ?? 0,
                              accentColor: Colors.orange.shade50,
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
  final Map<String, int> employees;
  final int total;
  final Color accentColor;

  const _ExpenseColumn({
    required this.title,
    required this.employees,
    required this.total,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = employees.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          // Rows
          ...sorted.take(10).map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      '-₱${formatCurrency(e.value)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              )),
          if (sorted.length > 10)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '+${sorted.length - 10} more',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
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
                  '-₱${formatCurrency(total)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
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
