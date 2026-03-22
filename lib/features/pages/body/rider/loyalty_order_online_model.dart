import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupStatus { queued, enroute, done }

extension PickupStatusExt on PickupStatus {
  String get label => switch (this) {
        PickupStatus.queued => 'Queued',
        PickupStatus.enroute => 'En Route',
        PickupStatus.done => 'Done',
      };

  static PickupStatus fromString(String? v) => switch (v) {
        'enroute' => PickupStatus.enroute,
        'done' => PickupStatus.done,
        _ => PickupStatus.queued,
      };

  String get value => switch (this) {
        PickupStatus.queued => 'queued',
        PickupStatus.enroute => 'enroute',
        PickupStatus.done => 'done',
      };
}

class LoyaltyOrderOnlineModel {
  final String docId;
  final String name;
  final String contact;
  final String address;
  final DateTime scheduleDate;
  final String timeSlot;
  final Timestamp createdAt;
  final PickupStatus pickupStatus;
  final int cardNumber;

  LoyaltyOrderOnlineModel({
    required this.docId,
    required this.name,
    required this.contact,
    required this.address,
    required this.scheduleDate,
    required this.timeSlot,
    required this.createdAt,
    required this.cardNumber,
    this.pickupStatus = PickupStatus.queued,
  });

  factory LoyaltyOrderOnlineModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final schedTs = d['scheduleDate'];
    return LoyaltyOrderOnlineModel(
      docId: doc.id,
      name: d['name'] ?? '',
      contact: d['contact'] ?? '',
      address: d['address'] ?? '',
      scheduleDate: schedTs is Timestamp ? schedTs.toDate() : DateTime.now(),
      timeSlot: d['timeSlot'] ?? '',
      createdAt: d['createdAt'] ?? Timestamp.now(),
      cardNumber: d['cardNumber'] ?? 0,
      pickupStatus: PickupStatusExt.fromString(d['pickupStatus']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'contact': contact,
        'address': address,
        'scheduleDate': Timestamp.fromDate(scheduleDate),
        'timeSlot': timeSlot,
        'createdAt': createdAt,
        'cardNumber': cardNumber,
        'pickupStatus': pickupStatus.value,
      };
}
