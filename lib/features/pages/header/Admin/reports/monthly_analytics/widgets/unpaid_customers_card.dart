import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class UnpaidCustomersCard extends StatelessWidget {
  final Map<String, int> unpaidCustomers;
  final Map<int, int> unpaidByWeek;
  final Map<int, Map<String, int>> unpaidCustomersByWeek;
  final DateTime currentMonth;
  final bool hasJobs;

  const UnpaidCustomersCard({
    super.key,
    required this.unpaidCustomers,
    required this.unpaidByWeek,
    required this.unpaidCustomersByWeek,
    required this.currentMonth,
    required this.hasJobs,
  });

  @override
  Widget build(BuildContext context) {
    final totalUnpaid = unpaidCustomers.values.fold(0, (s, v) => s + v);
    final monthLabel = DateFormat('MMMM yyyy').format(currentMonth);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Unpaid Customers — $monthLabel',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!hasJobs)
              _emptyState(Icons.people_outline, 'No completed jobs this month',
                  Colors.grey)
            else if (unpaidCustomers.isEmpty)
              _emptyState(Icons.check_circle_outline, 'All customers paid!',
                  Colors.green)
            else ...[
              // ── Month total section (always expanded) ──────────────
              _UnpaidSection(
                title: monthLabel,
                customers: unpaidCustomers,
                total: totalUnpaid,
                initiallyExpanded: true,
                headerColor: Colors.red.shade100,
              ),
              const SizedBox(height: 8),

              // ── Per-week sections (collapsed by default) ───────────
              ...List.generate(5, (i) {
                final week = i + 1;
                final weekMap = unpaidCustomersByWeek[week] ?? {};
                final weekTotal = unpaidByWeek[week] ?? 0;
                if (weekMap.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _UnpaidSection(
                    title: 'Week $week',
                    customers: weekMap,
                    total: weekTotal,
                    initiallyExpanded: false,
                    headerColor: Colors.orange.shade50,
                  ),
                );
              }),
            ],
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

/// Expandable section showing a list of unpaid customers + total footer.
class _UnpaidSection extends StatelessWidget {
  final String title;
  final Map<String, int> customers;
  final int total;
  final bool initiallyExpanded;
  final Color headerColor;

  const _UnpaidSection({
    required this.title,
    required this.customers,
    required this.total,
    required this.initiallyExpanded,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = customers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        // Remove default ExpansionTile dividers
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          collapsedBackgroundColor: headerColor,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              Text(
                '₱${formatCurrency(total)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: total > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...sorted.take(10).map((e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e.key,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '₱${formatCurrency(e.value)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                    ],
                  ),
                )),
            if (sorted.length > 10)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '+${sorted.length - 10} more',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
