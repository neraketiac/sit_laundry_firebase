//########################### Supplies History ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_supplies_history.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

Widget readDataSuppliesHistory() {
  bool bHeader = true;
  Container conDisplaySuppliesHist(
    BuildContext context,
    SuppliesModelHist sMH,
  ) {
    Container regularContainer() {
      return Container(
        height: 20,
        color: getCOlorSuppliesHistoryPosNeg(sMH),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                          DateFormat('MM/dd HH:mm:ss')
                              .format(sMH.logDate.toDate()),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                          "(₱${value.format(sMH.currentCounter)}/pCF=₱${value.format(sMH.currentStocks)})",
                          style: const TextStyle(fontSize: 11)),
                      SizedBox(
                        width: 2,
                      ),
                      Text(sMH.itemName,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 2,
                      ),
                      Text(ifMenuUniqueIsCashIn(sMH) ? 'to:' : 'by:',
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      Text(sMH.customerName,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 2,
                      ),
                      Text("log:${sMH.empId}",
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      SizedBox(
                        width: 2,
                      ),
                      Text((sMH.remarks.isEmpty ? '' : ":${sMH.remarks}"),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Container fundCheckContainer() {
      return Container(
        height: 20,
        color: getCOlorSuppliesHistoryPosNeg(sMH),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                          DateFormat('MM/dd HH:mm:ss')
                              .format(sMH.logDate.toDate()),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                          "(₱${value.format(sMH.currentCounter)}/pCF=₱${value.format(sMH.currentStocks)})",
                          style: const TextStyle(fontSize: 11)),
                      SizedBox(
                        width: 2,
                      ),
                      Text(sMH.itemName,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 2,
                      ),
                      Text("by:${sMH.empId}",
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      SizedBox(
                        width: 2,
                      ),
                      Text((sMH.remarks.isEmpty ? '' : ":${sMH.remarks}"),
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return (ifMenuUniqueIsEOD(sMH) ? fundCheckContainer() : regularContainer());
  }

  DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
  //read
  return StreamBuilder<QuerySnapshot>(
    stream: databaseSuppliesHist.getSuppliesHistory(false),
    builder: (context, snapshot) {
      List listSMH = snapshot.data?.docs ?? [];
      bHeader = true;
      List<TableRow> rowDatas = [];
      if (listSMH.isNotEmpty) {
        //header
        if (bHeader) {
          var rowData = TableRow(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
              children: [
                // AutoCompleteCustomer(),
                const Text(
                  "Supplies History",
                  style: TextStyle(fontSize: 10),
                ),
              ]);
          rowDatas.add(rowData);

          bHeader = false;
        }

        for (var sMHData in listSMH) {
          SuppliesModelHist sMH = sMHData.data();
          final rowData = TableRow(
              decoration: BoxDecoration(color: Colors.black),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: conDisplaySuppliesHist(context, sMH),
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
