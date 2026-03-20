import 'package:flutter/material.dart';
import 'analytics_helpers.dart';

class WeeklyRevenueChart extends StatelessWidget {
  final Map<int, Map<String, dynamic>> weeklyData;
  final int totalLoads;
  final int totalJobs;
  final bool isMobile;
  final String Function(int week) getWeekDateRange;

  const WeeklyRevenueChart({
    super.key,
    required this.weeklyData,
    required this.totalLoads,
    required this.totalJobs,
    required this.isMobile,
    required this.getWeekDateRange,
  });

  int get _totalPaid =>
      weeklyData.values.fold(0, (s, w) => s + (w['paid'] as int? ?? 0));
  int get _totalPaidCash =>
      weeklyData.values.fold(0, (s, w) => s + (w['paidCash'] as int? ?? 0));
  int get _totalPaidGCash =>
      weeklyData.values.fold(0, (s, w) => s + (w['paidGCash'] as int? ?? 0));
  int get _totalUnpaid =>
      weeklyData.values.fold(0, (s, w) => s + (w['unpaid'] as int? ?? 0));
  int get _totalRevenue => _totalPaid + _totalUnpaid;

  int get _maxValue {
    int max = 0;
    for (var w in weeklyData.values) {
      for (final key in ['paid', 'paidCash', 'paidGCash', 'unpaid']) {
        final v = w[key] as int? ?? 0;
        if (v > max) max = v;
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Revenue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$totalLoads loads, $totalJobs jobs',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            _buildRevenueSummary(),
            const SizedBox(height: 16),
            if (totalJobs == 0)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No data for this month',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text('Try selecting a different month',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width - 40
                          : 600,
                      height: 280,
                      child: _buildBars(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width - 40
                          : null,
                      child: _buildSummaryTable(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Revenue:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800)),
              Text('₱${formatCurrency(_totalRevenue)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniTile('Paid', _totalPaid, Colors.green),
              const SizedBox(width: 8),
              _miniTile('Cash', _totalPaidCash, Colors.blue),
              const SizedBox(width: 8),
              _miniTile('GCash', _totalPaidGCash, Colors.purple),
              const SizedBox(width: 8),
              _miniTile('Unpaid', _totalUnpaid, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTile(String label, int amount, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: color.shade700)),
            Text('₱${formatCurrency(amount)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _buildBars() {
    const chartHeight = 180.0;
    const yAxisWidth = 60.0;
    final maxValue = _maxValue;
    final interval = calculateYAxisInterval(maxValue);
    final maxYValue =
        maxValue == 0 ? 1 : ((maxValue / interval).ceil() * interval).toInt();
    final yAxisLabels = <int>[for (int i = 0; i <= maxYValue; i += interval) i];

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 40),
      child: Column(
        children: [
          Expanded(
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
                    children: List.generate(5, (i) {
                      final week = i + 1;
                      final paid = weeklyData[week]?['paid'] as int? ?? 0;
                      final cash = weeklyData[week]?['paidCash'] as int? ?? 0;
                      final gcash = weeklyData[week]?['paidGCash'] as int? ?? 0;
                      final unpaid = weeklyData[week]?['unpaid'] as int? ?? 0;

                      double h(int v) =>
                          maxYValue > 0 ? (v / maxYValue) * chartHeight : 0.0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _barSlice(
                                        'Week $week\nPaid: ₱${formatCurrency(paid)}',
                                        h(paid),
                                        Colors.green,
                                        chartHeight),
                                    _barSlice(
                                        'Week $week\nCash: ₱${formatCurrency(cash)}',
                                        h(cash),
                                        Colors.blue,
                                        chartHeight),
                                    _barSlice(
                                        'Week $week\nGCash: ₱${formatCurrency(gcash)}',
                                        h(gcash),
                                        Colors.purple,
                                        chartHeight),
                                    _barSlice(
                                        'Week $week\nUnpaid: ₱${formatCurrency(unpaid)}',
                                        h(unpaid),
                                        Colors.red,
                                        chartHeight),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(getWeekDateRange(week),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              _legend('Paid Revenue', Colors.green.shade400),
              _legend('Cash Received', Colors.blue.shade400),
              _legend('GCash Received', Colors.purple.shade400),
              _legend('Unpaid Revenue', Colors.red.shade400),
            ],
          ),
          const SizedBox(height: 8),
          Text('Each week shows 4 separate bars for easy comparison',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _barSlice(
      String tooltip, double height, MaterialColor color, double chartHeight) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Container(
          height: height.clamp(2, chartHeight),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: color.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          DataTable(
            columnSpacing: 20,
            headingRowHeight: 35,
            dataRowHeight: 30,
            headingTextStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            dataTextStyle: const TextStyle(fontSize: 11),
            columns: const [
              DataColumn(label: Text('Week')),
              DataColumn(label: Text('Total'), numeric: true),
              DataColumn(label: Text('Paid'), numeric: true),
              DataColumn(label: Text('Cash'), numeric: true),
              DataColumn(label: Text('GCash'), numeric: true),
              DataColumn(label: Text('Unpaid'), numeric: true),
            ],
            rows: List.generate(5, (i) {
              final week = i + 1;
              final paid = weeklyData[week]?['paid'] as int? ?? 0;
              final cash = weeklyData[week]?['paidCash'] as int? ?? 0;
              final gcash = weeklyData[week]?['paidGCash'] as int? ?? 0;
              final unpaid = weeklyData[week]?['unpaid'] as int? ?? 0;
              final total = paid + unpaid;
              return DataRow(cells: [
                DataCell(Text('Week $week',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text('₱${formatCurrency(total)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            total > 0 ? Colors.blue.shade700 : Colors.grey))),
                DataCell(Text('₱${formatCurrency(paid)}',
                    style: TextStyle(
                        color:
                            paid > 0 ? Colors.green.shade700 : Colors.grey))),
                DataCell(Text('₱${formatCurrency(cash)}',
                    style: TextStyle(
                        color: cash > 0 ? Colors.blue.shade700 : Colors.grey))),
                DataCell(Text('₱${formatCurrency(gcash)}',
                    style: TextStyle(
                        color:
                            gcash > 0 ? Colors.purple.shade700 : Colors.grey))),
                DataCell(Text('₱${formatCurrency(unpaid)}',
                    style: TextStyle(
                        color:
                            unpaid > 0 ? Colors.red.shade700 : Colors.grey))),
              ]);
            }),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Month Total:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₱${formatCurrency(_totalRevenue)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }
}
