import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

/// Processes unpaid customer data from completed jobs.
class UnpaidData {
  /// Total unpaid per customer name (all weeks)
  final Map<String, int> byCustomer = {};

  /// Total unpaid amount per week (1–5)
  final Map<int, int> byWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  /// Unpaid per customer per week
  final Map<int, Map<String, int>> customersByWeek = {
    1: {},
    2: {},
    3: {},
    4: {},
    5: {},
  };

  void process(
    List<JobModelRepository> jobs,
    int Function(DateTime) weekNumber,
  ) {
    byCustomer.clear();
    for (int w = 1; w <= 5; w++) {
      byWeek[w] = 0;
      customersByWeek[w] = {};
    }

    for (final job in jobs) {
      final name = job.customerName;
      if (name.isEmpty) continue;
      final unpaid = job.finalPrice -
          job.paidCashAmount -
          (job.paidGCashVerified ? job.paidGCashAmount : 0);
      if (unpaid <= 0) continue;

      byCustomer[name] = (byCustomer[name] ?? 0) + unpaid;

      final week = weekNumber(job.dateD.toDate());
      byWeek[week] = (byWeek[week] ?? 0) + unpaid;
      final weekMap = customersByWeek[week] ??= {};
      weekMap[name] = (weekMap[name] ?? 0) + unpaid;
    }
  }
}
