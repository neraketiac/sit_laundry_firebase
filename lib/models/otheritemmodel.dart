class OtherItemModel {
  final String docId;
  final int itemId;
  final String itemGroup;
  final String itemName;
  final int itemPrice;

  OtherItemModel({
    required this.docId,
    required this.itemId,
    required this.itemGroup,
    required this.itemName,
    required this.itemPrice,
  });

  OtherItemModel.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['docId']! as String,
          itemId: json['ItemId']! as int,
          itemGroup: json['ItemGroup']! as String,
          itemName: json['ItemName']! as String,
          itemPrice: json['ItemPrice']! as int,
        );

  OtherItemModel coyWith({
    String? docId,
    int? itemId,
    String? itemGroup,
    String? itemName,
    int? itemPrice,
  }) {
    return OtherItemModel(
      docId: docId ?? this.docId,
      itemId: itemId ?? this.itemId,
      itemGroup: itemGroup ?? this.itemGroup,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'itemId': itemId,
        'itemGroup': itemGroup,
        'itemName': itemName,
        'itemPrice': itemPrice,
      };
}
