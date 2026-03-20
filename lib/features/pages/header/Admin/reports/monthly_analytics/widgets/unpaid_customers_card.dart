import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analytics_helpers.dart';

class UnpaidCustomersCard extends StatelessWidget {
  final Map<String, int> unpaidCustomers;
  final DateTime currentMonth;
  final bool hasJobs;

  const UnpaidCustomersCard({
    super.key,
    required this.unpaidCustomers,
    required this.currentMonth,
    required this.hasJobs,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = unpaidCustomers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalUnpaid = unpaidCustomers.values.fold(0, (s, v) => s + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Top Unpaid Customers(${DateFormat('MMMM yyyy').format(currentMonth)})',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (!hasJobs)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No completed jobs this month',
                        style: TextStyle(color: Colors.grey)),
                  ]),
                ),
              )
            else if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text('All customers paid!',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Amount'), numeric: true),
                  ],
                  rows: sorted
                      .take(10)
                      .map((e) => DataRow(cells: [
                            DataCell(Text(e.key,
                                style: const TextStyle(fontSize: 12))),
                            DataCell(Text('₱${formatCurrency(e.value)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red))),
                          ]))
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: totalUnpaid == 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Unpaid:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₱${formatCurrency(totalUnpaid)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: totalUnpaid == 0 ? Colors.green : Colors.red,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
