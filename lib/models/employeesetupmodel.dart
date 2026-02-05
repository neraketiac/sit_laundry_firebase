import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeSetupModel {
  String docId;
  String empId;
  String empName;
  Timestamp logDate;
  String logBy;
  String remarks;
  bool showLaundry;
  bool showFunds;
  bool showFundsHistory;
  bool showEmployee;
  bool showIncome;

  EmployeeSetupModel({
    required this.docId,
    required this.empId,
    required this.empName,
    required this.logDate,
    required this.logBy,
    required this.remarks,
    required this.showLaundry,
    required this.showFunds,
    required this.showFundsHistory,
    required this.showEmployee,
    required this.showIncome,
  });

  EmployeeSetupModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId'] ?? '',
          empId: json['EmpId'] ?? '',
          empName: json['EmpName'] ?? '',
          logDate: json['LogDate'] ?? Timestamp.now(),
          logBy: json['LogBy'] ?? '',
          remarks: json['Remarks'] ?? '',
          showLaundry: json['ShowLaundry'] ?? false,
          showFunds: json['ShowFunds'] ?? false,
          showFundsHistory: json['ShowFundsHistory'] ?? false,
          showEmployee: json['ShowEmployee'] ?? false,
          showIncome: json['ShowIncome'] ?? false,
        );

  EmployeeSetupModel copyWith({
    String? docId,
    String? empId,
    String? empName,
    Timestamp? logDate,
    String? logBy,
    String? remarks,
    bool? showLaundry,
    bool? showFunds,
    bool? showFundsHistory,
    bool? showEmployee,
    bool? showIncome,
  }) {
    return EmployeeSetupModel(
      docId: docId ?? this.docId,
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      logDate: logDate ?? this.logDate,
      logBy: logBy ?? this.logBy,
      remarks: remarks ?? this.remarks,
      showLaundry: showLaundry ?? this.showLaundry,
      showFunds: showFunds ?? this.showFunds,
      showFundsHistory: showFundsHistory ?? this.showFundsHistory,
      showEmployee: showEmployee ?? this.showEmployee,
      showIncome: showIncome ?? this.showIncome,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'EmpId': empId,
        'EmpName': empName,
        'LogDate': logDate,
        'LogBy': logBy,
        'Remarks': remarks,
        'ShowLaundry': showLaundry,
        'ShowFunds': showFunds,
        'ShowFundsHistory': showFundsHistory,
        'ShowEmployee': showEmployee,
        'ShowIncome': showIncome,
      };
}
