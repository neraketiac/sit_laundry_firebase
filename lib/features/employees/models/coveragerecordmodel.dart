import 'package:cloud_firestore/cloud_firestore.dart';

class CoverageRecordModel {
  final String docId;
  final int amountEarned;
  final int coverageDate;
  final int
      absent; //0 - present, 1 - absent am, 2 - absent pm, 3 - absent whole day
  final String empId;
  final String remarks;
  final bool isGenerated;
  final Timestamp? createdAt;

  CoverageRecordModel({
    required this.docId,
    required this.amountEarned,
    required this.coverageDate,
    required this.absent,
    required this.empId,
    required this.remarks,
    required this.isGenerated,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "amountEarned": amountEarned,
      "coverageDate": coverageDate,
      "absent": absent,
      "empId": empId,
      "remarks": remarks,
      "isGenerated": isGenerated,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory CoverageRecordModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return CoverageRecordModel(
      docId: doc.id,
      amountEarned: d["amountEarned"] ?? 0,
      coverageDate: d["coverageDate"] ?? 0,
      absent: d["absent"] ?? 0,
      empId: d["empId"] ?? "",
      remarks: d["remarks"] ?? "",
      isGenerated: d["isGenerated"] ?? false,
      createdAt: d["createdAt"],
    );
  }
}
