import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 COLLECTION REFERENCES
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
const String GCASH_PENDING_REF = "GCash_pending";
const String GCASH_DONE_REF = "GCash_done";

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 DATABASE : GCASH PENDING
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
class DatabaseGCashPending {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(GCASH_PENDING_REF);

  /// ➕ Add modelValue
  Future<bool> addBool(SuppliesModelHist modelValue) async {
    bool bSuccess = false;
    final docRef = _ref.doc(); // auto-generate ID
    modelValue.docId = docRef.id; // store the ID in your model
    await docRef
        .set(modelValue.toJson())
        .then((value) => {
              print("GCash Pending insert done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print(
                  "Failed insert GCash Pending : $error ${modelValue.customerName}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  /// 📥 Get single modelValue
  Future<SuppliesModelHist?> get(String docId) async {
    final doc = await _ref.doc(docId).get();
    if (!doc.exists || doc.data() == null) return null;
    return SuppliesModelHist.fromJson(doc.data()!);
  }

  /// 🔄 Stream all queued modelValues
  Stream<List<SuppliesModelHist>> streamAll() {
    return _ref.orderBy('LogDate', descending: true).limit(30).snapshots().map(
          (s) =>
              s.docs.map((d) => SuppliesModelHist.fromJson(d.data())).toList(),
        );
  }

  /// ❌ Delete modelValue
  Future<void> deleteVoid(SuppliesModelHist modelValue) async {
    await _ref
        .doc(modelValue.docId)
        .delete()
        .then((value) => {
              print("Delete pending done."),
            })
        .catchError((error) => {
              print(
                  "Failed delete GCash Pending : $error ${modelValue.customerName}"),
            });
  }

  Future<bool> deleteBool(SuppliesModelHist modelValue) async {
    bool bSuccess = false;
    await _ref
        .doc(modelValue.docId)
        .delete()
        .then((value) => {
              print("Delete pending done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print(
                  "Failed delete GCash Pending : $error ${modelValue.customerName}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  Future<void> updateVoid(SuppliesModelHist jM) async {
    await _ref.doc(jM.docId).update(jM.toJson());
  }

  Future<bool> updateBool(SuppliesModelHist jM) async {
    bool bSuccess = false;
    await _ref
        .doc(jM.docId)
        .update(jM.toJson())
        .then((value) => {
              print("Update Done"),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed Update GCash Pending : $error ${jM.customerName}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}

/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
/// 🔹 DATABASE : GCash Done
/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
class DatabaseGCashDone {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(GCASH_DONE_REF);

  /// 🔄 Stream all ongoing modelValues
  Stream<List<SuppliesModelHist>> streamAll() {
    return _ref.orderBy('LogDate', descending: true).snapshots().map(
          (s) =>
              s.docs.map((d) => SuppliesModelHist.fromJson(d.data())).toList(),
        );
  }
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 MOVEMENT (TRANSACTIONS)
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

/// ▶ Queue → Ongoing (start washing)
Future<void> moveToNext(String docId) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((tx) async {
    final queueRef = firestore.collection(GCASH_PENDING_REF).doc(docId);
    final ongoingRef = firestore.collection(GCASH_DONE_REF).doc(docId);

    final snapshot = await tx.get(queueRef);
    if (!snapshot.exists) return;

    final data = snapshot.data()!;

    final currentRemarks = (data['Remarks'] ?? '').toString().trim();
    final updatedRemarks =
        currentRemarks.isEmpty ? 'Done' : '$currentRemarks Done';

    tx.set(ongoingRef, {
      ...data,
      'Remarks': updatedRemarks,
      'CurrentStocks': 1,
    });

    tx.delete(queueRef);
  });
}
