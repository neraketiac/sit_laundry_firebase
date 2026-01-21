import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(
            "${convertTimeStampVar(Timestamp.now()).substring(0, 12).trim()}. Hello $empIdGlobal"),
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
          ],
        ),
      ),
    );
  }

  //read Supplies Current
  Widget _readDataSuppliesCurrent() {
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

          listSMH.forEach((sMHData) {
            SuppliesModelHist sMH = sMHData.data();
            if (displayInSummary(sMH)) {
              final rowData = TableRow(
                  decoration: BoxDecoration(color: Colors.black),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: _conDisplaySuppliesCurrent(context, sMH),
                        ),
                      ),
                    )
                  ]);

              rowDatas.add(rowData);
            }
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read Supplies History
  Widget _readDataSuppliesHistory() {
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

          listSMH.forEach((sMHData) {
            SuppliesModelHist sMH = sMHData.data();
            if (displayInHistory(sMH)) {
              final rowData = TableRow(
                  decoration: BoxDecoration(color: Colors.black),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: _conDisplaySuppliesHistory(context, sMH),
                        ),
                      ),
                    )
                  ]);

              rowDatas.add(rowData);
            }
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

Container _conDisplaySuppliesCurrent(
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

  Container _conDisplaySuppliesHistory(
    BuildContext context,
    SuppliesModelHist sMH,
  ) {
    return Container(
      height: 20,
      color: getCOlorSuppliesHistoryVar(sMH),
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
                    Text(" ${convertTimeStampVar(sMH.logDate)} ",
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    Text(sMH.itemName,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(
                        " ( ₱${value.format(sMH.currentCounter)} / ₱${value.format(sMH.currentStocks)} ) ",
                        style: const TextStyle(fontSize: 11)),
                    Text("by:{${sMH.customerName}} ",
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    Text("log:{${sMH.empId}}",
                        style: const TextStyle(
                          fontSize: 10,
                        )),
                    Text(":${sMH.remarks}",
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


}
