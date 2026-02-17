import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/variables/newvariables/gcashselected_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

class GCashRepository {
  //currentStocks status
  // cash in              double status
  // 0 - pending              .1
  // 1 -
  // 1 - done cash in         1

  // cash out
  // 0 - pending              .1
  // ? - verified cash out    .5
  // 1 - done cash out        1

  late SuppliesModelHist sMHGCash;
  late GCashSelectedRepository gCashSelectedRepository =
      GCashSelectedRepository();

  GCashRepository() {
    reset();
  }

  Future<void> reset() async {
    sMHGCash = finalInitialSuppliesModelHistGlobal;
  }

/////////////////////////////////////////////////////////////
//                          GETTER                         //
//                          MODEL                          //
/////////////////////////////////////////////////////////////

  SuppliesModelHist? getModel() {
    return sMHGCash;
  }

  SuppliesModelHist get sMHGCashData => sMHGCash;

  String get docId => sMHGCash.docId;
  int get countId => sMHGCash.countId;
  int get itemId => sMHGCash.itemId;
  int get itemUniqueId => sMHGCash.itemUniqueId;
  String get itemName => sMHGCash.itemName;
  int get currentCounter => sMHGCash.currentCounter;
  int get currentStocks => sMHGCash.currentStocks;
  Timestamp get logDate => sMHGCash.logDate;
  String get empId => sMHGCash.empId;
  int get customerId => sMHGCash.customerId;
  String get customerName => sMHGCash.customerName;
  String get remarks => sMHGCash.remarks;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBMODEL                       //
  /////////////////////////////////////////////////////////////

  void setModel(SuppliesModelHist value) {
    sMHGCash = value;
  }

  set docId(String value) => sMHGCash.docId = value;
  set countId(int value) => sMHGCash.countId = value;
  set itemId(int value) => sMHGCash.itemId = value;
  set itemUniqueId(int value) => sMHGCash.itemUniqueId = value;
  set itemName(String value) => sMHGCash.itemName = value;
  set currentCounter(int value) => sMHGCash.currentCounter = value;
  set currentStocks(int value) => sMHGCash.currentStocks = value;
  set logDate(Timestamp value) => sMHGCash.logDate = value;
  set empId(String value) => sMHGCash.empId = value;
  set customerId(int value) => sMHGCash.customerId = value;
  set customerName(String value) => sMHGCash.customerName = value;
  set remarks(String value) => sMHGCash.remarks = value;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          SELECTED                       //
  /////////////////////////////////////////////////////////////
  TextEditingController get customerNameVar =>
      gCashSelectedRepository.customerNameVar;

  TextEditingController get customerAmountVar =>
      gCashSelectedRepository.customerAmountVar;

  TextEditingController get remarksVar => gCashSelectedRepository.remarksVar;

  int get selectedFundCode => gCashSelectedRepository.selectedFundCode;

  /////////////////////////////////////////////////////////////
  //                          GETTER                         //
  //                          SELECTED                       //
  /////////////////////////////////////////////////////////////
  set customerNameVar(TextEditingController value) =>
      gCashSelectedRepository.customerNameVar = value;

  set customerAmountVar(TextEditingController value) =>
      gCashSelectedRepository.customerAmountVar = value;

  set remarksVar(TextEditingController value) =>
      gCashSelectedRepository.remarksVar = value;

  set selectedFundCode(int value) =>
      gCashSelectedRepository.selectedFundCode = value;
}
