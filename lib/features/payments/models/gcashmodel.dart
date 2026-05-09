import 'package:cloud_firestore/cloud_firestore.dart';

class GCashModel {
  String docId;
  int countId;
  Timestamp logDate;
  String logBy;
  Timestamp completeDate;
  int itemId;
  int itemUniqueId;
  String itemName;
  int customerAmount;
  double gCashStatus;
  // cash in status   0.25-pending                    0.75-picture provided, can mark complete 1.0 go to gcash done.
  // cash out status  0.25-pending 0.5 with picture   0.75-go signal to give money, can mark complete 1.0 go to gcash done.
  int customerId;
  String customerName;
  String customerNumber; //so that i can save 09 99 999 9999
  String remarks;
  String cashInImageUrl;
  String cashOutImageUrl;
  bool isPendingFundsUntilPaid; // true = pause funds recording until paid

  GCashModel(
      {required this.docId,
      required this.countId,
      required this.logDate,
      required this.logBy,
      required this.completeDate,
      required this.itemId,
      required this.itemUniqueId,
      required this.itemName,
      required this.customerAmount,
      required this.gCashStatus,
      required this.customerId,
      required this.customerName,
      required this.customerNumber,
      required this.remarks,
      required this.cashInImageUrl,
      required this.cashOutImageUrl,
      this.isPendingFundsUntilPaid = false});

  GCashModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          countId: json['CountId']! as int,
          logDate: json['LogDate']! as Timestamp,
          logBy: json['LogBy']! as String,
          completeDate: json['CompleteDate']! as Timestamp,
          itemId: json['ItemId']! as int,
          itemUniqueId: json['ItemUniqueId']! as int,
          itemName: json['ItemName']! as String,
          customerAmount: json['CustomerAmount']! as int,
          gCashStatus: json['GCashStatus']! as double,
          customerId: json['CustomerId']! as int,
          customerName: json['CustomerName']! as String,
          customerNumber: json['CustomerNumber']! as String,
          remarks: json['Remarks']! as String,
          cashInImageUrl: (json['CashInImageUrl'] as String?) ?? '',
          cashOutImageUrl: (json['CashOutImageUrl'] as String?) ?? '',
          isPendingFundsUntilPaid:
              (json['IsPendingFundsUntilPaid'] as bool?) ?? false,
        );

  GCashModel copyWith({
    String? docId,
    int? countId,
    Timestamp? logDate,
    String? logBy,
    Timestamp? completeDate,
    int? itemId,
    int? itemUniqueId,
    String? itemName,
    int? customerAmount,
    double? gCashStatus,
    int? customerId,
    String? customerName,
    String? customerNumber,
    String? remarks,
    String? cashInImageUrl,
    String? cashOutImageUrl,
    bool? isPendingFundsUntilPaid,
  }) {
    return GCashModel(
      docId: docId ?? this.docId,
      countId: countId ?? this.countId,
      logDate: logDate ?? this.logDate,
      logBy: logBy ?? this.logBy,
      completeDate: completeDate ?? this.completeDate,
      itemId: itemId ?? this.itemId,
      itemUniqueId: itemUniqueId ?? this.itemUniqueId,
      itemName: itemName ?? this.itemName,
      customerAmount: customerAmount ?? this.customerAmount,
      gCashStatus: gCashStatus ?? this.gCashStatus,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      remarks: remarks ?? this.remarks,
      cashInImageUrl: cashInImageUrl ?? this.cashInImageUrl,
      cashOutImageUrl: cashOutImageUrl ?? this.cashOutImageUrl,
      isPendingFundsUntilPaid:
          isPendingFundsUntilPaid ?? this.isPendingFundsUntilPaid,
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'CountId': countId,
        'LogDate': logDate,
        'LogBy': logBy,
        'CompleteDate': completeDate,
        'ItemId': itemId,
        'ItemUniqueId': itemUniqueId,
        'ItemName': itemName,
        'CustomerAmount': customerAmount,
        'GCashStatus': gCashStatus,
        'CustomerId': customerId,
        'CustomerName': customerName,
        'CustomerNumber': customerNumber,
        'Remarks': remarks,
        'CashInImageUrl': cashInImageUrl,
        'CashOutImageUrl': cashOutImageUrl,
        'IsPendingFundsUntilPaid': isPendingFundsUntilPaid,
      };
}
