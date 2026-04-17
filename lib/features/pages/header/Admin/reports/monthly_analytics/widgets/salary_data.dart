import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes salary payment data from EmployeeHist
/// where ItemUniqueId = 4406 (menuOthSalaryPayment)
class SalaryData {
  int totalSalary = 0;

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
    int Function(DateTime) weekNumber,
  ) {
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
      // Salary payments are negative (funds out) — take abs
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0).abs();
      if (amount == 0) continue;

      final label = (data['EmpName']?.toString().trim().isNotEmpty == true
                  ? data['EmpName']
                  : data['EmpId'])
              ?.toString() ??
          'Unknown';

      // Use AutoSalaryDate if available, fall back to LogDate
      final ts = (data['AutoSalaryDate'] ?? data['LogDate']) as Timestamp?;

      totalSalary += amount;
      byEmployee[label] = (byEmployee[label] ?? 0) + amount;

      if (ts != null) {
        final w = weekNumber(ts.toDate());
        byWeek[w] = (byWeek[w] ?? 0) + amount;
        final wMap = employeeByWeek[w] ??= {};
        wMap[label] = (wMap[label] ?? 0) + amount;
      }
    }
  }
}
