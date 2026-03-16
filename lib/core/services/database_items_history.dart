import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';

const String ITEMS_HIS_REF = "ItemsHist";

class DatabaseItemsHist {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _suppliesHistRef;

  DatabaseItemsHist() {
    _suppliesHistRef =
        _firestore.collection(ITEMS_HIS_REF).withConverter<SuppliesModelHist>(
            fromFirestore: (snapshots, _) => SuppliesModelHist.fromJson(
                  snapshots.data()!,
                ),
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

  Future<bool> addItemsHist(SuppliesModelHist sMH) async {
    bool bSuccess = false;
    await _suppliesHistRef
        .add(sMH)
        .then((value) => {
              print("Items History Save done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${sMH.itemId}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}
