//########################### Employee History ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/services/database_employee_hist.dart';
import 'package:laundry_firebase/variables/variables.dart';

Widget readDataEmployeeHist() {
  bool bHeader = true;
  Container conDisplayEmployeeHist(
    BuildContext context,
    EmployeeModel eM,
  ) {
    bool bNegative = (eM.currentCounter < 0 ? true : false);
    bool bNegativePCF = (eM.currentStocks < 0 ? true : false);
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
            DateFormat('MM/dd hh:mm a').format(eM.logDate.toDate()),
            style: TextStyle(
              fontSize: 9,
              color: const Color.fromARGB(255, 68, 68, 68),
            ),
          ),
          const SizedBox(width: 4),

          // Amount
          Text(
            "₱${value.format(eM.currentCounter)}",
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
              "${eM.itemName} ${ifMenuUniqueIsCashInEmp(eM) ? 'to' : 'by'} ${eM.empName} : ${eM.remarks}",
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
            eM.logBy,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),

          // Stocks
          Text(
            "pCF ₱${value.format(eM.currentStocks)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (bNegativePCF
                  ? Color.fromARGB(255, 185, 57, 48)
                  : Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }

  DatabaseEmployeeHist databaseEmployeeHist = DatabaseEmployeeHist();
  //read
  return StreamBuilder<QuerySnapshot>(
    stream: databaseEmployeeHist.getEmployeeHistory(),
    builder: (context, snapshot) {
      List listEM = snapshot.data?.docs ?? [];
      bHeader = true;
      List<TableRow> rowDatas = [];
      if (listEM.isNotEmpty) {
        //header
        if (bHeader) {
          var rowData = TableRow(
              decoration: BoxDecoration(color: Colors.grey),
              children: [
                // AutoCompleteCustomer(),
                const Text(
                  "History",
                  style: TextStyle(fontSize: 10),
                ),
              ]);
          rowDatas.add(rowData);

          bHeader = false;
        }

        for (var eMData in listEM) {
          EmployeeModel eM = eMData.data();
          final rowData = TableRow(
              decoration: BoxDecoration(color: Colors.black),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: conDisplayEmployeeHist(context, eM),
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
