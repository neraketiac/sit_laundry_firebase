import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/services/database_items_history.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

const String SUPPLIES_CURR_REF = "SuppliesCurr";

class DatabaseSuppliesCurrent {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _suppliesCurrRef;

  DatabaseSuppliesCurrent() {
    _suppliesCurrRef = _firestore
        .collection(SUPPLIES_CURR_REF)
        .withConverter<SuppliesModelHist>(
            fromFirestore: (snapshots, _) => SuppliesModelHist.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (sMH, _) => sMH.toJson());
  }

  Stream<QuerySnapshot> getSuppliesCurrent() {
    return _suppliesCurrRef.orderBy('LogDate', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getFundsCurrentOnly() {
    return _suppliesCurrRef
        .where('ItemId', isEqualTo: menuOthCashInOutFunds)
        .snapshots();
  }

  Future<SuppliesModelHist> computeCurrentStocks(SuppliesModelHist sMH) async {
    // _suppliesCurrRef --if reuse, will not work
    var collectionRef = FirebaseFirestore.instance
        .collection('SuppliesCurr')
        .where('ItemId', isEqualTo: sMH.itemId);
    var querySnapshots = await collectionRef.get();
    // var querySnapshots = await _suppliesCurrRef.get();  --if reuse, will not work
    print("Size=${querySnapshots.size}");
    for (var doc in querySnapshots.docs) {
      print("${doc['ItemId']} itemid getAndUpdate");
      sMH.currentStocks = doc['CurrentStocks'];
      sMH.countId = doc['CountId'] + 1;
      sMH.docId = doc['DocId'];
      break;
    }
    // print(
    //     "currentstocks=${sMH.currentStocks} -- currentcounter${sMH.currentCounter} -- countid${sMH.countId}");
    // sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    // print("currentstocks=${sMH.currentStocks}");

    return sMH;
  }

  Future<bool> addSuppliesCurr(SuppliesModelHist sMH) async {
    sMH = await computeCurrentStocks(sMH);
    //for EOD
    if (ifMenuUniqueIsEOD(sMH)) {
      if (sMH.currentCounter < sMH.currentStocks) {
        sMH.currentCounter = -1 * (sMH.currentStocks - sMH.currentCounter);
      } else if (sMH.currentCounter > sMH.currentStocks) {
        sMH.currentCounter = (sMH.currentCounter - sMH.currentStocks);
      } else {
        sMH.currentCounter = 0;
      }
    }
    // //for EOD
    sMH.empId = empIdGlobal;

    //save hist first to display the current stocks before adding the currentcounter
    DatabaseFundsHist dbFundsHist = DatabaseFundsHist();
    await dbFundsHist.addSuppliesHist(sMH);

    //to be used in Supplies Current
    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    alwaysTheLatestFunds = sMH.currentStocks;

    bool bSuccess = false;
    print("Doc id before=${sMH.docId}");

    if (sMH.docId.isNotEmpty) {
      print("Is not empty");
      await updateDocId(sMH);
      bSuccess = true;
    } else {
      print("Is empty");
      await _suppliesCurrRef
          .add(sMH)
          .then((value) => {
                sMH.docId = value.id,
                print("docID${value.id}"),
                updateDocId(sMH),
                print("Supplies Current Save done...."),
                bSuccess = true,
              })
          .catchError((error) => {
                print("Failed : $error ${sMH.itemId}"),
                bSuccess = false,
              });
    }

    return bSuccess;
  }

  Future<bool> addItemsCurr(SuppliesModelHist sMH) async {
    sMH = await computeCurrentStocks(sMH);

    //save hist first to display the current stocks before adding the currentcounter
    DatabaseItemsHist dbFundsHist = DatabaseItemsHist();
    await dbFundsHist.addItemsHist(sMH);

    //to be used in Supplies Current
    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    alwaysTheLatestFunds = sMH.currentStocks;

    bool bSuccess = false;
    print("Doc id before=${sMH.docId}");

    if (sMH.docId.isNotEmpty) {
      print("Is not empty");
      await updateDocId(sMH);
      bSuccess = true;
    } else {
      print("Is empty");
      await _suppliesCurrRef
          .add(sMH)
          .then((value) => {
                sMH.docId = value.id,
                print("docID${value.id}"),
                updateDocId(sMH),
                print("Supplies Current Save done...."),
                bSuccess = true,
              })
          .catchError((error) => {
                print("Failed : $error ${sMH.itemId}"),
                bSuccess = false,
              });
    }

    return bSuccess;
  }

  Future<void> updateDocId(SuppliesModelHist sMH) async {
    await _suppliesCurrRef
        .doc(sMH.docId)
        .update(sMH.toJson())
        .then((value) => {
              print("Update Done updateDocId database_jobsonqueuefbmodel"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }
}
