import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';
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

  late GCashModel gM;
  late GCashSelectedRepository gCashSelectedRepo = GCashSelectedRepository();

  GCashRepository() {
    reset();
  }

  Future<void> reset() async {
    gM = finalGCashModel;
  }

/////////////////////////////////////////////////////////////
//                          GETTER                         //
//                          MODEL                          //
/////////////////////////////////////////////////////////////

  GCashModel? getModel() {
    return gM;
  }

  GCashModel get gMData => gM;

  String get docId => gM.docId;
  int get countId => gM.countId;
  int get itemId => gM.itemId;
  int get itemUniqueId => gM.itemUniqueId;
  String get itemName => gM.itemName;
  int get currentCounter => gM.currentCounter;
  int get currentStocks => gM.currentStocks;
  Timestamp get logDate => gM.logDate;
  String get empId => gM.empId;
  int get customerId => gM.customerId;
  String get customerName => gM.customerName;
  String get remarks => gM.remarks;
  String? get imageUrl => gM.imageUrl;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBMODEL                       //
  /////////////////////////////////////////////////////////////

  void setModel(GCashModel value) {
    gM = value;
  }

  set docId(String value) => gM.docId = value;
  set countId(int value) => gM.countId = value;
  set itemId(int value) => gM.itemId = value;
  set itemUniqueId(int value) => gM.itemUniqueId = value;
  set itemName(String value) => gM.itemName = value;
  set currentCounter(int value) => gM.currentCounter = value;
  set currentStocks(int value) => gM.currentStocks = value;
  set logDate(Timestamp value) => gM.logDate = value;
  set empId(String value) => gM.empId = value;
  set customerId(int value) => gM.customerId = value;
  set customerName(String value) => gM.customerName = value;
  set remarks(String value) => gM.remarks = value;
  set imageUrl(String? value) => gM.imageUrl = value;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          SELECTED                       //
  /////////////////////////////////////////////////////////////
  TextEditingController get customerNameVar =>
      gCashSelectedRepo.customerNameVar;

  TextEditingController get customerAmountVar =>
      gCashSelectedRepo.customerAmountVar;

  TextEditingController get remarksVar => gCashSelectedRepo.remarksVar;

  int get selectedFundCode => gCashSelectedRepo.selectedFundCode;

  /////////////////////////////////////////////////////////////
  //                          GETTER                         //
  //                          SELECTED                       //
  /////////////////////////////////////////////////////////////
  set customerNameVar(TextEditingController value) =>
      gCashSelectedRepo.customerNameVar = value;

  set customerAmountVar(TextEditingController value) =>
      gCashSelectedRepo.customerAmountVar = value;

  set remarksVar(TextEditingController value) =>
      gCashSelectedRepo.remarksVar = value;

  set selectedFundCode(int value) => gCashSelectedRepo.selectedFundCode = value;
}
