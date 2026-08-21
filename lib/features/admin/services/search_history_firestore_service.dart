import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/admin/models/search_history_model.dart';

class SearchHistoryFirestoreService {
  static final SearchHistoryFirestoreService _instance =
      SearchHistoryFirestoreService._internal();

  factory SearchHistoryFirestoreService() => _instance;

  SearchHistoryFirestoreService._internal();

  static const String _collectionName = 'search_history';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a successful search to Firestore
  Future<void> saveSearchHistory({
    required int customerId,
    required String customerName,
    required String staffName,
    required String staffId,
  }) async {
    try {
      await _firestore.collection(_collectionName).add({
        'customerId': customerId,
        'customerName': customerName,
        'staffName': staffName,
        'staffId': staffId,
        'searchedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  /// Get all search history (latest first)
  Stream<List<SearchHistoryModel>> getSearchHistoryStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('searchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get search history with pagination (returns items and last document for cursor)
  Future<List<SearchHistoryModel>> getSearchHistoryPage({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('searchedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting search history page: $e');
      return [];
    }
  }

  /// Get search history with pagination (returns items and last document snapshot)
  Future<Map<String, dynamic>> getSearchHistoryPageWithDoc({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .orderBy('searchedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final items = snapshot.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();

      return {
        'items': items,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print('Error getting search history page with doc: $e');
      return {
        'items': <SearchHistoryModel>[],
        'lastDocument': null,
      };
    }
  }

  /// Get search history for a specific date
  Future<List<SearchHistoryModel>> getSearchHistoryByDate(DateTime date) async {
    try {
      final startOfDay =
          Timestamp.fromDate(DateTime(date.year, date.month, date.day));
      final endOfDay = Timestamp.fromDate(
          DateTime(date.year, date.month, date.day, 23, 59, 59));

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('searchedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('searchedAt', isLessThanOrEqualTo: endOfDay)
          .orderBy('searchedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting search history by date: $e');
      return [];
    }
  }

  /// Get search history for a specific staff member
  Future<List<SearchHistoryModel>> getSearchHistoryByStaff(
      String staffId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('staffId', isEqualTo: staffId)
          .orderBy('searchedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SearchHistoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting search history by staff: $e');
      return [];
    }
  }

  /// Get search count for a specific customer
  Future<int> getSearchCountForCustomer(int customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('customerId', isEqualTo: customerId.toString())
          .get();

      return snapshot.size;
    } catch (e) {
      print('Error getting search count: $e');
      return 0;
    }
  }

  /// Delete a search history entry
  Future<void> deleteSearchHistory(String docId) async {
    try {
      await _firestore.collection(_collectionName).doc(docId).delete();
    } catch (e) {
      print('Error deleting search history: $e');
    }
  }

  /// Clear all search history (use with caution)
  Future<void> clearAllSearchHistory() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }
}
