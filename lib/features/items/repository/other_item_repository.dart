import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';

class OtherItemsRepository {
  OtherItemsRepository._();
  static final OtherItemsRepository instance = OtherItemsRepository._();

  final List<OtherItemModel> items = [];

  bool _loaded = false;
  String _loadedCollection = '';

  Future<void> loadOnce({required String collectionName}) async {
    /// prevent reloading same collection
    if (_loaded && _loadedCollection == collectionName) return;

    items.clear();

    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('ItemName', descending: false)
        .get();

    items.addAll(
      snapshot.docs.map((doc) {
        final data = doc.data();

        return OtherItemModel(
          docId: doc.id,
          itemId: data['ItemId'] ?? 0,
          itemUniqueId: data['ItemUniqueId'] ?? 0,
          itemName: data['ItemName'] ?? '',
          itemPrice: data['ItemPrice'] ?? 0,
          stocksAlert: data['StocksAlert'] ?? 0,
          stocksType: data['StocksType'] ?? '',
          itemGroup: data['ItemGroup'] ?? '',
          logDate: data['LogDate'] ?? Timestamp.now(),
        );
      }),
    );

    _loaded = true;
    _loadedCollection = collectionName;
  }
}
