import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/firebase_options.dart';
import 'package:laundry_firebase/features/pages/header/Admin/reports/monthly_analytics/widgets/unpaid_customers_card.dart';
import 'package:laundry_firebase/features/pages/header/Admin/reports/monthly_analytics/widgets/unpaid_data.dart';

Widget readUnpaidLaundry() => const _UnpaidLaundryPanel();

class _UnpaidLaundryPanel extends StatefulWidget {
  const _UnpaidLaundryPanel();

  @override
  State<_UnpaidLaundryPanel> createState() => _UnpaidLaundryPanelState();
}

class _UnpaidLaundryPanelState extends State<_UnpaidLaundryPanel> {
  late DateTime _month;
  final _unpaid = UnpaidData();
  List<JobModelRepository> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _load();
  }

  int _weekNumber(DateTime date) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final firstDow = firstDay.weekday % 7; // Sun=0 … Sat=6
    final week1End = firstDow == 0 ? 1 : 7 - firstDow + 1;
    if (date.day <= week1End) return 1;
    final remaining = date.day - week1End - 1;
    return 2 + (remaining ~/ 7);
  }

  String _weekDateRange(int week) {
    final firstDay = DateTime(_month.year, _month.month, 1);
    final firstDow = firstDay.weekday % 7; // Sun=0 … Sat=6
    final week1End = firstDow == 0 ? 1 : 7 - firstDow + 1;
    final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
    final mon = DateFormat('MMM').format(_month);

    if (week == 1) return '$mon 1-$week1End';
    final start = week1End + (week - 2) * 7 + 1;
    final end = (start + 6).clamp(start, lastDay);
    return '$mon $start-$end';
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final start = DateTime(_month.year, _month.month, 1);
    final end = DateTime(_month.year, _month.month + 1, 0);

    try {
      FirebaseApp thirdApp;
      try {
        thirdApp = Firebase.app('thirdWeb');
      } catch (_) {
        thirdApp = await Firebase.initializeApp(
          name: 'thirdWeb',
          options: DefaultFirebaseOptions.reportsDb,
        );
      }
      final db = FirebaseFirestore.instanceFor(app: thirdApp);

      final doneSnap = await db
          .collection('Jobs_done')
          .where('A05_DateD', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final completedSnap = await db
          .collection('Jobs_completed')
          .where('A05_DateD', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('A05_DateD', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      _jobs = [
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

      _unpaid.process(_jobs, _weekNumber);
    } catch (e) {
      debugPrint('Error loading unpaid data: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(
                      () => _month = DateTime(_month.year, _month.month - 1));
                  _load();
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(
                      () => _month = DateTime(_month.year, _month.month + 1));
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else
            UnpaidCustomersCard(
              unpaidCustomers: _unpaid.byCustomer,
              unpaidByWeek: _unpaid.byWeek,
              unpaidCustomersByWeek: _unpaid.customersByWeek,
              currentMonth: _month,
              hasJobs: _jobs.isNotEmpty,
              getWeekDateRange: _weekDateRange,
            ),
        ],
      ),
    );
  }
}
