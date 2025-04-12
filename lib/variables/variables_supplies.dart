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
                    (sMH.itemId == menuFabWKLDValPinkDVal
                        ? "  Fab WKL(Pnk)"
                        : (sMH.itemId == menuFabWKLDValGreenDVal
                            ? "  Fab WKL(Grn)"
                            : (sMH.itemId == menuDetWKL
                                ? "  Det WKL"
                                : (sMH.itemId == menuFabWKLDValPurpleDVal
                                    ? "  Fab WKL(Ppl)"
                                    : (sMH.itemId == menuOthCashInOutFunds
                                        ? "  Funds"
                                        : "  ${getItemNameOnly(sMH.itemId, sMH.itemUniqueId)}"))))),
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
                    "${sMH.currentStocks}  ",
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
    color: cNasaCustomerNa,
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
              Text(
                "  ${convertTimeStampVar(sMH.logDate)} ${getItemName(sMH.itemId, sMH.itemUniqueId)}{${customerName(sMH.customerId.toString())}} - (${sMH.currentCounter}/${sMH.currentStocks}) - (${sMH.empId})",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

//insert new Supplies
// void insertDataSuppliesHistVar() {
Future<bool> insertDataSuppliesHistVar(SuppliesModelHist sMH) async {
  // DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();

  sMH.logDate = Timestamp.now();

  return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
}

void addListSuppItems() {
  //cash out/cash in
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
}
