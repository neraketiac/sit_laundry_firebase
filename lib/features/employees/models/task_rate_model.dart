import 'package:cloud_firestore/cloud_firestore.dart';

class TaskRate {
  final int taskId;
  final String label;
  final int rate;
  final Timestamp createdAt;

  TaskRate({
    required this.taskId,
    required this.label,
    required this.rate,
    required this.createdAt,
  });

  factory TaskRate.fromJson(Map<String, dynamic> json) {
    return TaskRate(
      taskId: json['taskId'] as int,
      label: json['label'] as String,
      rate: json['rate'] as int,
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'label': label,
      'rate': rate,
      'createdAt': createdAt,
    };
  }
}
