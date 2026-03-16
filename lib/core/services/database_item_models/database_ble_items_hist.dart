import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';

class BleItemsServiceHist {
  final _ref = FirebaseFirestore.instance.collection('ble_items_hist');

  /// GENERIC LOGGER
  Future<void> logAction(
    OtherItemModel item,
    String actionType,
  ) async {
    final doc = _ref.doc();

    final data = item
        .coyWith(
          docId: doc.id,
          logDate: Timestamp.now(),
        )
        .toJson();

    data['ActionType'] = actionType;

    await doc.set(data);
  }

  /// INSERT LOG
  Future<void> logInsert(OtherItemModel item) async {
    await logAction(item, "insert");
  }

  /// UPDATE LOG
  Future<void> logUpdate(OtherItemModel item) async {
    await logAction(item, "update");
  }

  /// DELETE LOG
  Future<void> logDelete(OtherItemModel item) async {
    await logAction(item, "delete");
  }
}
