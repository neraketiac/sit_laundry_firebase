import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  String docId;
  int countId;
  String empId;
  String empName;
  int currentCounter;
  int currentStocks;
  int itemId;
  int itemUniqueId;
  String itemName;
  Timestamp logDate; //* transaction recorded date (always now)
  String logBy;
  String remarks;
  Timestamp?
      autoSalaryDate; //* actual work date when auto-generated from calendar

  EmployeeModel({
    required this.docId,
    required this.countId,
    required this.empId,
    required this.empName,
    required this.currentCounter,
    required this.currentStocks,
    required this.itemId,
    required this.itemUniqueId,
    required this.itemName,
    required this.logDate,
    required this.logBy,
    required this.remarks,
    this.autoSalaryDate,
  });

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          countId: json['CountId']! as int,
          empId: json['EmpId']! as String,
          empName: json['EmpName']! as String,
          currentCounter: json['CurrentCounter']! as int,
          currentStocks: json['CurrentStocks']! as int,
          itemId: json['ItemId']! as int,
          itemUniqueId: json['ItemUniqueId']! as int,
          itemName: json['ItemName']! as String,
          logDate: json['LogDate']! as Timestamp,
          logBy: json['LogBy']! as String,
          remarks: json['Remarks']! as String,
          autoSalaryDate: json['AutoSalaryDate'] as Timestamp?,
        );

  EmployeeModel coyWith({
    String? docId,
    int? countId,
    String? empId,
    String? empName,
    int? currentCounter,
    int? currentStocks,
    int? itemId,
    int? itemUniqueId,
    String? itemName,
    Timestamp? logDate,
    String? logBy,
    String? remarks,
    Timestamp? autoSalaryDate,
  }) {
    return EmployeeModel(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      currentCounter: currentCounter ?? this.currentCounter,
      currentStocks: currentStocks ?? this.currentStocks,
      itemId: itemId ?? this.itemId,
      itemUniqueId: itemUniqueId ?? this.itemUniqueId,
      itemName: itemName ?? this.itemName,
      logDate: logDate ?? this.logDate,
      logBy: logBy ?? this.logBy,
      remarks: remarks ?? this.remarks,
      autoSalaryDate: autoSalaryDate ?? this.autoSalaryDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'CountId': countId,
        'EmpId': empId,
        'EmpName': empName,
        'CurrentCounter': currentCounter,
        'CurrentStocks': currentStocks,
        'ItemId': itemId,
        'ItemUniqueId': itemUniqueId,
        'ItemName': itemName,
        'LogDate': logDate,
        'LogBy': logBy,
        'Remarks': remarks,
        if (autoSalaryDate != null) 'AutoSalaryDate': autoSalaryDate,
      };
}
