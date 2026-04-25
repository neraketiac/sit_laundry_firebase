import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/firebase_options.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

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
  Map<String, int> suppliesData =
      {}; // Funds In, Funds Out, Laundry Payment, Cash In/Load, Cash Out
  int totalLoads = 0;
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
      print(
          'Loading data for: ${DateFormat('MMMM yyyy').format(currentMonth)}');
      print('Date range: $startDate to $endDate');

      // Read Jobs_done from jobsDoneDb
      final jobsDoneDb = FirebaseService.jobsDoneFirestore;

      // Read Jobs_completed from reportsDb
      FirebaseApp thirdApp;
      try {
        thirdApp = Firebase.app('thirdWeb');
      } catch (_) {
        thirdApp = await Firebase.initializeApp(
          name: 'thirdWeb',
          options: DefaultFirebaseOptions.reportsDb,
        );
      }
      final reportsDb = FirebaseFirestore.instanceFor(app: thirdApp);

      // Load from Jobs_done
      final doneSnapshot = await jobsDoneDb
          .collection('Jobs_done')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Load from Jobs_completed
      final completedSnapshot = await reportsDb
          .collection('Jobs_completed')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      print(
          'Found ${doneSnapshot.docs.length} done jobs and ${completedSnapshot.docs.length} completed jobs');

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

      // Load from SuppliesHist
      final suppliesSnapshot = await reportsDb
          .collection('SuppliesHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      print('Found ${suppliesSnapshot.docs.length} supplies records');

      _processSuppliesData(suppliesSnapshot.docs);
      _processWeeklyData();
      _processUnpaidCustomers();
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => isLoading = false);
  }

  void _processWeeklyData() {
    weeklyData.clear();
    totalLoads = 0;

    for (int week = 1; week <= 5; week++) {
      weeklyData[week] = {
        'paid': 0,
        'paidCash': 0,
        'paidGCash': 0,
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
      int paidGCash =
          (job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0;
      int totalPaid = paidCash + paidGCash;
      int unpaidAmount = finalPrice - totalPaid;

      // Sum total loads
      totalLoads += job.finalLoad ?? 0;

      if (unpaidAmount > 0) {
        weeklyData[week]!['unpaid'] += unpaidAmount;
      }

      if (totalPaid > 0) {
        weeklyData[week]!['paid'] += totalPaid;
      }

      if (paidCash > 0) {
        weeklyData[week]!['paidCash'] += paidCash;
      }

      if (paidGCash > 0) {
        weeklyData[week]!['paidGCash'] += paidGCash;
      }
    }
  }

  void _processSuppliesData(List<QueryDocumentSnapshot> docs) {
    suppliesData = {
      'Funds In': 0,
      'Funds Out': 0,
      'Laundry Payment': 0,
      'Cash In/Load': 0,
      'Cash Out': 0,
    };

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      int itemUniqueId = data['ItemUniqueId'] ?? 0;
      int currentCounter = (data['CurrentCounter'] ?? 0) is int
          ? data['CurrentCounter']
          : (data['CurrentCounter'] as double).toInt();

      // Separate Funds In (positive) and Funds Out (negative)
      if (currentCounter > 0) {
        suppliesData['Funds In'] = suppliesData['Funds In']! + currentCounter;
      } else if (currentCounter < 0) {
        suppliesData['Funds Out'] =
            suppliesData['Funds Out']! + currentCounter.abs();
      }

      // Also categorize by ItemUniqueId
      if (itemUniqueId == 4405) {
        suppliesData['Laundry Payment'] =
            suppliesData['Laundry Payment']! + currentCounter;
      } else if (itemUniqueId == 4401 || itemUniqueId == 431) {
        suppliesData['Cash In/Load'] =
            suppliesData['Cash In/Load']! + currentCounter;
      } else if (itemUniqueId == 4402) {
        suppliesData['Cash Out'] = suppliesData['Cash Out']! + currentCounter;
      }
    }
  }

  void _processUnpaidCustomers() {
    unpaidCustomers.clear();

    for (var job in completedJobs) {
      if (job.customerName != null) {
        int finalPrice = job.finalPrice ?? 0;
        int paidCash = (job.paidCashAmount ?? 0);
        int paidGCash =
            (job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0;
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
    });
    _loadMonthlyData();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
    _loadMonthlyData();
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
                  _buildSuppliesSummary(isMobile),
                  const SizedBox(height: 20),
                  _buildSuppliesChart(isMobile),
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

  Widget _buildSuppliesSummary(bool isMobile) {
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
                _buildSuppliesCard(
                    'Funds In', suppliesData['Funds In'] ?? 0, Colors.teal),
                _buildSuppliesCard(
                    'Funds Out', suppliesData['Funds Out'] ?? 0, Colors.orange),
                _buildSuppliesCard('Laundry Payment',
                    suppliesData['Laundry Payment'] ?? 0, Colors.blue),
                _buildSuppliesCard('Cash In/Load',
                    suppliesData['Cash In/Load'] ?? 0, Colors.green),
                _buildSuppliesCard(
                    'Cash Out', suppliesData['Cash Out'] ?? 0, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliesCard(String label, int amount, MaterialColor color) {
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
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.shade800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '₱${_formatCurrency(amount)}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliesChart(bool isMobile) {
    final maxValue = _getMaxSuppliesValue();
    final chartHeight = 180.0;
    final yAxisWidth = 60.0;

    final interval = _calculateYAxisInterval(maxValue);
    final maxYValue = ((maxValue / interval).ceil() * interval).toInt();
    final yAxisLabels = <int>[];
    for (int i = 0; i <= maxYValue; i += interval) {
      yAxisLabels.add(i);
    }

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
                                value >= 1000
                                    ? '${(value / 1000).toStringAsFixed(0)}k'
                                    : value.toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // Chart bars
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildSuppliesBar(
                                'Funds\nIn',
                                suppliesData['Funds In'] ?? 0,
                                Colors.teal,
                                maxYValue,
                                chartHeight),
                            _buildSuppliesBar(
                                'Funds\nOut',
                                suppliesData['Funds Out'] ?? 0,
                                Colors.orange,
                                maxYValue,
                                chartHeight),
                            _buildSuppliesBar(
                                'Laundry\nPayment',
                                suppliesData['Laundry Payment'] ?? 0,
                                Colors.blue,
                                maxYValue,
                                chartHeight),
                            _buildSuppliesBar(
                                'Cash In/\nLoad',
                                suppliesData['Cash In/Load'] ?? 0,
                                Colors.green,
                                maxYValue,
                                chartHeight),
                            _buildSuppliesBar(
                                'Cash\nOut',
                                suppliesData['Cash Out'] ?? 0,
                                Colors.red,
                                maxYValue,
                                chartHeight),
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

  Widget _buildSuppliesBar(String label, int value, MaterialColor color,
      int maxYValue, double chartHeight) {
    final barHeight = maxYValue > 0 ? (value / maxYValue) * chartHeight : 0.0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: '$label: ₱${_formatCurrency(value)}',
              child: Container(
                height: barHeight.clamp(2, chartHeight),
                decoration: BoxDecoration(
                  color: color.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getMaxSuppliesValue() {
    int max = 0;
    for (var value in suppliesData.values) {
      if (value > max) max = value;
    }
    return max;
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
                const Text('Weekly Revenue',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$totalLoads loads, ${completedJobs.length} jobs',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                      Text('Total Revenue:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800)),
                      Text(
                        '₱${_formatCurrency(_getTotalRevenue())}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('Paid',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade700)),
                              Text('₱${_formatCurrency(_getTotalPaid())}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('Cash',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700)),
                              Text('₱${_formatCurrency(_getTotalPaidCash())}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('GCash',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple.shade700)),
                              Text('₱${_formatCurrency(_getTotalPaidGCash())}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Text('Unpaid',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red.shade700)),
                              Text('₱${_formatCurrency(_getTotalUnpaid())}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade800)),
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
                      child: _buildChartContent(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width - 40
                          : null,
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
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(0)}k'
                              : value.toString(),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
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
                      final paidCashValue =
                          (weeklyData[week]?['paidCash'] ?? 0) as int;
                      final paidGCashValue =
                          (weeklyData[week]?['paidGCash'] ?? 0) as int;
                      final unpaidValue =
                          (weeklyData[week]?['unpaid'] ?? 0) as int;

                      final paidHeight = maxYValue > 0
                          ? (paidValue / maxYValue) * chartHeight
                          : 0.0;
                      final paidCashHeight = maxYValue > 0
                          ? (paidCashValue / maxYValue) * chartHeight
                          : 0.0;
                      final paidGCashHeight = maxYValue > 0
                          ? (paidGCashValue / maxYValue) * chartHeight
                          : 0.0;
                      final unpaidHeight = maxYValue > 0
                          ? (unpaidValue / maxYValue) * chartHeight
                          : 0.0;

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
                                        message:
                                            'Week $week\nPaid Revenue: ₱${_formatCurrency(paidValue)}',
                                        child: Container(
                                          height:
                                              paidHeight.clamp(2, chartHeight),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Cash Received Bar (Blue)
                                    Expanded(
                                      child: Tooltip(
                                        message:
                                            'Week $week\nCash Received: ₱${_formatCurrency(paidCashValue)}',
                                        child: Container(
                                          height: paidCashHeight.clamp(
                                              2, chartHeight),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade400,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // GCash Received Bar (Purple)
                                    Expanded(
                                      child: Tooltip(
                                        message:
                                            'Week $week\nGCash Received: ₱${_formatCurrency(paidGCashValue)}',
                                        child: Container(
                                          height: paidGCashHeight.clamp(
                                              2, chartHeight),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade400,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Unpaid Revenue Bar (Red)
                                    Expanded(
                                      child: Tooltip(
                                        message:
                                            'Week $week\nUnpaid Revenue: ₱${_formatCurrency(unpaidValue)}',
                                        child: Container(
                                          height: unpaidHeight.clamp(
                                              2, chartHeight),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade400,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(_getWeekDateRange(week),
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
              _buildLegendItem('Paid Revenue', Colors.green.shade400),
              _buildLegendItem('Cash Received', Colors.blue.shade400),
              _buildLegendItem('GCash Received', Colors.purple.shade400),
              _buildLegendItem('Unpaid Revenue', Colors.red.shade400),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Each week shows 4 separate bars for easy comparison',
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic),
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
      int gcashValue = (week['paidGCash'] ?? 0) as int;

      if (paidValue > max) max = paidValue;
      if (unpaidValue > max) max = unpaidValue;
      if (cashValue > max) max = cashValue;
      if (gcashValue > max) max = gcashValue;
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

  int _getTotalPaidCash() {
    int total = 0;
    for (var week in weeklyData.values) {
      total += ((week['paidCash'] ?? 0) as double).toInt();
    }
    return total;
  }

  int _getTotalPaidGCash() {
    int total = 0;
    for (var week in weeklyData.values) {
      total += ((week['paidGCash'] ?? 0) as double).toInt();
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
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
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
          const Text('Weekly Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
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
              rows: List.generate(5, (index) {
                int week = index + 1;
                final paidValue = (weeklyData[week]?['paid'] ?? 0) as int;
                final cashValue = (weeklyData[week]?['paidCash'] ?? 0) as int;
                final gcashValue = (weeklyData[week]?['paidGCash'] ?? 0) as int;
                final unpaidValue = (weeklyData[week]?['unpaid'] ?? 0) as int;
                final totalValue = paidValue + unpaidValue;

                return DataRow(
                  cells: [
                    DataCell(Text('Week $week',
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('₱${_formatCurrency(totalValue)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: totalValue > 0
                                ? Colors.blue.shade700
                                : Colors.grey))),
                    DataCell(Text('₱${_formatCurrency(paidValue)}',
                        style: TextStyle(
                            color: paidValue > 0
                                ? Colors.green.shade700
                                : Colors.grey))),
                    DataCell(Text('₱${_formatCurrency(cashValue)}',
                        style: TextStyle(
                            color: cashValue > 0
                                ? Colors.blue.shade700
                                : Colors.grey))),
                    DataCell(Text('₱${_formatCurrency(gcashValue)}',
                        style: TextStyle(
                            color: gcashValue > 0
                                ? Colors.purple.shade700
                                : Colors.grey))),
                    DataCell(Text('₱${_formatCurrency(unpaidValue)}',
                        style: TextStyle(
                            color: unpaidValue > 0
                                ? Colors.red.shade700
                                : Colors.grey))),
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
              const Text('Month Total:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '₱${_formatCurrency(_getTotalRevenue())}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue),
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
            const Text('Top Unpaid Customers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (completedJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No completed jobs this month',
                          style: TextStyle(color: Colors.grey)),
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
                      Icon(Icons.check_circle_outline,
                          size: 48, color: Colors.green),
                      SizedBox(height: 8),
                      Text('All customers paid!',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
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
                        DataCell(Text(entry.key,
                            style: const TextStyle(fontSize: 12))),
                        DataCell(
                          Text('₱${_formatCurrency(entry.value)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red)),
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
                color: unpaidCustomers.isEmpty
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Unpaid:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '₱${_formatCurrency(unpaidCustomers.values.fold(0, (sum, val) => sum + val))}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          unpaidCustomers.isEmpty ? Colors.green : Colors.red,
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
