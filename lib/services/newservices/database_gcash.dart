import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';

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
  Future<bool> addBool(GCashModel modelValue) async {
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
  Future<GCashModel?> get(String docId) async {
    final doc = await _ref.doc(docId).get();
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
    await _ref.doc(gM.docId).update(gM.toJson());
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

  Future<String?> uploadToCloudinaryWeb(XFile file) async {
    const cloudName = 'dxdskr55w';
    const uploadPreset = 'gcash_unsigned';

    final dio = Dio();

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final bytes = await file.readAsBytes();

    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      ),
      "upload_preset": uploadPreset,
    });

    final response = await dio.post(url, data: formData);

    if (response.statusCode == 200) {
      return response.data['secure_url'];
    }

    return null;
  }

  Future<void> saveImageWeb(GCashModel model, XFile imageFile) async {
    String? imageUrl = await uploadToCloudinaryWeb(imageFile);

    if (imageUrl == null) {
      throw Exception("Image upload failed");
    }

    // 👇 Use existing docId
    final docRef = FirebaseFirestore.instance
        .collection(GCASH_PENDING_REF)
        .doc(model.docId);

    // 👇 Only update imageUrl field
    await docRef.update({
      'ImageUrl': imageUrl,
    });
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
  Stream<List<GCashModel>> streamAll() {
    return _ref.orderBy('LogDate', descending: true).snapshots().map(
          (s) => s.docs.map((d) => GCashModel.fromJson(d.data())).toList(),
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

    // final currentRemarks = (data['Remarks'] ?? '').toString().trim();
    // final updatedRemarks =
    //     currentRemarks.isEmpty ? 'Done' : '$currentRemarks Done';

    tx.set(ongoingRef, {
      ...data,
      // 'Remarks': updatedRemarks,
      'CurrentStocks': 1,
      'LogDate': Timestamp.now(),
    });

    tx.delete(queueRef);
  });
}
