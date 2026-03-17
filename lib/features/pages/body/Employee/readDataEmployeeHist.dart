//########################### Employee History ###############################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_hist.dart';


/// STATE
List<EmployeeModel> sortedEmployeeHistory = [];
DocumentSnapshot? lastEmployeeHistoryDoc;
bool loadingEmployeeHistory = false;
bool hasMoreEmployeeHistory = true;

final DatabaseEmployeeHist dbEmployeeHist = DatabaseEmployeeHist();

/// LOAD PAGE
Future<void> loadMoreEmployeeHistory(VoidCallback refresh) async {
  if (loadingEmployeeHistory || !hasMoreEmployeeHistory) return;

  loadingEmployeeHistory = true;

  final snapshot = await dbEmployeeHist.getEmployeeHistoryPaginated(
      lastDoc: lastEmployeeHistoryDoc);

  if (snapshot.docs.isEmpty) {
    hasMoreEmployeeHistory = false;
  } else {
    final employees = snapshot.docs.map((doc) {
      return doc.data() as EmployeeModel;
    }).toList();

    sortedEmployeeHistory.addAll(employees);
    lastEmployeeHistoryDoc = snapshot.docs.last;
  }

  loadingEmployeeHistory = false;
  refresh();
}

Widget _buildEmployeeRow(EmployeeModel eM) {
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
        Text(
          DateFormat('MM/dd hh:mm a').format(eM.logDate.toDate()),
          style: TextStyle(
            fontSize: 9,
            color: const Color.fromARGB(255, 68, 68, 68),
          ),
        ),
        const SizedBox(width: 4),
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
        Text(
          eM.logBy,
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
        ),
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

Widget readDataEmployeeHist() {
  return StatefulBuilder(
    builder: (context, setState) {
      /// load first page
      if (sortedEmployeeHistory.isEmpty && !loadingEmployeeHistory) {
        loadMoreEmployeeHistory(() => setState(() {}));
      }

      if (sortedEmployeeHistory.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("👤📊 EMPLOYEE HISTORY",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedEmployeeHistory.length +
                  (hasMoreEmployeeHistory ? 1 : 0),
              itemBuilder: (context, index) {
                /// pagination trigger
                if (index == sortedEmployeeHistory.length - 1) {
                  loadMoreEmployeeHistory(() => setState(() {}));
                }

                if (index == sortedEmployeeHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final eM = sortedEmployeeHistory[index];
                return SizedBox(
                  height: 24,
                  child: _buildEmployeeRow(eM),
                );
              },
            ),
          ),
          if (loadingEmployeeHistory)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    },
  );
}
