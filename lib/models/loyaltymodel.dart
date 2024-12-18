class LoyaltyModel {
  final String name;
  final String contact;
  final String address;
  final String remarks;
  final int count;

  LoyaltyModel({
    required this.name,
    required this.contact,
    required this.address,
    required this.remarks,
    required this.count,
  });

  LoyaltyModel.fromJson(Map<String, dynamic> json)
      : this(
          name: json['Name']! as String,
          contact: json['Contact']! as String,
          address: json['Address']! as String,
          remarks: json['Remarks']! as String,
          count: json['Count']! as int,
        );

  LoyaltyModel coyWith({
    String? name,
    String? contact,
    String? address,
    String? remarks,
    int? count,
  }) {
    return LoyaltyModel(
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      remarks: remarks ?? this.remarks,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Contact': contact,
        'Address': address,
        'Remarks': remarks,
        'Count': count,
      };

  String toStringLoyaltyModel() {
    return '$name, $address';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LoyaltyModel &&
        other.name == name &&
        other.address == address &&
        other.remarks == remarks;
  }

  @override
  int get hashCode => Object.hash(address, name);
}
