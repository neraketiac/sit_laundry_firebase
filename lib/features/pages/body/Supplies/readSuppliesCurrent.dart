//########################### Supplies Current ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

Widget readDataSuppliesCurrent() {
  bool bHeader = true;

  Container conDisplaySuppliesCurr(
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
              children: [
                SizedBox(
                  height: 2,
                ),
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
                      "₱ ${value.format(sMH.currentStocks)}  ",
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

  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
  //read
  return StreamBuilder<QuerySnapshot>(
    stream: databaseSuppliesCurrent.getSuppliesCurrent(),
    builder: (context, snapshot) {
      List listSMH = snapshot.data?.docs ?? [];
      bHeader = true;
      List<TableRow> rowDatas = [];
      if (listSMH.isNotEmpty) {
        //header
        if (bHeader) {
          const rowData = TableRow(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              children: [
                Text(
                  "Supplies Current",
                  style: TextStyle(fontSize: 10),
                ),
              ]);
          rowDatas.add(rowData);
          bHeader = false;
        }

        for (var sMHData in listSMH) {
          SuppliesModelHist sMH = sMHData.data();
          if (sMH.itemId == menuOthCashInOutFunds) {
            alwaysTheLatestFunds = sMH.currentStocks;
          }
          final rowData = TableRow(
              decoration: BoxDecoration(color: Colors.black),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: conDisplaySuppliesCurr(context, sMH),
                    ),
                  ),
                )
              ]);

          rowDatas.add(rowData);
        }
      }

      return Table(
        children: rowDatas,
      );
    },
  );
}
