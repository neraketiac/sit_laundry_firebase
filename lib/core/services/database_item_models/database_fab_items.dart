import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';

class FabItemsService {
  final _ref = FirebaseFirestore.instance.collection('fab_items');

  /// GET ALL ITEMS
  Future<List<OtherItemModel>> getItems() async {
    final snapshot = await _ref.get();

    return snapshot.docs.map((doc) {
      return OtherItemModel.fromJson(
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  /// STREAM (optional if you need realtime updates)
  Stream<List<OtherItemModel>> streamItems() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OtherItemModel.fromJson(
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// INSERT
  Future<OtherItemModel> addItem(OtherItemModel item) async {
    final doc = _ref.doc();

    final newItem = item.coyWith(
      docId: doc.id,
      logDate: Timestamp.now(),
    );

    await doc.set(newItem.toJson());

    return newItem;
  }

  /// UPDATE
  Future<void> updateItem(OtherItemModel item) async {
    final updated = item.coyWith(
      logDate: Timestamp.now(),
    );

    await _ref.doc(updated.docId).update(updated.toJson());
  }

  /// DELETE
  Future<void> deleteItem(String docId) async {
    await _ref.doc(docId).delete();
  }
}
