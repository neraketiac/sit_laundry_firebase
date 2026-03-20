import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/firebase_options.dart';
import 'widgets/month_selector.dart';
import 'widgets/supplies_summary_card.dart';
import 'widgets/supplies_chart.dart';
import 'widgets/weekly_revenue_chart.dart';
import 'widgets/unpaid_customers_card.dart';

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
  Map<String, int> suppliesData = {};
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
      FirebaseApp thirdApp;
      try {
        thirdApp = Firebase.app('thirdWeb');
      } catch (_) {
        thirdApp = await Firebase.initializeApp(
          name: 'thirdWeb',
          options: DefaultFirebaseOptions.thirdWeb,
        );
      }
      final db = FirebaseFirestore.instanceFor(app: thirdApp);

      final doneSnap = await db
          .collection('Jobs_done')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final completedSnap = await db
          .collection('Jobs_completed')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      completedJobs = [
        ...doneSnap.docs.map((doc) {
          final r = JobModelRepository();
          r.setJobModel(JobModel.fromFirestore(doc.data(), doc.id));
          return r;
        }),
        ...completedSnap.docs.map((doc) {
          final r = JobModelRepository();
          r.setJobModel(JobModel.fromFirestore(doc.data(), doc.id));
          return r;
        }),
      ];

      final suppliesSnap = await db
          .collection('SuppliesHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      _processSuppliesData(suppliesSnap.docs);
      _processWeeklyData();
      _processUnpaidCustomers();
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
    }

    setState(() => isLoading = false);
  }

  void _processWeeklyData() {
    weeklyData = {
      for (int w = 1; w <= 5; w++)
        w: {'paid': 0, 'paidCash': 0, 'paidGCash': 0, 'unpaid': 0}
    };
    totalLoads = 0;

    for (var job in completedJobs) {
      if (job.dateD == null) continue;
      final jobDate = job.dateD is Timestamp
          ? (job.dateD as Timestamp).toDate()
          : job.dateD as DateTime;
      final week = _weekNumber(jobDate);

      final finalPrice = job.finalPrice ?? 0;
      final paidCash = job.paidCashAmount ?? 0;
      final paidGCash =
          (job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0;
      final totalPaid = paidCash + paidGCash;
      final unpaid = finalPrice - totalPaid;

      totalLoads += job.finalLoad ?? 0;
      if (totalPaid > 0) weeklyData[week]!['paid'] += totalPaid;
      if (paidCash > 0) weeklyData[week]!['paidCash'] += paidCash;
      if (paidGCash > 0) weeklyData[week]!['paidGCash'] += paidGCash;
      if (unpaid > 0) weeklyData[week]!['unpaid'] += unpaid;
    }
  }

  void _processSuppliesData(List<QueryDocumentSnapshot> docs) {
    suppliesData = {
      'Funds In': 0,
      'Funds Out': 0,
      'Laundry Payment': 0,
      'Cash In/Load': 0,
      'Cash Out': 0
    };

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final itemId = data['ItemUniqueId'] ?? 0;
      final counter = (data['CurrentCounter'] ?? 0) is int
          ? data['CurrentCounter'] as int
          : (data['CurrentCounter'] as double).toInt();

      if (counter > 0)
        suppliesData['Funds In'] = suppliesData['Funds In']! + counter;
      if (counter < 0)
        suppliesData['Funds Out'] = suppliesData['Funds Out']! + counter.abs();
      if (itemId == 4405)
        suppliesData['Laundry Payment'] =
            suppliesData['Laundry Payment']! + counter;
      if (itemId == 4401 || itemId == 431)
        suppliesData['Cash In/Load'] = suppliesData['Cash In/Load']! + counter;
      if (itemId == 4402)
        suppliesData['Cash Out'] = suppliesData['Cash Out']! + counter;
    }
  }

  void _processUnpaidCustomers() {
    unpaidCustomers.clear();
    for (var job in completedJobs) {
      if (job.customerName == null) continue;
      final unpaid = (job.finalPrice ?? 0) -
          (job.paidCashAmount ?? 0) -
          ((job.paidGCashVerified ?? false) ? (job.paidGCashAmount ?? 0) : 0);
      if (unpaid > 0) {
        unpaidCustomers[job.customerName!] =
            (unpaidCustomers[job.customerName!] ?? 0) + unpaid;
      }
    }
  }

  int _weekNumber(DateTime date) {
    if (date.day <= 7) return 1;
    if (date.day <= 14) return 2;
    if (date.day <= 21) return 3;
    if (date.day <= 28) return 4;
    return 5;
  }

  String _weekDateRange(int week) {
    final startDay = (week - 1) * 7 + 1;
    final endDay = week == 5
        ? DateTime(currentMonth.year, currentMonth.month + 1, 0).day
        : week * 7;
    return '${DateFormat('MMM').format(currentMonth)}$startDay-$endDay';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Analytics'), elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  MonthSelector(
                    currentMonth: currentMonth,
                    onPrevious: () => setState(() {
                      currentMonth =
                          DateTime(currentMonth.year, currentMonth.month - 1);
                      _loadMonthlyData();
                    }),
                    onNext: () => setState(() {
                      currentMonth =
                          DateTime(currentMonth.year, currentMonth.month + 1);
                      _loadMonthlyData();
                    }),
                  ),
                  const SizedBox(height: 20),
                  SuppliesSummaryCard(
                      suppliesData: suppliesData, isMobile: isMobile),
                  const SizedBox(height: 20),
                  SuppliesChart(suppliesData: suppliesData, isMobile: isMobile),
                  const SizedBox(height: 20),
                  WeeklyRevenueChart(
                    weeklyData: weeklyData,
                    totalLoads: totalLoads,
                    totalJobs: completedJobs.length,
                    isMobile: isMobile,
                    getWeekDateRange: _weekDateRange,
                  ),
                  const SizedBox(height: 30),
                  UnpaidCustomersCard(
                    unpaidCustomers: unpaidCustomers,
                    currentMonth: currentMonth,
                    hasJobs: completedJobs.isNotEmpty,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
