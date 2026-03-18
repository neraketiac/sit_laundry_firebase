import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

class MonthlyAnalyticsPage extends StatefulWidget {
  const MonthlyAnalyticsPage({super.key});

  @override
  State<MonthlyAnalyticsPage> createState() => _MonthlyAnalyticsPageState();
}

class _MonthlyAnalyticsPageState extends State<MonthlyAnalyticsPage> {
  late DateTime currentMonth;
  List<JobModelRepository> completedJobs = [];
  Map<int, Map<String, dynamic>> weeklyData = {};
  Map<String, int> unpaidCustomers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() => isLoading = true);

    final startDate = DateTime(currentMonth.year, currentMonth.month, 1);
    final endDate = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    try {
      print('Loading data for: ${DateFormat('MMMM yyyy').format(currentMonth)}');
      print('Date range: $startDate to $endDate');
      
      // Load from Jobs_done
      final doneSnapshot = await FirebaseFirestore.instance
          .collection('Jobs_done')
          .where('A05_DateD', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Load from Jobs_completed  
      final completedSnapshot = await FirebaseFirestore.instance
          .collection('Jobs_completed')
          .where('A05_DateD', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      print('Found ${doneSnapshot.docs.length} done jobs and ${completedSnapshot.docs.length} completed jobs');

      completedJobs = [];
      
      // Process Jobs_done
      for (var doc in doneSnapshot.docs) {
        final jobRepo = JobModelRepository();
        final jobModel = JobModel.fromFirestore(doc.data(), doc.id);
        jobRepo.setJobModel(jobModel);
        completedJobs.add(jobRepo);
      }
      
      // Process Jobs_completed
      for (var doc in completedSnapshot.docs) {
        final jobRepo = JobModelRepository();
        final jobModel = JobModel.fromFirestore(doc.data(), doc.id);
        jobRepo.setJobModel(jobModel);
        completedJobs.add(jobRepo);
      }

      _processWeeklyData();
      _processUnpaidCustomers();
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => isLoading = false);
  }

  void _processWeeklyData() {
    weeklyData.clear();

    for (int week = 1; week <= 5; week++) {
      weeklyData[week] = {
        'paid': 0,
        'paidCash': 0,
        'unpaid': 0,
        'dates': _getWeekDateRange(week),
      };
    }

    for (var job in completedJobs) {
      if (job.dateD == null) continue;

      DateTime jobDate = job.dateD is Timestamp
          ? (job.dateD as Timestamp).toDate()
          : job.dateD as DateTime;

      int week = _getWeekNumber(jobDate);
      
      int finalPrice = job.finalPrice ?? 0;
      int paidCash = (job.paidCashAmount ?? 0);
      int paidGCash = (job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0;
      int totalPaid = paidCash + paidGCash;
      int unpaidAmount = finalPrice - totalPaid;

      if (unpaidAmount > 0) {
        weeklyData[week]!['unpaid'] += unpaidAmount;
      }
      
      if (totalPaid > 0) {
        weeklyData[week]!['paid'] += totalPaid;
        weeklyData[week]!['paidCash'] += totalPaid;
      }
    }
  }

  void _processUnpaidCustomers() {
    unpaidCustomers.clear();

    for (var job in completedJobs) {
      if (job.customerName != null) {
        int finalPrice = job.finalPrice ?? 0;
        int paidCash = (job.paidCashAmount ?? 0);
        int paidGCash = (job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0;
        int totalPaid = paidCash + paidGCash;
        int unpaidAmount = finalPrice - totalPaid;
        
        if (unpaidAmount > 0) {
          unpaidCustomers[job.customerName!] =
              (unpaidCustomers[job.customerName!] ?? 0) + unpaidAmount;
        }
      }
    }
  }

  int _getWeekNumber(DateTime date) {
    int day = date.day;
    if (day <= 7) return 1;
    if (day <= 14) return 2;
    if (day <= 21) return 3;
    if (day <= 28) return 4;
    return 5;
  }

  String _getWeekDateRange(int week) {
    int startDay = (week - 1) * 7 + 1;
    int endDay = week * 7;

    if (week == 5) {
      endDay = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    }

    String monthAbbr = DateFormat('MMM').format(currentMonth);
    return '$monthAbbr$startDay-$endDay';
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      _loadMonthlyData();
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      _loadMonthlyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analytics'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 20),
                  _buildWeeklyChart(isMobile),
                  const SizedBox(height: 30),
                  _buildUnpaidCustomersSummary(isMobile),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousMonth,
            ),
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(bool isMobile) {
    final totalRevenue = _getTotalRevenue();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${completedJobs.length} jobs', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            // Total Revenue Indicators
            Container(
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
                      Text('Total Revenue:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800)),
                      Text(
                        '₱${_formatCurrency(_getTotalRevenue())}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('Paid', style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
                              Text('₱${_formatCurrency(_getTotalPaid())}', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('Unpaid', style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
                              Text('₱${_formatCurrency(_getTotalUnpaid())}', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (completedJobs.isEmpty)
              Container(
                height: 200,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No data for this month', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      Text('Try selecting a different month', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                      width: isMobile ? MediaQuery.of(context).size.width - 40 : 600,
                      height: 280,
                      child: _buildChartContent(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isMobile ? MediaQuery.of(context).size.width - 40 : null,
                      child: _buildWeeklySummaryTable(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    final maxValue = _getMaxValue();
    final chartHeight = 180.0;
    final yAxisWidth = 60.0;

    // Calculate nice scale intervals
    final interval = _calculateYAxisInterval(maxValue);
    final maxYValue = ((maxValue / interval).ceil() * interval).toInt();
    final yAxisLabels = <int>[];
    for (int i = 0; i <= maxYValue; i += interval) {
      yAxisLabels.add(i);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 40),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  width: yAxisWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yAxisLabels.reversed.map((value) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Chart bars
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(5, (index) {
                      int week = index + 1;
                      final paidValue = (weeklyData[week]?['paid'] ?? 0) as int;
                      final paidCashValue = (weeklyData[week]?['paidCash'] ?? 0) as int;
                      final unpaidValue = (weeklyData[week]?['unpaid'] ?? 0) as int;

                      final paidHeight = maxYValue > 0 ? (paidValue / maxYValue) * chartHeight : 0.0;
                      final paidCashHeight = maxYValue > 0 ? (paidCashValue / maxYValue) * chartHeight : 0.0;
                      final unpaidHeight = maxYValue > 0 ? (unpaidValue / maxYValue) * chartHeight : 0.0;

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
                                    // Paid Revenue Bar (Green)
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Week $week\nPaid Revenue: ₱$paidValue',
                                        child: Container(
                                          height: paidHeight.clamp(2, chartHeight),
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Cash Received Bar (Orange)
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Week $week\nCash Received: ₱$paidCashValue',
                                        child: Container(
                                          height: paidCashHeight.clamp(2, chartHeight),
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade400,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Unpaid Revenue Bar (Red)
                                    Expanded(
                                      child: Tooltip(
                                        message: 'Week $week\nUnpaid Revenue: ₱$unpaidValue',
                                        child: Container(
                                          height: unpaidHeight.clamp(2, chartHeight),
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade400,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_getWeekDateRange(week), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
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
              _buildLegendItem('Paid Revenue', Colors.green.shade400),
              _buildLegendItem('Cash Received', Colors.orange.shade400),
              _buildLegendItem('Unpaid Revenue', Colors.red.shade400),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Each week shows 3 separate bars for easy comparison',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  int _calculateYAxisInterval(int maxValue) {
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 500;
    if (maxValue <= 10000) return 1000;
    if (maxValue <= 50000) return 5000;
    return 10000;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  int _getMaxValue() {
    int max = 0;
    for (var week in weeklyData.values) {
      int paidValue = (week['paid'] ?? 0) as int;
      int unpaidValue = (week['unpaid'] ?? 0) as int;
      int cashValue = (week['paidCash'] ?? 0) as int;
      
      if (paidValue > max) max = paidValue;
      if (unpaidValue > max) max = unpaidValue;
      if (cashValue > max) max = cashValue;
    }
    return max;
  }

  int _getTotalPaid() {
    int total = 0;
    for (var week in weeklyData.values) {
      total += ((week['paid'] ?? 0) as double).toInt();
    }
    return total;
  }

  int _getTotalUnpaid() {
    int total = 0;
    for (var week in weeklyData.values) {
      total += ((week['unpaid'] ?? 0) as double).toInt();
    }
    return total;
  }

  int _getTotalRevenue() {
    return _getTotalPaid() + _getTotalUnpaid();
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toString();
  }

  Widget _buildWeeklySummaryTable() {
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
          const Text('Weekly Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowHeight: 35,
              dataRowHeight: 30,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              dataTextStyle: const TextStyle(fontSize: 11),
              columns: const [
                DataColumn(label: Text('Week')),
                DataColumn(label: Text('Total'), numeric: true),
                DataColumn(label: Text('Paid'), numeric: true),
                DataColumn(label: Text('Unpaid'), numeric: true),
                DataColumn(label: Text('Cash Received'), numeric: true),
              ],
              rows: List.generate(5, (index) {
                int week = index + 1;
                final paidValue = (weeklyData[week]?['paid'] ?? 0) as int;
                final unpaidValue = (weeklyData[week]?['unpaid'] ?? 0) as int;
                final cashValue = (weeklyData[week]?['paidCash'] ?? 0) as int;
                final totalValue = paidValue + unpaidValue;
                
                return DataRow(
                  cells: [
                    DataCell(Text('Week $week', style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('₱${totalValue.toStringAsFixed(0)}', 
                      style: TextStyle(fontWeight: FontWeight.w600, color: totalValue > 0 ? Colors.blue.shade700 : Colors.grey))),
                    DataCell(Text('₱${paidValue.toStringAsFixed(0)}', 
                      style: TextStyle(color: paidValue > 0 ? Colors.green.shade700 : Colors.grey))),
                    DataCell(Text('₱${unpaidValue.toStringAsFixed(0)}', 
                      style: TextStyle(color: unpaidValue > 0 ? Colors.red.shade700 : Colors.grey))),
                    DataCell(Text('₱${cashValue.toStringAsFixed(0)}', 
                      style: TextStyle(color: cashValue > 0 ? Colors.orange.shade700 : Colors.grey))),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Month Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '₱${_getTotalRevenue().toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidCustomersSummary(bool isMobile) {
    final sortedCustomers = unpaidCustomers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Unpaid Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (completedJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No completed jobs this month', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (sortedCustomers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text('All customers paid!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
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
                  rows: sortedCustomers.take(10).map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(entry.key, style: const TextStyle(fontSize: 12))),
                        DataCell(
                          Text('₱${entry.value}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                          onTap: () {},
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: unpaidCustomers.isEmpty ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Unpaid:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '₱${unpaidCustomers.values.fold(0, (sum, val) => sum + val)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: unpaidCustomers.isEmpty ? Colors.green : Colors.red,
                    ),
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
