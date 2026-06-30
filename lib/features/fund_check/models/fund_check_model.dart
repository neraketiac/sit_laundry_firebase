import 'package:cloud_firestore/cloud_firestore.dart';

class FundCheckModel {
  final String? id;
  final bool morningCheck;
  final bool lunchCheck;
  final bool dinnerCheck;
  final bool morningEnable;
  final bool lunchEnable;
  final bool dinnerEnable;
  final Timestamp logDate;

  FundCheckModel({
    this.id,
    required this.morningCheck,
    required this.lunchCheck,
    required this.dinnerCheck,
    required this.morningEnable,
    required this.lunchEnable,
    required this.dinnerEnable,
    required this.logDate,
  });

  /// Convert model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'morningCheck': morningCheck,
      'lunchCheck': lunchCheck,
      'dinnerCheck': dinnerCheck,
      'morningEnable': morningEnable,
      'lunchEnable': lunchEnable,
      'dinnerEnable': dinnerEnable,
      'logDate': logDate,
    };
  }

  /// Create model from Firestore document
  factory FundCheckModel.fromJson(Map<String, dynamic> json, String docId) {
    return FundCheckModel(
      id: docId,
      morningCheck: json['morningCheck'] ?? false,
      lunchCheck: json['lunchCheck'] ?? false,
      dinnerCheck: json['dinnerCheck'] ?? false,
      morningEnable: json['morningEnable'] ?? false,
      lunchEnable: json['lunchEnable'] ?? false,
      dinnerEnable: json['dinnerEnable'] ?? false,
      logDate: json['logDate'] ?? Timestamp.now(),
    );
  }

  /// Create a copy of the model with optional field updates
  FundCheckModel copyWith({
    String? id,
    bool? morningCheck,
    bool? lunchCheck,
    bool? dinnerCheck,
    bool? morningEnable,
    bool? lunchEnable,
    bool? dinnerEnable,
    Timestamp? logDate,
  }) {
    return FundCheckModel(
      id: id ?? this.id,
      morningCheck: morningCheck ?? this.morningCheck,
      lunchCheck: lunchCheck ?? this.lunchCheck,
      dinnerCheck: dinnerCheck ?? this.dinnerCheck,
      morningEnable: morningEnable ?? this.morningEnable,
      lunchEnable: lunchEnable ?? this.lunchEnable,
      dinnerEnable: dinnerEnable ?? this.dinnerEnable,
      logDate: logDate ?? this.logDate,
    );
  }

  @override
  String toString() {
    return 'FundCheckModel(id: $id, morningCheck: $morningCheck, lunchCheck: $lunchCheck, dinnerCheck: $dinnerCheck, morningEnable: $morningEnable, lunchEnable: $lunchEnable, dinnerEnable: $dinnerEnable, logDate: $logDate)';
  }
}
