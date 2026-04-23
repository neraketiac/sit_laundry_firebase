import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/employees/models/coveragerecordmodel.dart';

class DatabaseCoverage {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// reference to employee dates
  CollectionReference<Map<String, dynamic>> _ref(String empName) {
    return _db.collection('coverage_records').doc(empName).collection('dates');
  }

  /// create or replace a coverage record
  Future<void> save(
    String empName,
    int coverageDate,
    CoverageRecordModel record,
  ) async {
    await _ref(empName).doc(coverageDate.toString()).set({
      ...record.toMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// get a single day
  Future<CoverageRecordModel?> getDay(
    String empName,
    int coverageDate,
  ) async {
    final doc = await _ref(empName).doc(coverageDate.toString()).get();

    if (!doc.exists) return null;

    return CoverageRecordModel.fromDoc(doc);
  }

  /// stream all days of an employee
  Stream<List<CoverageRecordModel>> streamAll(String empName) {
    return _ref(empName)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CoverageRecordModel.fromDoc(d)).toList());
  }

  /// delete a specific day
  Future<void> deleteDay(
    String empName,
    int coverageDate,
  ) async {
    await _ref(empName).doc(coverageDate.toString()).delete();
  }

  /// batch save multiple days (good for Generate button)
  Future<void> batchSave(
    String empName,
    List<CoverageRecordModel> records,
  ) async {
    final batch = _db.batch();

    for (final r in records) {
      final doc = _ref(empName).doc(r.coverageDate.toString());

      // use merge so isGenerated set by Generate is never overwritten by Save
      batch.set(doc, {
        "amountEarned": r.amountEarned,
        "coverageDate": r.coverageDate,
        "absent": r.absent,
        "empId": r.empId,
        "remarks": r.remarks,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<List<CoverageRecordModel>> getAll(String empName) async {
    final snap = await FirebaseFirestore.instance
        .collection('coverage_records')
        .doc(empName)
        .collection('dates')
        .get();

    return snap.docs.map((d) => CoverageRecordModel.fromDoc(d)).toList();
  }
}
