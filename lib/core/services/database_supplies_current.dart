import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/services/database_items_history.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

const String SUPPLIES_CURR_REF = "SuppliesCurr";

class DatabaseSuppliesCurrent {
  final _firestore = FirebaseService.suppliesFirestore;
  late final CollectionReference _suppliesCurrRef;

  DatabaseSuppliesCurrent() {
    _suppliesCurrRef = _firestore
        .collection(SUPPLIES_CURR_REF)
        .withConverter<SuppliesModelHist>(
            fromFirestore: (s, _) => SuppliesModelHist.fromJson(s.data()!),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getSuppliesCurrent() {
    return _suppliesCurrRef.orderBy('LogDate', descending: true).snapshots();
  }

  Future<SuppliesModelHist> computeCurrentStocks(SuppliesModelHist sMH) async {
    final snap = await FirebaseService.suppliesFirestore
        .collection('SuppliesCurr')
        .where('ItemId', isEqualTo: sMH.itemId)
        .get()
        .withFsTimeout();
    for (var doc in snap.docs) {
      sMH.currentStocks = doc['CurrentStocks'];
      sMH.countId = doc['CountId'] + 1;
      sMH.docId = doc['DocId'];
      break;
    }
    return sMH;
  }

  /// Throws on failure — caller handles error display via FsHandler.
  Future<void> addSuppliesCurr(SuppliesModelHist sMH) async {
    sMH = await computeCurrentStocks(sMH);
    if (ifMenuUniqueIsEOD(sMH)) {
      if (sMH.currentCounter < sMH.currentStocks) {
        sMH.currentCounter = -1 * (sMH.currentStocks - sMH.currentCounter);
      } else if (sMH.currentCounter > sMH.currentStocks) {
        sMH.currentCounter = sMH.currentCounter - sMH.currentStocks;
      } else {
        sMH.currentCounter = 0;
      }
    }
    sMH.empId = empIdGlobal;

    await DatabaseFundsHist().addSuppliesHist(sMH);

    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    alwaysTheLatestFunds = sMH.currentStocks;

    if (sMH.docId.isNotEmpty) {
      await updateDocId(sMH);
    } else {
      final ref = await _suppliesCurrRef.add(sMH).withFsTimeout();
      sMH.docId = ref.id;
      await updateDocId(sMH);
    }
  }

  /// Throws on failure — caller handles error display via FsHandler.
  Future<void> addItemsCurr(SuppliesModelHist sMH) async {
    sMH = await computeCurrentStocks(sMH);

    await DatabaseItemsHist().addItemsHist(sMH);

    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    alwaysTheLatestFunds = sMH.currentStocks;

    if (sMH.docId.isNotEmpty) {
      await updateDocId(sMH);
    } else {
      final ref = await _suppliesCurrRef.add(sMH).withFsTimeout();
      sMH.docId = ref.id;
      await updateDocId(sMH);
    }
  }

  Future<void> updateDocId(SuppliesModelHist sMH) async {
    await _suppliesCurrRef.doc(sMH.docId).update(sMH.toJson()).withFsTimeout();
  }
}
