import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

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
              //add977GCashSuppliesHist(sMH),
              print("Supplies History Save done."),
              //resetSHGlobalVar(),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${sMH.itemId}"),
              bSuccess = false,
            });
    return bSuccess;
  }

  Future<void> add977GCashSuppliesHist(SuppliesModelHist sMH) async {
    if (sMH.itemUniqueId == menuOthUniqIdCashIn) {
      SuppliesModelHist sMH977Gcash = new SuppliesModelHist(
          docId: sMH.docId,
          countId: sMH.countId,
          itemId: menuOth977GCash,
          itemUniqueId: menuOth977GCashOut,
          itemName: '977 GCash Out',
          currentCounter: -1 *
              (sMH.currentCounter), //cash in to customer, cash out to sender
          currentStocks: sMH.currentStocks,
          logDate: Timestamp.now(),
          empId: empIdGlobal,
          customerId: 0,
          customerName: '',
          remarks: "auto insert");

      await _suppliesHistRef
          .add(sMH977Gcash)
          .then((value) => {
                print("Supplies History Save done 977Gcash."),
                resetSHGlobalVar(),
              })
          .catchError((error) => {
                print("Failed : $error ${sMH977Gcash.itemId}"),
              });
    }
  }
}
