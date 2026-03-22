import 'package:cloud_firestore/cloud_firestore.dart';

class ModelRiderAvailability {
  final DateTime date;
  final bool slot7to9; // 7am - 9am
  final bool slot9to10; // 9am - 10am
  final bool slot10to12; // 10am - 12pm
  final bool slot1to3; // 1pm - 3pm
  final bool slot3to5; // 3pm - 5pm
  final bool slot5to7; // 5pm - 7pm
  final bool slot7to9pm; // 7pm - 9pm

  ModelRiderAvailability({
    required this.date,
    this.slot7to9 = false,
    this.slot9to10 = false,
    this.slot10to12 = false,
    this.slot1to3 = false,
    this.slot3to5 = false,
    this.slot5to7 = false,
    this.slot7to9pm = false,
  });

  String get docId =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'slot7to9': slot7to9,
        'slot9to10': slot9to10,
        'slot10to12': slot10to12,
        'slot1to3': slot1to3,
        'slot3to5': slot3to5,
        'slot5to7': slot5to7,
        'slot7to9pm': slot7to9pm,
      };

  factory ModelRiderAvailability.fromMap(Map<String, dynamic> map) {
    final ts = map['date'] as Timestamp;
    return ModelRiderAvailability(
      date: ts.toDate(),
      slot7to9: map['slot7to9'] ?? false,
      slot9to10: map['slot9to10'] ?? false,
      slot10to12: map['slot10to12'] ?? false,
      slot1to3: map['slot1to3'] ?? false,
      slot3to5: map['slot3to5'] ?? false,
      slot5to7: map['slot5to7'] ?? false,
      slot7to9pm: map['slot7to9pm'] ?? false,
    );
  }

  ModelRiderAvailability copyWith({
    bool? slot7to9,
    bool? slot9to10,
    bool? slot10to12,
    bool? slot1to3,
    bool? slot3to5,
    bool? slot5to7,
    bool? slot7to9pm,
  }) =>
      ModelRiderAvailability(
        date: date,
        slot7to9: slot7to9 ?? this.slot7to9,
        slot9to10: slot9to10 ?? this.slot9to10,
        slot10to12: slot10to12 ?? this.slot10to12,
        slot1to3: slot1to3 ?? this.slot1to3,
        slot3to5: slot3to5 ?? this.slot3to5,
        slot5to7: slot5to7 ?? this.slot5to7,
        slot7to9pm: slot7to9pm ?? this.slot7to9pm,
      );

  bool get hasAnySlot =>
      slot7to9 ||
      slot9to10 ||
      slot10to12 ||
      slot1to3 ||
      slot3to5 ||
      slot5to7 ||
      slot7to9pm;

  List<bool> get slotList => [
        slot7to9,
        slot9to10,
        slot10to12,
        slot1to3,
        slot3to5,
        slot5to7,
        slot7to9pm
      ];
}

const List<String> kSlotLabels = [
  '7am-9am',
  '9am-10am',
  '10am-12pm',
  '1pm-3pm',
  '3pm-5pm',
  '5pm-7pm',
  '7pm-9pm',
];
