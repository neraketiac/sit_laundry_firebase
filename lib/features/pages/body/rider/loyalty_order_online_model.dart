import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupStatus { pending, ongoing, completed }

extension PickupStatusExt on PickupStatus {
  String get label => switch (this) {
        PickupStatus.pending => 'Pending',
        PickupStatus.ongoing => 'Ongoing',
        PickupStatus.completed => 'Completed',
      };

  static PickupStatus fromString(String? v) => switch (v) {
        'ongoing' => PickupStatus.ongoing,
        'completed' => PickupStatus.completed,
        _ => PickupStatus.pending,
      };

  String get value => switch (this) {
        PickupStatus.pending => 'pending',
        PickupStatus.ongoing => 'ongoing',
        PickupStatus.completed => 'completed',
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

  LoyaltyOrderOnlineModel({
    required this.docId,
    required this.name,
    required this.contact,
    required this.address,
    required this.scheduleDate,
    required this.timeSlot,
    required this.createdAt,
    this.pickupStatus = PickupStatus.pending,
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
        'pickupStatus': pickupStatus.value,
      };
}
