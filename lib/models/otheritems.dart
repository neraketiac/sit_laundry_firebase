class OtherItems {
  final int itemId;
  final String itemName;
  final int itemPrice;

  OtherItems({
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
  });

  OtherItems.fromJson(Map<String, dynamic> json)
      : this(
          itemId: json['ItemId']! as int,
          itemName: json['ItemName']! as String,
          itemPrice: json['ItemPrice']! as int,
        );

  OtherItems coyWith({
    int? itemId,
    String? itemName,
    int? itemPrice,
  }) {
    return OtherItems(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'itemPrice': itemPrice,
      };
}
