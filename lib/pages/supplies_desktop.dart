import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MySuppliesDesktop extends StatefulWidget {
  const MySuppliesDesktop({super.key});

  @override
  State<MySuppliesDesktop> createState() => _MySuppliesDesktopState();
}

class _MySuppliesDesktopState extends State<MySuppliesDesktop> {
  bool bHeader = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          title: const Text("D E S K T O P"),
          toolbarHeight: 30,
        ),
        body: Row(
          children: [
            const Padding(padding: EdgeInsets.all(8.0)),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        height: 100,
                        color: Colors.deepPurple[400],
                        child: const Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        _readData('Det'),
                      ]),
                    ),
                  ),
                  /*
                  Expanded(child: ListView.builder(itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.deepPurple[300],
                        height: 120,
                      ),
                    );
                  })),
                  */
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 300,
                color: Colors.deepPurple[300],
              ),
            ),
          ],
        ));
  }

 //read
  Widget _readData(String streamName) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ProductsUsed').orderBy('Date').snapshots(),
      builder: (context, snapshot) {
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(decoration: BoxDecoration(color: Colors.blueGrey), children: [
              Text(
                "Job #",
                style: TextStyle(fontSize: 10),
              ),
              Text(
                "Type",
                style: TextStyle(fontSize: 10),
              ),
              Text(
                "Item Name",
                style: TextStyle(fontSize: 10),
              ),
              Text(
                "Count",
                style: TextStyle(fontSize: 10),
              ),
              Text(
                "Date",
                style: TextStyle(fontSize: 10),
              )
            ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //body
          final buffRecords = snapshot.data?.docs.reversed.toList();

          for (var buffRecord in buffRecords!) {
            if (zebra) {
              zebra = false;
            } else {
              zebra = true;
            }
            final rowData = TableRow(decoration: BoxDecoration(color: zebra ? Colors.grey : Colors.white), children: [
              Text("#${buffRecord['jobid']}", style: const TextStyle(fontSize: 10)),
              Text(
                "${buffRecord['Type']}",
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                mapBleNames[buffRecord['Id']] ?? mapFabNames[buffRecord['Id']] ?? mapDetNames[buffRecord['Id']] ?? mapOthNames[buffRecord['Id']]!,
                style: const TextStyle(fontSize: 7),
              ),
              Text(
                buffRecord['Count'].toString(),
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                convertTimeStamp(buffRecord['Date']),
                style: const TextStyle(fontSize: 7),
              ),
            ]);
            rowDatas.add(rowData);

            //listRemaining.add(ProductsRemaining(buffRecord['Type'], buffRecord['Count']));
          }
        }

        /*
        for (int i = 0; i < listRemaining.length; i++) {
          ProductsRemaining prodRem = listRemaining[i];

          log("watata${prodRem.count}");
        }
        */

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  static convertTimeStamp(Timestamp timestamp) {
    //assert(timestamp != null);
    String convertedDate;
    convertedDate = DateFormat.yMMMd().add_jm().format(timestamp.toDate());
    return convertedDate;
  }
}
