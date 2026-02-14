import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/newservices/database_supplies_history.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

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

    // if (sMH.itemUniqueId == menuOthUniqIdFundsEOD) {
    //   if (sMH.currentCounter < sMH.currentStocks) {
    //     sMH.currentCounter = sMH.currentCounter - sMH.currentStocks;
    //   } else if (sMH.currentCounter > sMH.currentStocks) {
    //     sMH.currentCounter = sMH.currentStocks - sMH.currentCounter;
    //   } else {
    //     sMH.currentCounter = 0;
    //   }
    // }

    //save hist first to display the current stocks before adding the currentcounter
    DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
    await databaseSuppliesHist.addSuppliesHist(sMH);

    //to be used in Supplies Current
    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    alwaysTheLatestFunds = sMH.currentStocks;

    bool bSuccess = false;
    print("Doc id before=${sMH.docId}");

    if (sMH.docId.isNotEmpty) {
      print("Is not empty");
      await updateDocId(sMH);
      // await databaseSuppliesHist.addSuppliesHist(sMH);
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
                // databaseSuppliesHist.addSuppliesHist(sMH),
                bSuccess = true,

                ///insert977GCash(sMH),
              })
          .catchError((error) => {
                print("Failed : $error ${sMH.itemId}"),
                bSuccess = false,
              });
    }

    //insert977GCash(sMH);

    return bSuccess;
  }

  Future<void> insert977GCash(SuppliesModelHist sMH) async {
    if (sMH.itemUniqueId == menuOthUniqIdCashIn) {
      bool bSuccess = false;
      SuppliesModelHist sMH977Gcash = new SuppliesModelHist(
          docId: "",
          countId: 0,
          itemId: menuOth977GCash,
          itemUniqueId: menuOth977GCashOut,
          itemName: '977 GCash Out',
          currentCounter: -1 *
              (sMH.currentCounter), //cash in to customer, cash out to sender
          currentStocks: 0,
          logDate: Timestamp.now(),
          empId: empIdGlobal,
          customerId: 0,
          customerName: '',
          remarks: "auto insert");

      sMH977Gcash = await computeCurrentStocks(sMH977Gcash);

      sMH977Gcash.currentStocks =
          sMH977Gcash.currentStocks + sMH977Gcash.currentCounter;

      if (sMH977Gcash.docId.isNotEmpty) {
        print("Is not empty");
        await updateDocId(sMH977Gcash);
        // await databaseSuppliesHist.addSuppliesHist(sMH);
        bSuccess = true;
      } else {
        print("Is empty");
        await _suppliesCurrRef
            .add(sMH977Gcash)
            .then((value) => {
                  sMH977Gcash.docId = value.id,
                  print("docID${value.id}"),
                  updateDocId(sMH977Gcash),
                  print("Supplies 977 Save done."),

                  // databaseSuppliesHist.addSuppliesHist(sMH),
                  bSuccess = true,
                })
            .catchError((error) => {
                  print("Failed : $error ${sMH977Gcash.itemId}"),
                  bSuccess = false,
                });
      }
    }
    //return bSuccess;
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
