import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/variables/variables.dart';

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

  Stream<QuerySnapshot> getSuppliesHistory(bool bSel) {
    ///int? accCode = mapEmpAccess[empIdGlobal];
    if (!bSel) {
      return _suppliesHistRef

          ///.where('AccessCode', isLessThan: accCode)
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    } else {
      return _suppliesHistRef

          ///.where('AccessCode', isLessThan: accCode)
          .orderBy('ItemId')
          .orderBy('LogDate', descending: true)
          //.limit(50)
          .snapshots();
    }

    //return _suppliesHistRef.snapshots();
  }

  Future<bool> addSuppliesHist(SuppliesModelHist sMH) async {
    bool bSuccess = false;
    await _suppliesHistRef
        .add(sMH)
        .then((value) => {
              print("Supplies History Save done."),
              resetSHGlobalVar(),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${sMH.itemId}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}
