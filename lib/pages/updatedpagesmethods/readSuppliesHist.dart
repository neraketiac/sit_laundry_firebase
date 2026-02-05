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
    bool bNegative = (sMH.currentCounter < 0 ? true : false);

    Container regularContainer() {
      return Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(255, 89, 89, 89),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            // Time
            Text(
              DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
              style: TextStyle(
                fontSize: 9,
                color: const Color.fromARGB(255, 68, 68, 68),
              ),
            ),
            const SizedBox(width: 4),

            // Amount
            Text(
              "₱${value.format(sMH.currentCounter)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: (bNegative
                    ? Color.fromARGB(255, 185, 57, 48)
                    : Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(width: 4),

            // Main log text
            Expanded(
              child: Text(
                "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName} : ${sMH.remarks}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
            ),

            //log by
            Text(
              sMH.empId,
              style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800]),
            ),

            // Stocks
            Text(
              "pCF ₱${value.format(sMH.currentStocks)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: (bNegative
                    ? Color.fromARGB(255, 185, 57, 48)
                    : Color(0xFF0D47A1)),
              ),
            ),
          ],
        ),
      );
    }

    Container fundCheckContainer() {
      bool bNegative = (sMH.currentCounter < 0 ? true : false);
      return Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
              255, 155, 155, 155), // slightly darker laundry blue
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(255, 89, 89, 89),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            // Time
            Text(
              DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
              style: TextStyle(
                fontSize: 9,
                color: const Color.fromARGB(255, 68, 68, 68),
              ),
            ),
            const SizedBox(width: 4),

            // Amount
            Text(
              "₱${value.format(sMH.currentCounter)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: (bNegative
                    ? Color.fromARGB(255, 185, 57, 48)
                    : Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(width: 4),

            // Main log text
            Expanded(
              child: Text(
                "${sMH.itemName} by ${sMH.empId} : ${sMH.remarks}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
            ),

            // Stocks
            Text(
              " pCF ₱${value.format(sMH.currentStocks)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: (bNegative
                    ? Color.fromARGB(255, 185, 57, 48)
                    : Color(0xFF0D47A1)),
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
