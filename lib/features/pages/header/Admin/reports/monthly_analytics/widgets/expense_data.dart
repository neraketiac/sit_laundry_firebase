import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes expense data.
///
/// ItemsHist:    no expense field — skipped
/// EmployeeHist: ItemUniqueId=4406, EmpId != '#1919'
///               amount = CurrentCounter (always treated as positive expense)
class ExpenseData {
  int totalExpense = 0;

  /// expense per week (1–5)
  final Map<int, int> byWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  void process(
    List<QueryDocumentSnapshot> itemsDocs, // kept for signature compat, unused
    List<QueryDocumentSnapshot> empDocs,
    int Function(DateTime) weekNumber,
  ) {
    totalExpense = 0;
    for (int w = 1; w <= 5; w++) {
      byWeek[w] = 0;
    }

    // EmployeeHist — ItemUniqueId=4406 already filtered in query
    // skip EmpId '#1919', use CurrentCounter as the expense amount
    for (final doc in empDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['EmpId']?.toString() ?? '') == '#1919') continue;

      final raw = data['CurrentCounter'];
      if (raw == null) continue;
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0).abs();
      if (amount == 0) continue;

      totalExpense += amount;

      final ts = data['LogDate'] as Timestamp?;
      if (ts != null) {
        final w = weekNumber(ts.toDate());
        byWeek[w] = (byWeek[w] ?? 0) + amount;
      }
    }
  }
}
