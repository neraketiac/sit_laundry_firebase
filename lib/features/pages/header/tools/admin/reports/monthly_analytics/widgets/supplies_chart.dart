import 'package:flutter/material.dart';
import 'analytics_helpers.dart';

class SuppliesChart extends StatelessWidget {
  final Map<String, int> suppliesData;
  final bool isMobile;

  const SuppliesChart({
    super.key,
    required this.suppliesData,
    required this.isMobile,
  });

  int get _maxValue {
    int max = 0;
    for (var v in suppliesData.values) {
      if (v > max) max = v;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    const chartHeight = 180.0;
    const yAxisWidth = 60.0;
    final maxValue = _maxValue;
    final interval = calculateYAxisInterval(maxValue);
    final maxYValue =
        maxValue == 0 ? 1 : ((maxValue / interval).ceil() * interval).toInt();
    final yAxisLabels = <int>[for (int i = 0; i <= maxYValue; i += interval) i];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supplies & Funds Chart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: isMobile ? MediaQuery.of(context).size.width - 40 : 600,
                height: 280,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 20, top: 20, bottom: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: yAxisWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: yAxisLabels.reversed
                              .map((v) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      v >= 1000
                                          ? '${(v / 1000).toStringAsFixed(0)}k'
                                          : v.toString(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar('Funds\nIn', suppliesData['Funds In'] ?? 0,
                                Colors.teal, maxYValue, chartHeight),
                            _bar('Funds\nOut', suppliesData['Funds Out'] ?? 0,
                                Colors.orange, maxYValue, chartHeight),
                            _bar(
                                'Laundry\nPayment',
                                suppliesData['Laundry Payment'] ?? 0,
                                Colors.blue,
                                maxYValue,
                                chartHeight),
                            _bar(
                                'Cash In/\nLoad',
                                suppliesData['Cash In/Load'] ?? 0,
                                Colors.green,
                                maxYValue,
                                chartHeight),
                            _bar('Cash\nOut', suppliesData['Cash Out'] ?? 0,
                                Colors.red, maxYValue, chartHeight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, int value, MaterialColor color, int maxYValue,
      double chartHeight) {
    final barHeight = maxYValue > 0 ? (value / maxYValue) * chartHeight : 0.0;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: '$label: ₱${formatCurrency(value)}',
              child: Container(
                height: barHeight.clamp(2, chartHeight),
                decoration: BoxDecoration(
                  color: color.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
