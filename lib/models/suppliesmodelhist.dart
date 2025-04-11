import 'package:cloud_firestore/cloud_firestore.dart';

class SuppliesModelHist {
  String docId;
  int countId;
  int itemId;
  int currentCounter; // -1 or +1 or -2 or +2, indicates to subtract or add in stocksCount
  int currentStocks; // ex. 50 if -1 counter, 49 currentStocks
  Timestamp logDate;
  String empId;

  SuppliesModelHist({
    required this.docId,
    required this.countId,
    required this.itemId,
    required this.currentCounter,
    required this.currentStocks,
    required this.logDate,
    required this.empId,
  });

  SuppliesModelHist.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          countId: json['CountId']! as int,
          itemId: json['ItemId']! as int,
          currentCounter: json['CurrentCounter']! as int,
          currentStocks: json['CurrentStocks']! as int,
          logDate: json['LogDate']! as Timestamp,
          empId: json['EmpId']! as String,
        );

  SuppliesModelHist coyWith({
    String? docId,
    int? countId,
    int? itemId,
    int? currentCounter,
    int? currentStocks,
    Timestamp? logDate,
    String? empId,
  }) {
    return SuppliesModelHist(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      itemId: itemId ?? this.itemId,
      currentCounter: currentCounter ?? this.currentCounter,
      currentStocks: currentStocks ?? this.currentStocks,
      logDate: logDate ?? this.logDate,
      empId: empId ?? this.empId,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'CountId': countId,
        'ItemId': itemId,
        'CurrentCounter': currentCounter,
        'CurrentStocks': currentStocks,
        'LogDate': logDate,
        'EmpId': empId,
      };
}
