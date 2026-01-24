//Display
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_det.dart';
import 'package:laundry_firebase/variables/variables_fab.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';

List<OtherItemModel> listSuppItems = [];
List<OtherItemModel> listSuppItemsAll = [];
const int menuOthCashInOutFunds = 422,
    menuOthPlasticSmall = 423,
    menuOthPlasticMedium = 424,
    menuOthPlasticLarge = 425,
    menuOthPlasticXLarge = 426,
    menuOthLPG11Kilos = 427,
    menuOthLPG50Kilos = 428,
    menuOthUniqIdFundsEOD = 429,
    menuOthUniqIdFee = 430,
    menuOthUniqIdLoad = 431,
    menuOthExpense = 432,
    //specialaccess
    menuOth977GCash = 10001,
    menuOth977GCashIn = 10002,
    menuOth977GCashOut = 10003,
    menuOth152GCash = 10011,
    menuOth152GCashIn = 10012,
    menuOth152GCashOut = 10013,
    menuOthLPDonP = 10014,
    menuOthLPDonPCash = 10015,
    menuOthLaundryPaymentGCash = 10016;

//Supplies Colors
final Color cStocks = Color.fromRGBO(255, 251, 43, 0.452);
final Color cCashOut = Color.fromRGBO(170, 170, 170, 1);
final Color cCashIn = Color.fromRGBO(120, 120, 120, 1);
final Color cCashFee = Color.fromRGBO(120, 120, 120, 1);
final Color cFundsEOD = Color.fromRGBO(255, 92, 233, 1);
final Color cFundsEODShaded = Color.fromRGBO(255, 92, 233, 0.3);

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
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthCashInOutFunds,
    itemUniqueId: menuOthUniqIdFundsEOD,
    itemGroup: groupOth,
    itemName: "Funds EOD",
    itemPrice: 0,
    stocksAlert: 1000,
    stocksType: "php",
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
  ));
  //plastic
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthPlasticSmall,
    itemUniqueId: menuOthPlasticSmall,
    itemGroup: groupOth,
    itemName: "Plastic(S)",
    itemPrice: 0,
    stocksAlert: 3,
    stocksType: "roll",
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthPlasticMedium,
    itemUniqueId: menuOthPlasticMedium,
    itemGroup: groupOth,
    itemName: "Plastic(M)",
    itemPrice: 0,
    stocksAlert: 3,
    stocksType: "roll",
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthPlasticLarge,
    itemUniqueId: menuOthPlasticLarge,
    itemGroup: groupOth,
    itemName: "Plastic(L)",
    itemPrice: 0,
    stocksAlert: 3,
    stocksType: "roll",
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthPlasticXLarge,
    itemUniqueId: menuOthPlasticXLarge,
    itemGroup: groupOth,
    itemName: "Plastic(XL)",
    itemPrice: 0,
    stocksAlert: 3,
    stocksType: "roll",
  ));
  //gas
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthLPG50Kilos,
    itemUniqueId: menuOthLPG50Kilos,
    itemGroup: groupOth,
    itemName: "LPG(50)",
    itemPrice: 0,
    stocksAlert: 0,
    stocksType: "tank",
  ));
  listSuppItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthLPG11Kilos,
    itemUniqueId: menuOthLPG11Kilos,
    itemGroup: groupOth,
    itemName: "LPG(11)",
    itemPrice: 0,
    stocksAlert: 1,
    stocksType: "tank",
  ));

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
  ));
}

void addListSuppItemsAccesOnly() {
  if (displayInList(menuOth977GCashIn)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthLaundryPaymentGCash,
      itemUniqueId: menuOthLaundryPaymentGCash,
      itemGroup: groupOth,
      itemName: "Laundry Payment(G)",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
  if (displayInList(menuOth977GCashIn)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth977GCash,
      itemUniqueId: menuOth977GCashIn,
      itemGroup: groupOth,
      itemName: "977CashIn",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
  if (displayInList(menuOth977GCashOut)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth977GCash,
      itemUniqueId: menuOth977GCashOut,
      itemGroup: groupOth,
      itemName: "977CashOut",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
  if (displayInList(menuOth152GCashOut)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth152GCash,
      itemUniqueId: menuOth152GCashOut,
      itemGroup: groupOth,
      itemName: "152CashIn",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
  if (displayInList(menuOth152GCashOut)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth152GCash,
      itemUniqueId: menuOth152GCashOut,
      itemGroup: groupOth,
      itemName: "152CashOut",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
  if (displayInList(menuOthLPDonPCash)) {
    listSuppItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthLPDonP,
      itemUniqueId: menuOthLPDonPCash,
      itemGroup: groupOth,
      itemName: "DonP Cash",
      itemPrice: 0,
      stocksAlert: 1000,
      stocksType: "php",
    ));
  }
}

Color getCOlorSuppliesHistoryVar(SuppliesModelHist sMH) {
  if (sMH.itemId == menuOthCashInOutFunds) {
    if (ifMenuUniqueIsCashIn(sMH)) {
      return cCashIn;
    } else if (ifMenuUniqueIsCashOut(sMH)) {
      return cCashOut;
    } else if (ifMenuUniqueIsLaundryPayment(sMH)) {
      return cRiderPickup;
    } else if (ifMenuUniqueIsLPaymentGCash(sMH)) {
      return cRiderPickup;
    } else if (sMH.itemUniqueId == menuOthUniqIdFundsEOD) {
      return cFundsEOD;
    } else if (ifMenuUniqueIsFundsIn(sMH)) {
      return cCashIn;
    } else if (ifMenuUniqueIsFundsOut(sMH)) {
      return cCashOut;
    } else if (ifMenuUniqueIsFee(sMH)) {
      return cCashFee;
    }
  }

  return cStocks;
}

Container conDisplaySuppliesCurrentVar(
  BuildContext context,
  SuppliesModelHist sMH,
) {
  return Container(
    height: 22,
    color: (sMH.currentStocks <=
            getItemNameStocksAlert(sMH.itemId, sMH.itemUniqueId)
        ? cRiderPickup
        : cWaiting),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            //mainAxisSize: MainAxisSize.max,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2,
              ),
              // Text(
              //   "  ${(sMH.itemId == menuOthCashInOutFunds ? "Funds" : getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} - (${sMH.currentStocks} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)}) (${sMH.empId})",
              //   style: const TextStyle(
              //     fontSize: 10,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.end,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (sMH.itemId == menuOth977GCash
                        ? " 997Gcash "
                        : (sMH.itemId == menuFabWKLDValPinkDVal
                            ? "  Fab WKL(Pnk)"
                            : (sMH.itemId == menuFabWKLDValGreenDVal
                                ? "  Fab WKL(Grn)"
                                : (sMH.itemId == menuDetWKL
                                    ? "  Det WKL"
                                    : (sMH.itemId == menuFabWKLDValPurpleDVal
                                        ? "  Fab WKL(Ppl)"
                                        : (sMH.itemId == menuOthCashInOutFunds
                                            ? "  Funds"
                                            : "  ${getItemNameOnly(sMH.itemId, sMH.itemUniqueId)}")))))),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "(${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)})",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${value.format(sMH.currentStocks)}  ",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Container conDisplaySuppliesHistoryVar(
  BuildContext context,
  SuppliesModelHist sMH,
) {
  return Container(
    height: 20,
    color: getCOlorSuppliesHistoryVar(
        sMH), //(sMH.itemId == menuOthCashInOutFunds ? cWaiting : cNasaCustomerNa),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(" ${convertTimeStampVar(sMH.logDate)} ",
                      style: const TextStyle(
                        fontSize: 10,
                      )),
                  Text(getItemNameOnlyTest(sMH.itemId, sMH.itemUniqueId),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                      " (${value.format(sMH.currentCounter)}/${value.format(sMH.currentStocks)}) ",
                      style: const TextStyle(fontSize: 11)),
                  Text("by:{${customerName(sMH.customerId.toString())}} ",
                      style: const TextStyle(
                        fontSize: 10,
                      )),
                  Text("log:{${sMH.empId}}",
                      style: const TextStyle(
                        fontSize: 10,
                      )),
                  Text(":${sMH.remarks}",
                      style: const TextStyle(
                        fontSize: 10,
                      )),
                ],
              ),
              // Text(
              //   "  ${convertTimeStampVar(sMH.logDate)} ${getItemNameOnly(sMH.itemId, sMH.itemUniqueId)} (${sMH.currentCounter}/${sMH.currentStocks}) by:{${customerName(sMH.customerId.toString())}} log:{${sMH.empId}}",
              //   style: const TextStyle(
              //     fontSize: 10,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.end,
              // ),
            ],
          ),
        ),
      ],
    ),
  );
}

//insert new Supplies
Future<bool> insertDataSuppliesHistVar(SuppliesModelHist sMH) async {
  // DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();

  sMH.logDate = Timestamp.now();
  //one record only, just show remarks the details
  if (ifMenuUniqueIsCashIn(sMH)) {
    var iFee = getFee(sMH.currentCounter);
    if (bNagbigayFee) {
      sMH.remarks =
          "${sMH.remarks} CI=${sMH.currentCounter} Fee=$iFee"; // 210, CI=200 Fee=10
      //sMH.currentCounter = sMH.currentCounter + iFee;
    } else {
      sMH.remarks =
          "${sMH.remarks} CI=${sMH.currentCounter - iFee} Fee=$iFee"; // 200, CI=190 Fee=10
    }
  } else if (ifMenuUniqueIsCashOut(sMH)) {
    // negative currentCounter
    var iFee = getFee(sMH.currentCounter);
    //sMH.currentCounter = sMH.currentCounter + iFee;
    sMH.remarks =
        "${sMH.remarks} CO=${sMH.currentCounter} Fee=$iFee"; //-200, CO=-190 Fee=10
  }

  return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  //double entry start
  /*
  if (sMH.itemUniqueId == menuOthUniqIdCashIn) {
    var iFee = getFee(sMH.currentCounter);
    if (bNagbigayFee) {
      await databaseSuppliesCurrent.addSuppliesCurr(sMH);
    } else {
      sMH.currentCounter = sMH.currentCounter - iFee;
      await databaseSuppliesCurrent.addSuppliesCurr(sMH);
    }
    sMH.currentCounter = iFee;
    sMH.itemUniqueId = menuOthUniqIdFee;
    return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  } else {
    return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  }
  */
  //double entry end
}

int getFee(int price) {
  var iPrice = (price < 0 ? (price * -1) : price);

  if (iPrice <= 1000) {
    if (iPrice <= 750) {
      if (iPrice <= 500) {
        if (iPrice <= 100) {
          return 5;
        }
        return 10;
      }
      return 15;
    }
    return 20;
  } else {
    if (iPrice % 500 == 0) {
      return ((iPrice ~/ 500) * 10);
    } else {
      return (((iPrice ~/ 500) + 1) * 10);
    }
  }
}

Container conRemarksSuppliesVar(Function setState) {
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
      },
    ),
  );
}
