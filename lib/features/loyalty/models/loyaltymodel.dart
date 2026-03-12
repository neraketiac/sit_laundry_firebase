import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyModel {
  final String name;
  final String contact;
  final String address;
  final String remarks;
  final int count; //every jobs_done, add that promoCounter here.
  //if count >= 10, the free button will appear ( -155 free )
  //if (-155 free was used), after jobs_done, it will deduct count = count - 10
  //then repeat the process again how to add count = count + promoCounter(jobs_done)
  final int cardNumber;
  final Timestamp logDate;

  LoyaltyModel({
    required this.name,
    required this.contact,
    required this.address,
    required this.remarks,
    required this.count,
    required this.cardNumber,
    required this.logDate,
  });

  LoyaltyModel.fromJson(Map<String, dynamic> json)
      : this(
          name: json['Name'] as String,
          contact: json['Contact'] as String,
          address: json['Address'] as String,
          remarks: json['C5_Remarks'] as String,
          count: json['Count'] as int,
          cardNumber: json['cardNumber'] as int,
          logDate: json['logDate'] as Timestamp,
        );

  LoyaltyModel copyWith({
    String? name,
    String? contact,
    String? address,
    String? remarks,
    int? count,
    int? cardNumber,
    Timestamp? logDate,
  }) {
    return LoyaltyModel(
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      remarks: remarks ?? this.remarks,
      count: count ?? this.count,
      cardNumber: cardNumber ?? this.cardNumber,
      logDate: logDate ?? this.logDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Contact': contact,
        'Address': address,
        'C5_Remarks': remarks,
        'Count': count,
        'cardNumber': cardNumber,
        'logDate': logDate,
      };
}
