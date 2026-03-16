import 'package:cloud_firestore/cloud_firestore.dart';

class OtherItemModel {
  final String docId; // Firestore document id
  final int itemId; // editable
  final int itemUniqueId; // editable
  final String itemGroup; // always "Oth"
  final String itemName; // editable
  final int itemPrice; // editable
  final int stocksAlert; // editable
  final String stocksType; // pcs, pack, bottle, peso
  final Timestamp logDate; // last modification date

  OtherItemModel({
    required this.docId,
    required this.itemId,
    required this.itemUniqueId,
    required this.itemGroup,
    required this.itemName,
    required this.itemPrice,
    required this.stocksAlert,
    required this.stocksType,
    required this.logDate,
  });

  /// ---------------------------
  /// FROM FIRESTORE
  /// ---------------------------

  factory OtherItemModel.fromJson(Map<String, dynamic> json) {
    return OtherItemModel(
      docId: json['DocId'] ?? '',
      itemId: (json['ItemId'] ?? 0) as int,
      itemUniqueId: (json['ItemUniqueId'] ?? 0) as int,
      itemGroup: (json['ItemGroup'] ?? 'Oth') as String,
      itemName: (json['ItemName'] ?? '') as String,
      itemPrice: (json['ItemPrice'] ?? 0) as int,
      stocksAlert: (json['StocksAlert'] ?? 0) as int,
      stocksType: (json['StocksType'] ?? 'pcs') as String,
      logDate: (json['LogDate'] ?? Timestamp.now()) as Timestamp,
    );
  }

  /// ---------------------------
  /// COPY WITH
  /// ---------------------------

  OtherItemModel coyWith({
    String? docId,
    int? itemId,
    int? itemUniqueId,
    String? itemGroup,
    String? itemName,
    int? itemPrice,
    int? stocksAlert,
    String? stocksType,
    Timestamp? logDate,
  }) {
    return OtherItemModel(
      docId: docId ?? this.docId,
      itemId: itemId ?? this.itemId,
      itemUniqueId: itemUniqueId ?? this.itemUniqueId,
      itemGroup: itemGroup ?? this.itemGroup,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
      stocksAlert: stocksAlert ?? this.stocksAlert,
      stocksType: stocksType ?? this.stocksType,
      logDate: logDate ?? this.logDate,
    );
  }

  /// ---------------------------
  /// TO FIRESTORE
  /// ---------------------------

  Map<String, dynamic> toJson() {
    return {
      'DocId': docId,
      'ItemId': itemId,
      'ItemUniqueId': itemUniqueId,
      'ItemGroup': itemGroup,
      'ItemName': itemName,
      'ItemPrice': itemPrice,
      'StocksAlert': stocksAlert,
      'StocksType': stocksType,
      'LogDate': logDate,
    };
  }

  /// ---------------------------
  /// EMPTY MODEL
  /// ---------------------------

  factory OtherItemModel.makeEmpty() {
    return OtherItemModel(
      docId: '',
      itemId: 0,
      itemUniqueId: 0,
      itemGroup: 'Oth',
      itemName: '',
      itemPrice: 0,
      stocksAlert: 0,
      stocksType: 'pcs',
      logDate: Timestamp.now(),
    );
  }
}
