import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  String docId;
  int countId;
  String empId;
  String empName;
  //int    balCurr;           //* (+) need to pay in WKL, (-) need to give to customer, (0) no balance
  int currentCounter;
  int currentStocks;
  Timestamp logDate;  //* last transaction date
  String remarks;

  EmployeeModel({
    required this.docId,
    required this.countId,
    required this.empId,
    required this.empName,
    required this.currentCounter,
    required this.currentStocks,
    required this.logDate,
    required this.remarks,
  });

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['docId']! as String,
          countId: json['countId']! as int,
          empId: json['empId']! as String,
          empName: json['empName']! as String,
          currentCounter: json['currentCounter']! as int,
          currentStocks: json['currentStocks']! as int,
          logDate: json['logDate']! as Timestamp,
          remarks: json['remarks']! as String,
        );

  EmployeeModel coyWith({
    String? docId,
    int? countId,
    String? empId,
    String? empName,
    int? currentCounter,
    int? currentStocks,
    Timestamp? logDate,
    String? remarks,
  }) {
    return EmployeeModel(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      currentCounter: currentCounter ?? this.currentCounter,
      currentStocks: currentStocks ?? this.currentStocks,
      logDate: logDate ?? this.logDate,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'countId': countId,
        'empId': empId,
        'empName': empName,
        'currentCounter': currentCounter,
        'currentStocks': currentStocks,
        'logDate': logDate,
        'remarks': remarks,
      };
}
