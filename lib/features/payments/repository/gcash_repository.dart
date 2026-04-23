import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/features/payments/repository/gcashselected_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

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
  Timestamp get logDate => gM.logDate;
  String get logBy => gM.logBy;
  Timestamp get completeDate => gM.completeDate;
  String get itemName => gM.itemName;
  int get customerAmount => gM.customerAmount;
  double get gCashStatus => gM.gCashStatus;
  int get customerId => gM.customerId;
  String get customerName => gM.customerName;
  String get customerNumber => gM.customerNumber;
  String get remarks => gM.remarks;
  String get cashInImageUrl => gM.cashInImageUrl;
  String get cashOutImageUrl => gM.cashOutImageUrl;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          JOBMODEL                       //
  /////////////////////////////////////////////////////////////

  void setModel(GCashModel value) {
    gM = value;
    selectedFundCode = value.itemUniqueId;
    selectedFundCode = value.itemUniqueId;
    customerNumberVar.text = value.customerNumber;
    customerNameVar.text = value.customerName;
    customerAmountVar.text = value.customerAmount.toString();
    remarksVar.text = value.remarks;
  }

  set docId(String value) => gM.docId = value;
  set countId(int value) => gM.countId = value;
  set itemId(int value) => gM.itemId = value;
  set logDate(Timestamp value) => gM.logDate = value;
  set logBy(String value) => gM.logBy = value;
  set completeDate(Timestamp value) => gM.completeDate = value;
  set itemUniqueId(int value) => gM.itemUniqueId = value;
  set itemName(String value) => gM.itemName = value;
  set customerAmount(int value) => gM.customerAmount = value;
  set gCashStatus(double value) => gM.gCashStatus = value;
  set customerId(int value) => gM.customerId = value;
  set customerName(String value) => gM.customerName = value;
  set customerNumber(String value) => gM.customerNumber = value;
  set remarks(String value) => gM.remarks = value;
  set cashInImageUrl(String value) => gM.cashInImageUrl = value;
  set cashOutImageUrl(String value) => gM.cashOutImageUrl = value;

  /////////////////////////////////////////////////////////////
  //                          SETTER                         //
  //                          SELECTED                       //
  /////////////////////////////////////////////////////////////
  TextEditingController get customerNameVar =>
      gCashSelectedRepo.customerNameVar;

  TextEditingController get customerNumberVar =>
      gCashSelectedRepo.customerNumberVar;

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

  set customerNumberVar(TextEditingController value) =>
      gCashSelectedRepo.customerNumberVar = value;

  set customerAmountVar(TextEditingController value) =>
      gCashSelectedRepo.customerAmountVar = value;

  set remarksVar(TextEditingController value) =>
      gCashSelectedRepo.remarksVar = value;

  set selectedFundCode(int value) => gCashSelectedRepo.selectedFundCode = value;
}
