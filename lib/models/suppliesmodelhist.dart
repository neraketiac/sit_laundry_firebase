import 'package:cloud_firestore/cloud_firestore.dart';

class SuppliesModelHist {
  String docId;
  int itemId;
  int counter; // -1 or +1 or -2 or +2, indicates to subtract or add in stocksCount
  int currentStocks; // ex. 50 if -1 counter, 49 currentStocks
  int stocksAlert;
  Timestamp logDate;

  SuppliesModelHist({
    required this.docId,
    required this.itemId,
    required this.counter,
    required this.currentStocks,
    required this.stocksAlert,
    required this.logDate,
  });

  SuppliesModelHist.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['docId']! as String,
          itemId: json['itemId']! as int,
          counter: json['Counter']! as int,
          currentStocks: json['CurrentStocks']! as int,
          stocksAlert: json['StocksAlert']! as int,
          logDate: json['LogDate']! as Timestamp,
        );

  SuppliesModelHist coyWith({
    String? docId,
    int? itemId,
    int? counter,
    int? currentStocks,
    int? stocksAlert,
    Timestamp? logDate,
  }) {
    return SuppliesModelHist(
      docId: docId ?? this.docId,
      itemId: itemId ?? this.itemId,
      counter: counter ?? this.counter,
      currentStocks: currentStocks ?? this.currentStocks,
      stocksAlert: stocksAlert ?? this.stocksAlert,
      logDate: logDate ?? this.logDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'itemId': itemId,
        'Counter': counter,
        'CurrentStocks': currentStocks,
        'StocksAlert': stocksAlert,
        'LogDate': logDate,
      };
}
