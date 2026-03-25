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
import 'widgets/expense_data.dart';
import 'widgets/unpaid_data.dart';
import 'widgets/weekly_data.dart';
import 'widgets/supplies_data.dart';

class MonthlyAnalyticsPage extends StatefulWidget {
  const MonthlyAnalyticsPage({super.key});

  @override
  State<MonthlyAnalyticsPage> createState() => _MonthlyAnalyticsPageState();
}

class _MonthlyAnalyticsPageState extends State<MonthlyAnalyticsPage> {
  late DateTime currentMonth;
  List<JobModelRepository> completedJobs = [];

  final _weekly = WeeklyData();
  final _unpaid = UnpaidData();
  final _expense = ExpenseData();
  final _supplies = SuppliesData();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonthlyData();
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

      // Jobs
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

      // Supplies
      final suppliesSnap = await db
          .collection('SuppliesHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // ItemsHist expense
      final itemsHistSnap = await db
          .collection('ItemsHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // EmployeeHist expense (ItemUniqueId=4406 filtered server-side)
      final empHistSnap = await db
          .collection('EmployeeHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('ItemUniqueId', isEqualTo: 4406)
          .get();

      // Process
      _supplies.process(suppliesSnap.docs);
      _expense.process(itemsHistSnap.docs, empHistSnap.docs, _weekNumber);
      _weekly.process(completedJobs, _weekNumber);
      _weekly.mergeExpense(_expense.byWeek);
      _unpaid.process(completedJobs, _weekNumber);
    } catch (e) {
      debugPrint('Error loading monthly data: $e');
    }

    setState(() => isLoading = false);
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
                      suppliesData: _supplies.data, isMobile: isMobile),
                  const SizedBox(height: 20),
                  SuppliesChart(
                      suppliesData: _supplies.data, isMobile: isMobile),
                  const SizedBox(height: 20),
                  WeeklyRevenueChart(
                    weeklyData: _weekly.data,
                    totalLoads: _weekly.totalLoads,
                    totalJobs: completedJobs.length,
                    totalExpense: _expense.totalExpense,
                    isMobile: isMobile,
                    getWeekDateRange: _weekDateRange,
                  ),
                  const SizedBox(height: 30),
                  UnpaidCustomersCard(
                    unpaidCustomers: _unpaid.byCustomer,
                    unpaidByWeek: _unpaid.byWeek,
                    unpaidCustomersByWeek: _unpaid.customersByWeek,
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
