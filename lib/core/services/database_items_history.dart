import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';

const String ITEMS_HIS_REF = "ItemsHist";

class DatabaseItemsHist {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _suppliesHistRef;

  DatabaseItemsHist() {
    _suppliesHistRef = _firestore
        .collection(ITEMS_HIS_REF)
        .withConverter<SuppliesModelHist>(
            fromFirestore: (s, _) => SuppliesModelHist.fromJson(s.data()!),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getItemsHistory(bool bSel) {
    if (!bSel) {
      return _suppliesHistRef
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    } else {
      return _suppliesHistRef
          .orderBy('ItemId')
          .orderBy('LogDate', descending: true)
          .snapshots();
    }
  }

  Future<QuerySnapshot> getItemsHistoryPaginated(
      {DocumentSnapshot? lastDoc}) async {
    Query query = _suppliesHistRef.orderBy('LogDate', descending: true);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.limit(50).get().withFsTimeout();
  }

  Future<bool> addItemsHist(SuppliesModelHist sMH) async {
    try {
      await _suppliesHistRef.add(sMH).withFsTimeout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
