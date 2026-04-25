import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

const String FUNDS_HIS_REF = "SuppliesHist";

class DatabaseFundsHist {
  final _firestore = FirebaseService.suppliesFirestore;
  late final CollectionReference _fundsRef;

  DatabaseFundsHist() {
    _fundsRef = _firestore
        .collection(FUNDS_HIS_REF)
        .withConverter<SuppliesModelHist>(
            fromFirestore: (s, _) => SuppliesModelHist.fromJson(s.data()!),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getSuppliesHistory(bool bSel) {
    if (!bSel) {
      return _fundsRef
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    } else {
      return _fundsRef
          .orderBy('ItemId')
          .orderBy('LogDate', descending: true)
          .snapshots();
    }
  }

  Future<QuerySnapshot> getSuppliesHistoryPaginated(bool bSel,
      {DocumentSnapshot? lastDoc}) async {
    Query query = _fundsRef.orderBy('LogDate', descending: true);
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.limit(50).get().withFsTimeout();
  }

  Future<bool> addSuppliesHist(SuppliesModelHist sMH) async {
    try {
      await _fundsRef.add(sMH).withFsTimeout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
