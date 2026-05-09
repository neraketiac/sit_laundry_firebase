import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes expense data from two sources:
///
/// 1. ItemsHist   — docs that have an 'ExpenseAmount' field (item purchases)
///                  label = ItemName
///
/// 2. EmployeeHist — ItemUniqueId=4406, EmpId != '#1919' (salary payments)
///                  amount = CurrentCounter
///                  label = EmpName (fallback EmpId)
class ExpenseData {
  int totalExpense = 0;

  /// Total expense per week (1–5) — all sources
  final Map<int, int> byWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  /// Total expense per label (employee name or item name) — all sources
  final Map<String, int> byEmployee = {};

  /// Expense per label per week — all sources
  final Map<int, Map<String, int>> employeeByWeek = {
    1: {},
    2: {},
    3: {},
    4: {},
    5: {},
  };

  /// Employee-only expense (EmployeeHist portion only — for SalaryCard comparison)
  final Map<String, int> empOnlyByEmployee = {};
  final Map<int, Map<String, int>> empOnlyByWeek = {
    1: {},
    2: {},
    3: {},
    4: {},
    5: {},
  };

  void process(
    List<QueryDocumentSnapshot> itemsDocs,
    List<QueryDocumentSnapshot> empDocs,
    int Function(DateTime) weekNumber,
  ) {
    totalExpense = 0;
    for (int w = 1; w <= 5; w++) {
      byWeek[w] = 0;
      employeeByWeek[w] = {};
      empOnlyByWeek[w] = {};
    }
    byEmployee.clear();
    empOnlyByEmployee.clear();

    // ── ItemsHist: docs with ExpenseAmount ────────────────────────────────
    for (final doc in itemsDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('ExpenseAmount')) continue;

      final raw = data['ExpenseAmount'];
      if (raw == null) continue;
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0);
      if (amount == 0) continue;

      final label = (data['ItemName']?.toString().trim().isNotEmpty == true
              ? data['ItemName']
              : 'Item')
          .toString();

      _add(label, amount, data['LogDate'] as Timestamp?, weekNumber);
    }

    // ── EmployeeHist: ItemUniqueId=4406, skip EmpId '#1919' ───────────────
    for (final doc in empDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final empId = data['EmpId']?.toString() ?? '';

      final raw = data['CurrentCounter'];
      if (raw == null) continue;
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0);
      if (amount == 0) continue;

      final label = (data['EmpName']?.toString().trim().isNotEmpty == true
                  ? data['EmpName']
                  : data['EmpId'])
              ?.toString() ??
          'Unknown';

      final ts = (data['AutoSalaryDate'] ?? data['LogDate']) as Timestamp?;

      // Skip Lorie (#1919) from Top Expense display
      if (empId != '#1919') {
        _add(label, amount, ts, weekNumber);
      }

      // Always track employee-only for SalaryCard comparison (including Lorie)
      empOnlyByEmployee[label] = (empOnlyByEmployee[label] ?? 0) + amount;
      if (ts != null) {
        final w = weekNumber(ts.toDate());
        final wMap = empOnlyByWeek[w] ??= {};
        wMap[label] = (wMap[label] ?? 0) + amount;
      }
    }
  }

  void _add(
    String label,
    int amount,
    Timestamp? ts,
    int Function(DateTime) weekNumber,
  ) {
    totalExpense += amount;
    byEmployee[label] = (byEmployee[label] ?? 0) + amount;

    if (ts != null) {
      final w = weekNumber(ts.toDate());
      byWeek[w] = (byWeek[w] ?? 0) + amount;
      final wMap = employeeByWeek[w] ??= {};
      wMap[label] = (wMap[label] ?? 0) + amount;
    }
  }
}
