import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  String docId;
  int countId;
  String empId;
  String empName;
  //int    balCurr;           //* (+) need to pay in WKL, (-) need to give to customer, (0) no balance
  int currentCounter;
  int currentStocks;
  int itemId;
  int itemUniqueId;
  Timestamp logDate; //* last transaction date
  String logBy; //different name who log records
  String remarks;

  EmployeeModel({
    required this.docId,
    required this.countId,
    required this.empId,
    required this.empName,
    required this.currentCounter,
    required this.currentStocks,
    required this.itemId,
    required this.itemUniqueId,
    required this.logDate,
    required this.logBy,
    required this.remarks,
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
          logDate: json['LogDate']! as Timestamp,
          logBy: json['LogBy']! as String,
          remarks: json['Remarks']! as String,
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
    Timestamp? logDate,
    String? logBy,
    String? remarks,
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
      logDate: logDate ?? this.logDate,
      logBy: logBy ?? this.logBy,
      remarks: remarks ?? this.remarks,
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
        'LogDate': logDate,
        'LogBy': logBy,
        'Remarks': remarks,
      };
}
