//########################### Employee History ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/services/database_employee_hist.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

Widget readDataEmployeeHist() {
  bool bHeader = true;
  Container conDisplayEmployeeHist(
    BuildContext context,
    EmployeeModel eM,
  ) {
    return Container(
      height: 20,
      color: getCOlorEmployeeHistoryPosNeg(eM),
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
                            .format(eM.logDate.toDate()),
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    SizedBox(
                      width: 2,
                    ),
                    Text(eM.itemName,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                        (ifMenuUniqueIsCashInEmp(eM)
                            ? 'to:'
                            : (ifMenuUniqueIsSalaryPayEmp(eM) ? 'to:' : 'by:')),
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    Text(eM.empName,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                        " (amt=₱${value.format(eM.currentCounter)}/pBal=₱${value.format(eM.currentStocks)})",
                        style: const TextStyle(fontSize: 11)),
                    SizedBox(
                      width: 2,
                    ),
                    Text("log:${eM.logBy}",
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    SizedBox(
                      width: 2,
                    ),
                    Text((eM.remarks.isEmpty ? '' : ":${eM.remarks}"),
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    SizedBox(
                      width: 2,
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
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
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
