import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 COLLECTION REFERENCES
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
const String GCASH_PENDING_REF = "GCash_pending";
const String GCASH_DONE_REF = "GCash_done";

/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
/// 🔹 DATABASE : GCASH PENDING
/// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦
class DatabaseGCashPending {
  final FirebaseFirestore _firestore =
      FirebaseService.gcashPendingDoneFirestore;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(GCASH_PENDING_REF);

  /// ➕ Add modelValue
  // Future<bool> addBool(GCashModel modelValue) async {
  //   bool bSuccess = false;
  //   final docRef = _ref.doc(); // auto-generate ID
  //   modelValue.docId = docRef.id; // store the ID in your model
  //   await docRef
  //       .set(modelValue.toJson())
  //       .then((value) => {
  //             print("GCash Pending insert done."),
  //             bSuccess = true,
  //           })
  //       .catchError((error) => {
  //             print(
  //                 "Failed insert GCash Pending : $error ${modelValue.customerName}"),
  //             bSuccess = false,
  //           });
  //   return bSuccess;
  // }

  Future<bool> addBool(GCashModel modelValue) async {
    final docRef = _ref.doc();
    modelValue.docId = docRef.id;

    try {
      await docRef.set(modelValue.toJson()).withFsTimeout();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 📥 Get single modelValue
  Future<GCashModel?> get(String docId) async {
    final doc = await _ref.doc(docId).get().withFsTimeout();
    if (!doc.exists || doc.data() == null) return null;
    return GCashModel.fromJson(doc.data()!);
  }

  /// 🔄 Stream all queued modelValues
  Stream<List<GCashModel>> streamAll() {
    return _ref.orderBy('LogDate', descending: true).limit(30).snapshots().map(
          (s) => s.docs.map((d) => GCashModel.fromJson(d.data())).toList(),
        );
  }

  /// ❌ Delete modelValue
  Future<void> deleteVoid(GCashModel modelValue) async {
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

  Future<bool> deleteBool(GCashModel modelValue) async {
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

  Future<void> updateVoid(GCashModel gM) async {
    await _ref.doc(gM.docId).update(gM.toJson()).withFsTimeout();
  }

  Future<bool> updateBool(GCashModel gM) async {
    bool bSuccess = false;
    await _ref
        .doc(gM.docId)
        .update(gM.toJson())
        .then((value) => {
              print("Update Done"),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed Update GCash Pending : $error ${gM.customerName}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  Future<void> saveImageUrl(GCashModel model, Uint8List bytes) async {
    // 🔥 compress first
    Uint8List compressedBytes = await compressImage(bytes);

    String? imageUrl = await uploadToCloudinaryBytes(compressedBytes);

    if (imageUrl == null) {
      throw Exception("Image upload failed");
    }

    if (model.itemUniqueId == menuOthUniqIdCashOut) {
      await FirebaseService.gcashPendingDoneFirestore
          .collection(GCASH_PENDING_REF)
          .doc(model.docId)
          .update({
        'CashOutImageUrl': imageUrl,
        'GCashStatus': 0.5,
      });
    } else {
      await FirebaseService.gcashPendingDoneFirestore
          .collection(GCASH_PENDING_REF)
          .doc(model.docId)
          .update({
        'CashInImageUrl': imageUrl,
        'GCashStatus': 0.75,
      });
    }
  }
}

/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
/// 🔹 DATABASE : GCash Done
/// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
class DatabaseGCashDone {
  final FirebaseFirestore _firestore =
      FirebaseService.gcashPendingDoneFirestore;
  late final CollectionReference<Map<String, dynamic>> _ref =
      _firestore.collection(GCASH_DONE_REF);

  /// 🔄 Stream all — kept for compatibility
  Stream<List<GCashModel>> streamAll() {
    return _ref.orderBy('CompleteDate', descending: true).snapshots().map(
          (s) => s.docs.map((d) => GCashModel.fromJson(d.data())).toList(),
        );
  }

  /// Paginated fetch — 20 per page, ordered by CompleteDate descending, then LogDate descending
  Future<QuerySnapshot<Map<String, dynamic>>> fetchPaginated({
    DocumentSnapshot? lastDoc,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _ref
        .orderBy('CompleteDate', descending: true)
        //.orderBy('LogDate', descending: true)
        .limit(limit);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.get().withFsTimeout();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTop(int limit) {
    return _ref
        .orderBy('CompleteDate', descending: true)
        .limit(limit)
        .snapshots();
  }
}

/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
/// 🔥 MOVEMENT (TRANSACTIONS)
/// 🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

/// ▶ Queue → Ongoing (start washing)
/// With optional supplies record generation for Cash-Out
Future<void> moveToNext(String docId,
    {bool generateCashOutSupplies = false}) async {
  final firestore = FirebaseService.gcashPendingDoneFirestore;

  await firestore.runTransaction((tx) async {
    final queueRef = firestore.collection(GCASH_PENDING_REF).doc(docId);
    final ongoingRef = firestore.collection(GCASH_DONE_REF).doc(docId);

    final snapshot = await tx.get(queueRef);
    if (!snapshot.exists) {
      throw Exception('GCash record not found');
    }

    final data = snapshot.data()!;

    // Safety check: ensure status is not already 1.0 (completed)
    if ((data['GCashStatus'] ?? 0) >= 1.0) {
      throw Exception('Record already completed');
    }

    // final currentRemarks = (data['Remarks'] ?? '').toString().trim();
    // final updatedRemarks =
    //     currentRemarks.isEmpty ? 'Done' : '$currentRemarks Done';

    tx.set(ongoingRef, {
      ...data,
      // 'Remarks': updatedRemarks,
      'GCashStatus': 1,
      'CompleteDate': Timestamp.now(),
    });

    tx.delete(queueRef);
  }).then((_) async {
    // After successful transaction, generate supplies records if needed
    if (generateCashOutSupplies) {
      try {
        await _generateCashOutSuppliesRecordsAfterCompletion(docId);
      } catch (e) {
        // Transaction succeeded but supplies generation failed
        // Log it so we know about it
        debugPrint(
            '⚠️ WARNING: GCash completed but supplies records failed: $e');
        // Don't re-throw here - the main transaction already succeeded
        // User will see warning in logs/console
      }
    }
  }).catchError((e) {
    debugPrint('❌ moveToNext failed: $e');
    throw Exception('Failed to complete GCash record: $e');
  });
}

/// Generate supplies records for Cash-Out after transaction completion
Future<void> _generateCashOutSuppliesRecordsAfterCompletion(
    String docId) async {
  try {
    final firestore = FirebaseService.gcashPendingDoneFirestore;
    final doneRef = firestore.collection(GCASH_DONE_REF).doc(docId);

    final snapshot = await doneRef.get();
    if (!snapshot.exists) {
      debugPrint(
          '❌ GCash Done record not found for supplies generation: $docId');
      throw Exception('GCash Done record not found: $docId');
    }

    final data = snapshot.data()!;

    // Only generate for Cash-Out
    if ((data['ItemUniqueId'] ?? 0) != menuOthUniqIdCashOut) {
      debugPrint('ℹ️ Not a Cash-Out record, skipping supplies generation');
      return;
    }

    // Use SuppliesHistRepository to properly create the record
    // This ensures all the proper database calls and employee updates happen
    SuppliesHistRepository.instance.reset();
    SuppliesHistRepository.instance.setItemName(
        getItemNameOnly(menuOthCashInOutFunds, menuOthUniqIdCashOut));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdCashOut);
    SuppliesHistRepository.instance
        .setCurrentCounter(data['CustomerAmount'] ?? 0);
    SuppliesHistRepository.instance.setCustomerName(data['CustomerName'] ?? '');
    SuppliesHistRepository.instance.setCustomerId(0);
    SuppliesHistRepository.instance
        .setRemarks('GCash ${data['ItemName'] ?? ''} ${data['Remarks'] ?? ''}');
    SuppliesHistRepository.instance.setLogDate(Timestamp.now());

    debugPrint(
        '📝 Generating supplies records for Cash-Out: ${data['CustomerName']} - ₱${data['CustomerAmount']}');

    // Call the proper database function to add supplies records
    // This applies negation for cash-out and handles all employee updates
    await callDatabaseSuppliesCurrentAdd(
        SuppliesHistRepository.instance.suppliesModelHist!);

    debugPrint('✅ Cash-Out supplies records generated successfully for $docId');
  } catch (e) {
    // Log error and re-throw so caller can show to user
    debugPrint('❌ ERROR generating supplies records for $docId: $e');
    rethrow; // ← Important: Pass error back to caller
  }
}
