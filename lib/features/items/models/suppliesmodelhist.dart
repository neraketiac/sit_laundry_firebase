import 'package:cloud_firestore/cloud_firestore.dart';

class SuppliesModelHist {
  String docId;
  int countId;
  int itemId;
  int itemUniqueId; //if itemUniqueId below 10,000 then no security is needed, if equal or above, need to check if has access, cannot view in table
  String itemName;
  int currentCounter; // -1 or +1 or -2 or +2, indicates to subtract or add in stocksCount
  int currentStocks; // ex. 50 if -1 counter, 49 currentStocks
  Timestamp logDate;
  String empId;
  int customerId;
  String customerName;
  String remarks;
  int? expenseAmount;

  SuppliesModelHist({
    required this.docId,
    required this.countId,
    required this.itemId,
    required this.itemUniqueId,
    required this.itemName,
    required this.currentCounter,
    required this.currentStocks,
    required this.logDate,
    required this.empId,
    required this.customerId,
    required this.customerName,
    required this.remarks,
    this.expenseAmount,
  });

  SuppliesModelHist.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          countId: json['CountId']! as int,
          itemId: json['ItemId']! as int,
          itemUniqueId: json['ItemUniqueId']! as int,
          itemName: json['ItemName']! as String,
          currentCounter: json['CurrentCounter']! as int,
          currentStocks: json['CurrentStocks']! as int,
          logDate: json['LogDate']! as Timestamp,
          empId: json['EmpId']! as String,
          customerId: json['CustomerId']! as int,
          customerName: json['CustomerName']! as String,
          remarks: json['Remarks']! as String,
          expenseAmount: json['ExpenseAmount'] as int?,
        );

  SuppliesModelHist copyWith({
    String? docId,
    int? countId,
    int? itemId,
    int? itemUniqueId,
    String? itemName,
    int? currentCounter,
    int? currentStocks,
    Timestamp? logDate,
    String? empId,
    int? customerId,
    String? customerName,
    String? remarks,
    int? expenseAmount,
  }) {
    return SuppliesModelHist(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      itemId: itemId ?? this.itemId,
      itemUniqueId: itemUniqueId ?? this.itemUniqueId,
      itemName: itemName ?? this.itemName,
      currentCounter: currentCounter ?? this.currentCounter,
      currentStocks: currentStocks ?? this.currentStocks,
      logDate: logDate ?? this.logDate,
      empId: empId ?? this.empId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      remarks: remarks ?? this.remarks,
      expenseAmount: expenseAmount ?? this.expenseAmount,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'CountId': countId,
        'ItemId': itemId,
        'ItemUniqueId': itemUniqueId,
        'ItemName': itemName,
        'CurrentCounter': currentCounter,
        'CurrentStocks': currentStocks,
        'LogDate': logDate,
        'EmpId': empId,
        'CustomerId': customerId,
        'CustomerName': customerName,
        'Remarks': remarks,
        'ExpenseAmount': expenseAmount ?? 0,
      };
}
