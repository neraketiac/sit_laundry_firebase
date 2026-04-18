import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class UnpaidCustomersCard extends StatelessWidget {
  final Map<String, int> unpaidCustomers;
  final Map<int, int> unpaidByWeek;
  final Map<int, Map<String, int>> unpaidCustomersByWeek;
  final DateTime currentMonth;
  final bool hasJobs;
  final String Function(int week) getWeekDateRange;

  const UnpaidCustomersCard({
    super.key,
    required this.unpaidCustomers,
    required this.unpaidByWeek,
    required this.unpaidCustomersByWeek,
    required this.currentMonth,
    required this.hasJobs,
    required this.getWeekDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final totalUnpaid = unpaidCustomers.values.fold(0, (s, v) => s + v);
    final monthLabel = DateFormat('MMM yyyy').format(currentMonth);

    // Collect only weeks that have unpaid data
    final activeWeeks = List.generate(5, (i) => i + 1)
        .where((w) => (unpaidCustomersByWeek[w] ?? {}).isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Unpaid Customers — ${DateFormat('MMMM yyyy').format(currentMonth)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!hasJobs)
              _emptyState(Icons.people_outline, 'No completed jobs this month',
                  Colors.grey)
            else if (unpaidCustomers.isEmpty)
              _emptyState(Icons.check_circle_outline, 'All customers paid!',
                  Colors.green)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Month column
                      _UnpaidColumn(
                        title: monthLabel,
                        customers: unpaidCustomers,
                        total: totalUnpaid,
                        accentColor: Colors.red.shade100,
                      ),
                      // Week columns
                      ...activeWeeks.map((week) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _UnpaidColumn(
                              title: 'Week $week\n${getWeekDateRange(week)}',
                              customers: unpaidCustomersByWeek[week] ?? {},
                              total: unpaidByWeek[week] ?? 0,
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

  Widget _emptyState(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _UnpaidColumn extends StatelessWidget {
  final String title;
  final Map<String, int> customers;
  final int total;
  final Color accentColor;

  const _UnpaidColumn({
    required this.title,
    required this.customers,
    required this.total,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = customers.entries.toList()
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
          // Rows — Expanded so footer always aligns to bottom
          Expanded(
            child: Column(
              children: [
                ...sorted.take(10).map((e) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100)),
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
                            '₱${formatCurrency(e.value)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
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
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          // Footer total — always at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: total > 0 ? Colors.red.shade50 : Colors.green.shade50,
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
                  '₱${formatCurrency(total)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: total > 0 ? Colors.red : Colors.green,
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
