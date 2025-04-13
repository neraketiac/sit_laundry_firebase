import 'package:cloud_firestore/cloud_firestore.dart';

class SuppliesModelHist {
  String docId;
  int countId;
  int itemId;
  int itemUniqueId;
  int currentCounter; // -1 or +1 or -2 or +2, indicates to subtract or add in stocksCount
  int currentStocks; // ex. 50 if -1 counter, 49 currentStocks
  Timestamp logDate;
  String empId;
  int customerId;
  String remarks;

  SuppliesModelHist({
    required this.docId,
    required this.countId,
    required this.itemId,
    required this.itemUniqueId,
    required this.currentCounter,
    required this.currentStocks,
    required this.logDate,
    required this.empId,
    required this.customerId,
    required this.remarks,
  });

  SuppliesModelHist.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          countId: json['CountId']! as int,
          itemId: json['ItemId']! as int,
          itemUniqueId: json['ItemUniqueId']! as int,
          currentCounter: json['CurrentCounter']! as int,
          currentStocks: json['CurrentStocks']! as int,
          logDate: json['LogDate']! as Timestamp,
          empId: json['EmpId']! as String,
          customerId: json['CustomerId']! as int,
          remarks: json['Remarks']! as String,
        );

  SuppliesModelHist coyWith({
    String? docId,
    int? countId,
    int? itemId,
    int? itemUniqueId,
    int? currentCounter,
    int? currentStocks,
    Timestamp? logDate,
    String? empId,
    int? customerId,
    String? remarks,
  }) {
    return SuppliesModelHist(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      itemId: itemId ?? this.itemId,
      itemUniqueId: itemUniqueId ?? this.itemUniqueId,
      currentCounter: currentCounter ?? this.currentCounter,
      currentStocks: currentStocks ?? this.currentStocks,
      logDate: logDate ?? this.logDate,
      empId: empId ?? this.empId,
      customerId: customerId ?? this.customerId,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'CountId': countId,
        'ItemId': itemId,
        'ItemUniqueId': itemUniqueId,
        'CurrentCounter': currentCounter,
        'CurrentStocks': currentStocks,
        'LogDate': logDate,
        'EmpId': empId,
        'CustomerId': customerId,
        'Remarks': remarks,
      };
}
