import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes salary payment data from EmployeeHist
/// where ItemUniqueId = 4406 (menuOthSalaryPayment)
class SalaryData {
  int totalSalary = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  final Map<int, int> byWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  final Map<String, int> byEmployee = {};
  final Map<int, Map<String, int>> employeeByWeek = {
    1: {},
    2: {},
    3: {},
    4: {},
    5: {},
  };

  void process(
    List<QueryDocumentSnapshot> empDocs,
    int? Function(DateTime) weekNumber, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    totalSalary = 0;
    for (int w = 1; w <= 5; w++) {
      byWeek[w] = 0;
      employeeByWeek[w] = {};
    }
    byEmployee.clear();

    for (final doc in empDocs) {
      final data = doc.data() as Map<String, dynamic>;

      final raw = data['CurrentCounter'];
      if (raw == null) continue;
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0).abs();
      if (amount == 0) continue;

      final label = (data['EmpName']?.toString().trim().isNotEmpty == true
                  ? data['EmpName']
                  : data['EmpId'])
              ?.toString() ??
          'Unknown';

      final autoTs = data['AutoSalaryDate'] as Timestamp?;
      final logTs = data['LogDate'] as Timestamp?;

      // For LogDate >= May 1, 2026: use only AutoSalaryDate
      // For LogDate < May 1, 2026: use AutoSalaryDate if in month, else LogDate
      final cutoffDate = DateTime(2026, 5, 1);
      final logDate = logTs?.toDate();

      Timestamp? ts;
      if (logDate != null && logDate.isAfter(cutoffDate) ||
          logDate?.isAtSameMomentAs(cutoffDate) == true) {
        // LogDate >= May 1, 2026: use only AutoSalaryDate
        ts = autoTs;
      } else {
        // LogDate < May 1, 2026: use AutoSalaryDate if in month, else LogDate
        if (autoTs != null && _isInMonth(autoTs.toDate())) {
          ts = autoTs;
        } else {
          ts = logTs;
        }
      }

      if (ts != null) {
        final w = weekNumber(ts.toDate());

        // Only add to totals and weeks if it's a valid week number (dates in current month)
        if (w != null) {
          totalSalary += amount;
          byEmployee[label] = (byEmployee[label] ?? 0) + amount;

          byWeek[w] = (byWeek[w] ?? 0) + amount;
          final wMap = employeeByWeek[w] ??= {};
          wMap[label] = (wMap[label] ?? 0) + amount;
        }
      }
    }
  }

  bool _isInMonth(DateTime date) {
    if (_startDate == null || _endDate == null) return true;
    return !date.isBefore(_startDate!) && !date.isAfter(_endDate!);
  }
}
