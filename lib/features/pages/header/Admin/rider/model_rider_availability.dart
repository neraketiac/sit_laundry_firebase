import 'package:cloud_firestore/cloud_firestore.dart';

class ModelRiderAvailability {
  final DateTime date;
  final bool slot7to9; // 7am - 9am
  final bool slot9to12; // 9am - 12pm
  final bool slot12to4; // 12pm - 4pm
  final bool slot4to9; // 4pm - 9pm

  ModelRiderAvailability({
    required this.date,
    this.slot7to9 = false,
    this.slot9to12 = false,
    this.slot12to4 = false,
    this.slot4to9 = false,
  });

  /// Firestore doc id: yyyy-MM-dd
  String get docId =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'slot7to9': slot7to9,
        'slot9to12': slot9to12,
        'slot12to4': slot12to4,
        'slot4to9': slot4to9,
      };

  factory ModelRiderAvailability.fromMap(Map<String, dynamic> map) {
    final ts = map['date'] as Timestamp;
    return ModelRiderAvailability(
      date: ts.toDate(),
      slot7to9: map['slot7to9'] ?? false,
      slot9to12: map['slot9to12'] ?? false,
      slot12to4: map['slot12to4'] ?? false,
      slot4to9: map['slot4to9'] ?? false,
    );
  }

  ModelRiderAvailability copyWith({
    bool? slot7to9,
    bool? slot9to12,
    bool? slot12to4,
    bool? slot4to9,
  }) =>
      ModelRiderAvailability(
        date: date,
        slot7to9: slot7to9 ?? this.slot7to9,
        slot9to12: slot9to12 ?? this.slot9to12,
        slot12to4: slot12to4 ?? this.slot12to4,
        slot4to9: slot4to9 ?? this.slot4to9,
      );

  bool get hasAnySlot => slot7to9 || slot9to12 || slot12to4 || slot4to9;
}

const List<String> kSlotLabels = ['7am-9am', '9am-12pm', '12pm-4pm', '4pm-9pm'];
