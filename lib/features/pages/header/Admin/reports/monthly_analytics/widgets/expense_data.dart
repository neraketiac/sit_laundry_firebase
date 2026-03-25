import 'package:cloud_firestore/cloud_firestore.dart';

/// Processes expense data from ItemsHist and EmployeeHist.
///
/// ItemsHist: any doc with ExpenseAmount field
/// EmployeeHist: ItemUniqueId=4406, EmpId != '#1919'
///
/// All amounts treated as negative (expense), stored as positive int.
class ExpenseData {
  int totalExpense = 0;

  /// expense per week (1–5)
  final Map<int, int> byWeek = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  void process(
    List<QueryDocumentSnapshot> itemsDocs,
    List<QueryDocumentSnapshot> empDocs,
    int Function(DateTime) weekNumber,
  ) {
    totalExpense = 0;
    for (int w = 1; w <= 5; w++) byWeek[w] = 0;

    void add(Map<String, dynamic> data) {
      final raw = data['ExpenseAmount'];
      if (raw == null) return;
      final amount =
          (raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0).abs();
      if (amount == 0) return;
      totalExpense += amount;
      final ts = data['LogDate'] as Timestamp?;
      if (ts != null) {
        final w = weekNumber(ts.toDate());
        byWeek[w] = (byWeek[w] ?? 0) + amount;
      }
    }

    // ItemsHist — only docs that have ExpenseAmount
    for (final doc in itemsDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('ExpenseAmount')) continue;
      add(data);
    }

    // EmployeeHist — ItemUniqueId=4406 already filtered in query; skip EmpId #1919
    for (final doc in empDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['EmpId']?.toString() ?? '') == '#1919') continue;
      add(data);
    }
  }
}
