import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';

const String SUPPLIES_HIS_REF = "SuppliesHist";

class DatabaseSuppliesHist {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _suppliesHistRef;

  DatabaseSuppliesHist() {
    _suppliesHistRef = _firestore
        .collection(SUPPLIES_HIS_REF)
        .withConverter<SuppliesModelHist>(
            fromFirestore: (snapshots, _) => SuppliesModelHist.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getSuppliesHistory() {
    return _suppliesHistRef.snapshots();
  }

  Future<bool> addSuppliesHist(SuppliesModelHist sMH) async {
    bool bSuccess = false;
    await _suppliesHistRef
        .add(sMH)
        .then((value) => {
              print("Supplies Save done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${sMH.itemId}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}
