//Display
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_customer.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/services/database_supplies_history.dart';
import 'package:laundry_firebase/variables/variables.dart';

Container conDisplaySuppliesCurrentVar(
  BuildContext context,
  SuppliesModelHist sMH,
) {
  return Container(
    height: 20,
    color: cWaiting,
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
                "  ${(sMH.itemId == menuOthCashInOutFunds ? "Funds" : getItemName(sMH.itemId, sMH.itemUniqueId))} - (${sMH.currentStocks}) - ${convertTimeStampVar(sMH.logDate)} (${sMH.empId})",
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
                "  ${getItemName(sMH.itemId, sMH.itemUniqueId)}{${customerName(sMH.customerId.toString())}} - (${sMH.currentCounter}) - ${convertTimeStampVar(sMH.logDate)} (${sMH.empId})",
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
