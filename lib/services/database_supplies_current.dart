import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_supplies_history.dart';
import 'package:laundry_firebase/variables/variables.dart';

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
    return _suppliesCurrRef.snapshots();
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
    print(
        "currentstocks=${sMH.currentStocks} -- currentcounter${sMH.currentCounter} -- countid${sMH.countId}");
    sMH.currentStocks = sMH.currentStocks + sMH.currentCounter;
    print("currentstocks=${sMH.currentStocks}");

    return sMH;
  }

  Future<bool> addSuppliesCurr(SuppliesModelHist sMH) async {
    sMH = await computeCurrentStocks(sMH);
    sMH.empId = empIdGlobal;

    DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();

    bool bSuccess = false;
    print("Doc id before=${sMH.docId}");

    if (sMH.docId.isNotEmpty) {
      print("Is not empty");
      await updateDocId(sMH);
      await databaseSuppliesHist.addSuppliesHist(sMH);
      bSuccess = true;
    } else {
      print("Is empty");
      await _suppliesCurrRef
          .add(sMH)
          .then((value) => {
                sMH.docId = value.id,
                print("docID${value.id}"),
                // updateDocId(SuppliesModelHist(
                //     docId: value.id,
                //     countId: sMH.countId,
                //     itemId: sMH.itemId,
                //     currentCounter: sMH.currentCounter,
                //     currentStocks: sMH.currentStocks,
                //     logDate: sMH.logDate)),

                updateDocId(sMH),
                print("Supplies Current Save done."),

                databaseSuppliesHist.addSuppliesHist(sMH),
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
              print("Update Done updateDocId"),
            })
        .catchError(
          (error) => print("Update Failed : $error"),
        );
  }
}
