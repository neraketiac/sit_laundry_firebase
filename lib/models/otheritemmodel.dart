class OtherItemModel {
  final int itemId;
  final String itemGroup;
  final String itemName;
  final int itemPrice;

  OtherItemModel({
    required this.itemId,
    required this.itemGroup,
    required this.itemName,
    required this.itemPrice,
  });

  OtherItemModel.fromJson(Map<String, dynamic> json)
      : this(
          itemId: json['ItemId']! as int,
          itemGroup: json['ItemGroup']! as String,
          itemName: json['ItemName']! as String,
          itemPrice: json['ItemPrice']! as int,
        );

  OtherItemModel coyWith({
    int? itemId,
    String? itemGroup,
    String? itemName,
    int? itemPrice,
  }) {
    return OtherItemModel(
      itemId: itemId ?? this.itemId,
      itemGroup: itemGroup ?? this.itemGroup,
      itemName: itemName ?? this.itemName,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemGroup': itemGroup,
        'itemName': itemName,
        'itemPrice': itemPrice,
      };
}
