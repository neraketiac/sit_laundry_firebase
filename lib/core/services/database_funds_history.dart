import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';

const String FUNDS_HIS_REF =
    "SuppliesHist"; //retain name for collections already in use

class DatabaseFundsHist {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _fundsRef;

  DatabaseFundsHist() {
    _fundsRef =
        _firestore.collection(FUNDS_HIS_REF).withConverter<SuppliesModelHist>(
            fromFirestore: (snapshots, _) => SuppliesModelHist.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getSuppliesHistory(bool bSel) {
    ///int? accCode = mapEmpAccess[empIdGlobal];
    if (!bSel) {
      return _fundsRef

          ///.where('AccessCode', isLessThan: accCode)
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    } else {
      return _fundsRef

          ///.where('AccessCode', isLessThan: accCode)
          .orderBy('ItemId')
          .orderBy('LogDate', descending: true)
          //.limit(50)
          .snapshots();
    }

    //return _fundsRef.snapshots();
  }

  Future<bool> addSuppliesHist(SuppliesModelHist sMH) async {
    bool bSuccess = false;
    await _fundsRef
        .add(sMH)
        .then((value) => {
              print("Funds History Save done."),
              //resetSHGlobalVar(),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${sMH.itemId}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}
