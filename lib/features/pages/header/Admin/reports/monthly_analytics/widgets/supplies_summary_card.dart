import 'package:flutter/material.dart';
import 'analytics_helpers.dart';

class SuppliesSummaryCard extends StatelessWidget {
  final Map<String, int> suppliesData;
  final bool isMobile;

  const SuppliesSummaryCard({
    super.key,
    required this.suppliesData,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supplies & Funds Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 2 : 5,
              childAspectRatio: isMobile ? 1.5 : 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _tile('Funds In', suppliesData['Funds In'] ?? 0, Colors.teal),
                _tile(
                    'Funds Out', suppliesData['Funds Out'] ?? 0, Colors.orange),
                _tile('Laundry Payment', suppliesData['Laundry Payment'] ?? 0,
                    Colors.blue),
                _tile('Cash In/Load', suppliesData['Cash In/Load'] ?? 0,
                    Colors.green),
                _tile('Cash Out', suppliesData['Cash Out'] ?? 0, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, int amount, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.shade800),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('₱${formatCurrency(amount)}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.shade900)),
        ],
      ),
    );
  }
}
