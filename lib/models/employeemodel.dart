import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  String docId;
  String empId;
  String empName;
  int    balCurr;           //* (+) need to pay in WKL, (-) need to give to customer, (0) no balance
  Timestamp lastTransDate;  //* last transaction date
  String remarks;

  EmployeeModel({
    required this.docId,
    required this.empId,
    required this.empName,
    required this.balCurr,
    required this.lastTransDate,
    required this.remarks,
  });

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['docId']! as String,
          empId: json['empId']! as String,
          empName: json['empName']! as String,
          balCurr: json['balCurr']! as int,
          lastTransDate: json['lastTransDate']! as Timestamp,
          remarks: json['remarks']! as String,
        );

  EmployeeModel coyWith({
    String? docId,
    String? empId,
    String? empName,
    int? balCurr,
    Timestamp? lastTransDate,
    String? remarks,
  }) {
    return EmployeeModel(
      docId: docId ?? this.docId,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      balCurr: balCurr ?? this.balCurr,
      lastTransDate: lastTransDate ?? this.lastTransDate,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'empId': empId,
        'empName': empName,
        'balCurr': balCurr,
        'lastTransDate': lastTransDate,
        'remarks': remarks,
      };
}
