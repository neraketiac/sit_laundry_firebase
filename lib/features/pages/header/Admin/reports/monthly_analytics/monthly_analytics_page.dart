import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'widgets/month_selector.dart';
import 'widgets/supplies_summary_card.dart';
import 'widgets/supplies_chart.dart';
import 'widgets/supplies_detail_card.dart';
import 'widgets/weekly_revenue_chart.dart';
import 'widgets/unpaid_customers_card.dart';
import 'widgets/top_expense_card.dart';
import 'widgets/expense_data.dart';
import 'widgets/salary_data.dart';
import 'widgets/salary_card.dart';
import 'widgets/unpaid_data.dart';
import 'widgets/weekly_data.dart';
import 'widgets/supplies_data.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/monthly_loads_calendar.dart';

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
  final _salary = SalaryData();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonthlyData();
  }

  /// Calendar weeks: Week 1 = day 1 to first Saturday, then Sun–Sat blocks.
  int _weekNumber(DateTime date) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    // Mon=1..Sun=7 → convert to Sun=0..Sat=6
    final firstDow = firstDay.weekday % 7;
    // days until (and including) first Saturday
    final daysToSat = (6 - firstDow) % 7;
    final week1End =
        1 + daysToSat; // e.g. Apr 2026: Wed→firstDow=3, daysToSat=3, week1End=4
    if (date.day <= week1End) return 1;
    final remaining = date.day - week1End - 1;
    return 2 + (remaining ~/ 7);
  }

  String _weekDateRange(int week) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstDow = firstDay.weekday % 7;
    final daysToSat = (6 - firstDow) % 7;
    final week1End = 1 + daysToSat;
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final mon = DateFormat('MMM').format(currentMonth);

    if (week == 1) return '$mon 1-$week1End';
    final start = week1End + (week - 2) * 7 + 1;
    final end = (start + 6).clamp(start, lastDay);
    return '$mon $start-$end';
  }

  Future<void> _loadMonthlyData() async {
    setState(() => isLoading = true);

    final startDate = DateTime(currentMonth.year, currentMonth.month, 1);
    final endDate = DateTime(currentMonth.year, currentMonth.month + 1, 1)
        .subtract(const Duration(seconds: 1)); // last second of the month

    try {
      // Jobs_done from jobsDoneDb
      final doneSnap = await FirebaseService.jobsDoneFirestore
          .collection('Jobs_done')
          .where('A05_DateD',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Jobs_completed from primary DB (not in migration list)
      final completedSnap = await FirebaseFirestore.instance
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

      // SuppliesHist from suppliesDB
      final suppliesSnap = await FirebaseService.suppliesFirestore
          .collection('SuppliesHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // ItemsHist from primary DB (not in migration list)
      final itemsHistSnap = await FirebaseFirestore.instance
          .collection('ItemsHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // EmployeeHist from employeeDB — two queries (4404 + 4401), merged
      final empHist4404 = await FirebaseService.employeeFirestore
          .collection('EmployeeHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('ItemUniqueId', isEqualTo: 4404) // funds out
          .get();

      final empHist4401 = await FirebaseService.employeeFirestore
          .collection('EmployeeHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('ItemUniqueId', isEqualTo: 4401) // cash in
          .get();

      final empHistDocs = [...empHist4404.docs, ...empHist4401.docs];

      // Process
      _supplies.process(suppliesSnap.docs);
      _expense.process(itemsHistSnap.docs, empHistDocs, _weekNumber);
      _weekly.process(completedJobs, _weekNumber);
      _weekly.mergeExpense(_expense.byWeek);
      _unpaid.process(completedJobs, _weekNumber);

      // Salary payments (ItemUniqueId = 4406) from employeeDB
      final salarySnap = await FirebaseService.employeeFirestore
          .collection('EmployeeHist')
          .where('LogDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('LogDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('ItemUniqueId', isEqualTo: 4406)
          .get();
      _salary.process(salarySnap.docs, _weekNumber,
          startDate: startDate, endDate: endDate);
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
                  const SizedBox(height: 12),
                  SuppliesDetailCard(byItemName: _supplies.byItemName),
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
                    getWeekDateRange: _weekDateRange,
                  ),
                  const SizedBox(height: 20),
                  TopExpenseCard(
                    expenseByEmployee: _expense.byEmployee,
                    expenseByWeek: _expense.byWeek,
                    employeeByWeek: _expense.employeeByWeek,
                    currentMonth: currentMonth,
                    getWeekDateRange: _weekDateRange,
                  ),
                  const SizedBox(height: 20),
                  SalaryCard(
                    salaryByEmployee: _salary.byEmployee,
                    salaryByWeek: _salary.byWeek,
                    salaryEmployeeByWeek: _salary.employeeByWeek,
                    expenseByEmployee: _expense.empOnlyByEmployee,
                    expenseEmployeeByWeek: _expense.empOnlyByWeek,
                    currentMonth: currentMonth,
                    getWeekDateRange: _weekDateRange,
                  ),
                  const SizedBox(height: 20),
                  MonthlyLoadsCalendar(currentMonth: currentMonth),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
