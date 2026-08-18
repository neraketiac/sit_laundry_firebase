import 'package:cloud_firestore/cloud_firestore.dart';

class SearchHistoryModel {
  final String docId;
  final String customerId;
  final String customerName;
  final String staffName;
  final String staffId;
  final Timestamp searchedAt;

  SearchHistoryModel({
    required this.docId,
    required this.customerId,
    required this.customerName,
    required this.staffName,
    required this.staffId,
    required this.searchedAt,
  });

  factory SearchHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchHistoryModel(
      docId: doc.id,
      customerId: data['customerId']?.toString() ?? '0',
      customerName: data['customerName'] ?? 'Unknown',
      staffName: data['staffName'] ?? 'Unknown',
      staffId: data['staffId'] ?? 'Unknown',
      searchedAt: data['searchedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'staffName': staffName,
      'staffId': staffId,
      'searchedAt': searchedAt,
    };
  }
}
