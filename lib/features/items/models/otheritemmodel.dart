class OtherItemModel {
  final String docId;
  final int itemId;
  final int itemUniqueId;
  final String itemGroup;
  final String itemName;
  final int itemPrice;
  final int stocksAlert;
  final String stocksType; //pcs, pack, bottle

  OtherItemModel({
    required this.docId,
    required this.itemId,
    required this.itemUniqueId,
    required this.itemGroup,
    required this.itemName,
    required this.itemPrice,
    required this.stocksAlert,
    required this.stocksType,
  });

  OtherItemModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['DocId']! as String,
          itemId: json['ItemId']! as int,
          itemUniqueId: json['ItemUniqueId']! as int,
          itemGroup: json['ItemGroup']! as String,
          itemName: json['ItemName']! as String,
          itemPrice: json['ItemPrice']! as int,
          stocksAlert: json['StocksAlert']! as int,
          stocksType: json['StocksType']! as String,
        );

  OtherItemModel coyWith({
    String? docId,
    int? itemId,
    int? itemUniqueId,
    String? itemGroup,
    String? itemName,
    int? itemPrice,
    int? stocksAlert,
    String? stocksType,
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
    );
  }

  Map<String, dynamic> toJson() => {
        'DocId': docId,
        'ItemId': itemId,
        'ItemUniqueId': itemUniqueId,
        'ItemGroup': itemGroup,
        'ItemName': itemName,
        'ItemPrice': itemPrice,
        'StocksAlert': stocksAlert,
        'StocksType': stocksType,
      };

  factory OtherItemModel.makeEmpty() {
    return OtherItemModel(
      docId: '',
      itemId: 0,
      itemUniqueId: 0,
      itemGroup: '',
      itemName: '',
      itemPrice: 0,
      stocksAlert: 0,
      stocksType: '',
    );
  }
}
