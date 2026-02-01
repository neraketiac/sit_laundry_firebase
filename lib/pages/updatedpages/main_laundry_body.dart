import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_employee_current.dart';
import 'package:laundry_firebase/services/database_employee_hist.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/services/database_supplies_history.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_det.dart';
import 'package:laundry_firebase/variables/variables_fab.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

class MyMainLaundryBody extends StatefulWidget {
  final String empidClass;

  const MyMainLaundryBody(this.empidClass, {super.key});

  @override
  State<MyMainLaundryBody> createState() => _MyMainLaundryBodyState();
}

class _MyMainLaundryBodyState extends State<MyMainLaundryBody> {
  bool bHeader = true;

  @override
  void initState() {
    super.initState();
    empIdGlobal = widget.empidClass;
    putEntries(); // only to use getItemNameOnly()
  }

  //########################### MAIN ###############################
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(
            "${DateFormat('MMM dd, yyyy').format(Timestamp.now().toDate())}. Hello $empIdGlobal"),
        toolbarHeight: 25,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 250,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataSuppliesCurrent(),
                ]),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 600,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataSuppliesHistory(),
                ]),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 600,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataEmployeeCurr(),
                  _readDataEmployeeHist(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //########################### Supplies Current ###############################
  Widget _readDataSuppliesCurrent() {
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
                                        : (sMH.itemId ==
                                                menuFabWKLDValPurpleDVal
                                            ? "  Fab WKL(Ppl)"
                                            : (sMH.itemId ==
                                                    menuOthCashInOutFunds
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
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
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

  //########################### Supplies History ###############################
  Widget _readDataSuppliesHistory() {
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

      return (ifMenuUniqueIsEOD(sMH)
          ? fundCheckContainer()
          : regularContainer());
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

  //########################### Employee ###############################
  Widget _readDataEmployeeCurr() {
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
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
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

  //########################### Employee History ###############################
  Widget _readDataEmployeeHist() {
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
                              : (ifMenuUniqueIsSalaryPayEmp(eM)
                                  ? 'to:'
                                  : 'by:')),
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
}
