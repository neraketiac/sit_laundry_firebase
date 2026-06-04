import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

/// Processes weekly revenue data from completed jobs.
/// Excludes jobs where customer is staff: Rowell, Lorie, Seiji, Analyn, Ket, DonF
class WeeklyData {
  /// Keys per week: paid, paidCash, paidGCash, unpaid, expense
  final Map<int, Map<String, int>> data = {
    for (int w = 1; w <= 5; w++)
      w: {'paid': 0, 'paidCash': 0, 'paidGCash': 0, 'unpaid': 0, 'expense': 0}
  };

  int totalLoads = 0;

  // Staff customer names to exclude from load calculations
  static const Set<String> _staffCustomerNames = {
    'Rowell',
    'Lorie',
    'Seiji',
    'Analyn',
    'Ket',
    'DonF'
  };

  void process(
    List<JobModelRepository> jobs,
    int Function(DateTime) weekNumber,
  ) {
    for (int w = 1; w <= 5; w++) {
      data[w] = {
        'paid': 0,
        'paidCash': 0,
        'paidGCash': 0,
        'unpaid': 0,
        'expense': 0
      };
    }
    totalLoads = 0;

    for (final job in jobs) {
      final week = weekNumber(job.dateD.toDate());
      final paidCash = job.paidCashAmount;
      final paidGCash = job.paidGCashVerified ? job.paidGCashAmount : 0;
      final totalPaid = paidCash + paidGCash;
      final unpaid = job.finalPrice - totalPaid;

      // Only count loads if customer is not staff
      if (!_staffCustomerNames.contains(job.customerName)) {
        totalLoads += job.finalLoad;
      }

      if (totalPaid > 0) {
        data[week]!['paid'] = data[week]!['paid']! + totalPaid;
      }
      if (paidCash > 0) {
        data[week]!['paidCash'] = data[week]!['paidCash']! + paidCash;
      }
      if (paidGCash > 0) {
        data[week]!['paidGCash'] = data[week]!['paidGCash']! + paidGCash;
      }
      if (unpaid > 0) {
        data[week]!['unpaid'] = data[week]!['unpaid']! + unpaid;
      }
    }
  }

  /// Merge expense amounts (from ExpenseData.byWeek) into the data map
  void mergeExpense(Map<int, int> expenseByWeek) {
    for (int w = 1; w <= 5; w++) {
      data[w]!['expense'] = expenseByWeek[w] ?? 0;
    }
  }
}
