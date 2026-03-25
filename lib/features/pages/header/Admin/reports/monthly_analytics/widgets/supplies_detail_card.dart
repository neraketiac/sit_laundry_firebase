import 'package:flutter/material.dart';
import 'analytics_helpers.dart';

/// Collapsible card showing SuppliesHist grouped by ItemName, summed by CurrentCounter.
/// Positive = in, negative = out. Sorted by absolute value descending.
class SuppliesDetailCard extends StatelessWidget {
  final Map<String, int> byItemName;

  const SuppliesDetailCard({super.key, required this.byItemName});

  @override
  Widget build(BuildContext context) {
    if (byItemName.isEmpty) return const SizedBox.shrink();

    final sorted = byItemName.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final totalIn =
        byItemName.values.where((v) => v > 0).fold(0, (s, v) => s + v);
    final totalOut =
        byItemName.values.where((v) => v < 0).fold(0, (s, v) => s + v.abs());

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: const Text(
            'Supplies Detail',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'In: ₱${formatCurrency(totalIn)}  |  Out: ₱${formatCurrency(totalOut)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text('Item',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text('Total',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...sorted.map((e) {
              final isNeg = e.value < 0;
              final color = isNeg ? Colors.red.shade700 : Colors.green.shade700;
              final display = isNeg ? '-${e.value.abs()}' : '+${e.value}';
              return Container(
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        e.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        display,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            // Footer totals
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('In: +$totalIn',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700)),
                  Text('Out: -$totalOut',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700)),
                  Text(
                    'Net: ${totalIn - totalOut >= 0 ? '+' : ''}${totalIn - totalOut}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (totalIn - totalOut) >= 0
                            ? Colors.blue.shade700
                            : Colors.red.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
