class CustomerModel {
  final int customerId;
  final String name;
  final String address;
  final String contact;
  final String remarks;
  final int loyaltyCount;

  CustomerModel({
    required this.customerId,
    required this.name,
    required this.address,
    required this.contact,
    required this.remarks,
    required this.loyaltyCount,
  });

  CustomerModel.fromJson(Map<String, dynamic> json)
      : this(
          customerId: json['A5_CustomerId']! as int,
          name: json['name']! as String,
          address: json['address']! as String,
          contact: json['contact']! as String,
          remarks: json['C5_Remarks']! as String,
          loyaltyCount: json['loyaltyCount']! as int,
        );

  CustomerModel coyWith({
    int? customerId,
    String? name,
    String? address,
    String? contact,
    String? remarks,
    int? loyaltyCount,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      remarks: remarks ?? this.remarks,
      loyaltyCount: loyaltyCount ?? this.loyaltyCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'A5_CustomerId': customerId,
        'name': name,
        'address': address,
        'contact': contact,
        'C5_Remarks': remarks,
        'loyaltyCount': loyaltyCount,
      };

  String toStringCustomerModel() {
    return '$name, $address';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CustomerModel &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(address, name);
}
