import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';

class OtherItemsRepository {
  OtherItemsRepository._();
  static final OtherItemsRepository instance = OtherItemsRepository._();

  final List<OtherItemModel> items = [];
  bool _loaded = false;

  Future<void> loadOnce() async {
    if (_loaded) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('other_items')
        .orderBy('ItemName', descending: false)
        .get();

    items.addAll(
      snapshot.docs.map((doc) => OtherItemModel(
            docId: doc.id,
            itemId: doc['ItemId'],
            itemUniqueId: doc['ItemUniqueId'],
            itemName: doc['ItemName'],
            itemPrice: doc['ItemPrice'],
            stocksAlert: doc['StocksAlert'],
            stocksType: doc['StocksType'],
            itemGroup: doc['ItemGroup'],
            logDate: doc['LogDate'],
          )),
    );

    _loaded = true;
  }
}
