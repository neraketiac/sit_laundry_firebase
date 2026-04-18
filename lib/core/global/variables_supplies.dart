//Display
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listSuppItems = [];
List<OtherItemModel> listSuppItemsAll = [];

//Supplies Colors
final Color cStocks = Color.fromRGBO(255, 251, 43, 0.452);
final Color cCashOut =
    Color.from(alpha: 1, red: 0.667, green: 0.667, blue: 0.667);
final Color cCashIn = Color.fromRGBO(120, 120, 120, 1);
final Color cCashFee = Color.fromRGBO(120, 120, 120, 1);
final Color cFundsEOD = Color.fromRGBO(62, 255, 45, 1);
final Color cFundsEOD2 = Color.fromRGBO(255, 92, 233, 1);
final Color cFundsEODShaded = Color.fromRGBO(255, 92, 233, 0.7);
final Color cMoneyIn = Color.fromRGBO(177, 177, 177, 1);
final Color cMoneyOut = Color.fromRGBO(113, 113, 113, 1);
final Color cSalaryCurrent = Colors.yellow;
final Color cSalaryIn = Color.fromRGBO(209, 99, 30, 1);
final Color cSalaryOut = Color.fromRGBO(255, 151, 86, 1);

void addListSuppItems() {
  //salary payment
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthSalaryPayment,
    itemGroup: groupOth,
    itemName: "Salary Payment",
    itemPrice: 0,
    stocksAlert: 0,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  //cash out/cash in
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthLaundryPayment,
    itemGroup: groupOth,
    itemName: "Laundry Payment",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdCashIn,
    itemGroup: groupOth,
    itemName: "Cash-In",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdCashOut,
    itemGroup: groupOth,
    itemName: "Cash-Out",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdLoad,
    itemGroup: groupOth,
    itemName: "Load",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdFee,
    itemGroup: groupOth,
    itemName: "Gcash Fee",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdFundsIn,
    itemGroup: groupOth,
    itemName: "Funds-In",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));

  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdFundsOut,
    itemGroup: groupOth,
    itemName: "Funds-Out",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdFundsEOD,
    itemGroup: groupOth,
    itemName: "Funds Check",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));

  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthExpense,
    itemUniqueId: menuOthExpense,
    itemGroup: groupOth,
    itemName: "Laundry Expense",
    itemPrice: 0,
    stocksAlert: -5000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  //plastic
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthPlasticSmall,
  //   itemUniqueId: menuOthPlasticSmall,
  //   itemGroup: groupOth,
  //   itemName: "Plastic(S)",
  //   itemPrice: 0,
  //   stocksAlert: 3,
  //   stocksType: "roll",
  //   logDate: timestamp1900,
  // ));
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthPlasticMedium,
  //   itemUniqueId: menuOthPlasticMedium,
  //   itemGroup: groupOth,
  //   itemName: "Plastic(M)",
  //   itemPrice: 0,
  //   stocksAlert: 3,
  //   stocksType: "roll",
  //   logDate: timestamp1900,
  // ));
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthPlasticLarge,
  //   itemUniqueId: menuOthPlasticLarge,
  //   itemGroup: groupOth,
  //   itemName: "Plastic(L)",
  //   itemPrice: 0,
  //   stocksAlert: 3,
  //   stocksType: "roll",
  //   logDate: timestamp1900,
  // ));
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthPlasticXLarge,
  //   itemUniqueId: menuOthPlasticXLarge,
  //   itemGroup: groupOth,
  //   itemName: "Plastic(XL)",
  //   itemPrice: 0,
  //   stocksAlert: 3,
  //   stocksType: "roll",
  //   logDate: timestamp1900,
  // ));
  //gas
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthLPG50Kilos,
  //   itemUniqueId: menuOthLPG50Kilos,
  //   itemGroup: groupOth,
  //   itemName: "LPG(50)",
  //   itemPrice: 0,
  //   stocksAlert: 0,
  //   stocksType: "tank",
  //   logDate: timestamp1900,
  // ));
  // listSuppItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthLPG11Kilos,
  //   itemUniqueId: menuOthLPG11Kilos,
  //   itemGroup: groupOth,
  //   itemName: "LPG(11)",
  //   itemPrice: 0,
  //   stocksAlert: 1,
  //   stocksType: "tank",
  //   logDate: timestamp1900,
  // ));

  listSuppItemsAll.addAll(listSuppItems);
  //addListSuppItemsAccesOnly();
  addListSuppItemsAll();
}

void addListSuppItemsAll() {
  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOthLaundryPaymentGCash,
    itemUniqueId: menuOthLaundryPaymentGCash,
    itemGroup: groupOth,
    itemName: "Laundry Payment(G)",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));

  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOth977GCash,
    itemUniqueId: menuOth977GCashIn,
    itemGroup: groupOth,
    itemName: "977CashIn",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOth977GCash,
    itemUniqueId: menuOth977GCashOut,
    itemGroup: groupOth,
    itemName: "977CashOut",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOth152GCash,
    itemUniqueId: menuOth152GCashOut,
    itemGroup: groupOth,
    itemName: "152CashIn",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOth152GCash,
    itemUniqueId: menuOth152GCashOut,
    itemGroup: groupOth,
    itemName: "152CashOut",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
  listSuppItemsAll.add(OtherItemModel(
    docId: "",
    itemId: menuOthLPDonP,
    itemUniqueId: menuOthLPDonPCash,
    itemGroup: groupOth,
    itemName: "DonP Cash",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
    logDate: timestamp1900,
  ));
}

Container conRemarksSuppliesVar() {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: TextFormField(
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.start,
      controller: remarksSuppliesVar,
      decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
      validator: (val) {
        remarksSuppliesVar.text = val!;
        return null;
      },
    ),
  );
}
