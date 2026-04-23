import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseClosingCheck {
  final _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getHistory() async {
    final snap = await _db
        .collection('closing_check_history')
        .orderBy('logDate', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<void> save({
    required bool lpg,
    required bool fuse,
    required bool fundCheck,
    required bool inventory,
    required bool schedule,
    required String empId,
    required String empName,
  }) async {
    await _db.collection('closing_check_history').add({
      'lpg': lpg,
      'fuse': fuse,
      'fundCheck': fundCheck,
      'inventory': inventory,
      'schedule': schedule,
      'empId': empId,
      'empName': empName,
      'logDate': FieldValue.serverTimestamp(),
    });
  }
}
