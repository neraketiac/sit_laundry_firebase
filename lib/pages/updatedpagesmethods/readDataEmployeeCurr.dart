//########################### Employee ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/services/database_employee_current.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

Widget readDataEmployeeCurr() {
  bool bHeader = true;
  Container conDisplayEmployeeCurr(
    BuildContext context,
    EmployeeModel eM,
  ) {
    return Container(
      height: 22,
      color: cSalaryCurrent,
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
                      " ${eM.empName}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Visibility(
                      visible: (isAdmin ? true : false),
                      child: Text(
                        eM.empId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "₱ ${value.format(eM.currentStocks)}  ",
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

  DatabaseEmployeeCurrent databaseEmployeeCurrent = DatabaseEmployeeCurrent();
  //read
  return StreamBuilder<QuerySnapshot>(
    stream: databaseEmployeeCurrent.get(),
    builder: (context, snapshot) {
      List listEM = snapshot.data?.docs ?? [];
      bHeader = true;
      List<TableRow> rowDatas = [];
      if (listEM.isNotEmpty) {
        //header
        if (bHeader) {
          const rowData = TableRow(
              decoration: BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
              children: [
                Text(
                  "Current Balance",
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
                      child: conDisplayEmployeeCurr(context, eM),
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
