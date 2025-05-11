//import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/services/database_jobsdone.dart';
import 'package:laundry_firebase/services/database_jobsongoing.dart';
import 'package:laundry_firebase/services/database_jobsonqueue.dart';
import 'package:laundry_firebase/services/database_other_items_onqueue.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/services/database_supplies_history.dart';
import 'package:laundry_firebase/variables/vairables_jobsonqueue.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_jobsdone.dart';
import 'package:laundry_firebase/variables/variables_jobsongoing.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';
import 'package:laundry_firebase/variables/variables_det.dart';
import 'package:laundry_firebase/variables/variables_fab.dart';
import 'package:laundry_firebase/variables/variables_ble.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:week_of_year/week_of_year.dart';

/*
cd C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git status
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git add .
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git commit -m "JobsOnGoing"
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git push

flutter build web
firebase login
firebase init hosting
  public (yes)
  rewrite index (yes)
  github (no)
firebase deploy

open file firebase.json change public to build/web
*/

class MyQueueMobile extends StatefulWidget {
  final String empidClass;

  const MyQueueMobile(this.empidClass, {super.key});

  @override
  State<MyQueueMobile> createState() => _MyQueueMobileState();
}

class _MyQueueMobileState extends State<MyQueueMobile> {
  bool bHeader = true;
  //late String empid;

  //JobsOnQueue
  late String _gsId;
  late Timestamp _gtDateQ;
  late String _gsCreatedBy;
  late String _gsCustomer;
  late int _giInitialKilo;
  late int _giInitialLoad;
  late int _giInitialPrice;
  late String _gsQueueStat;
  late String _gsPaymentStat;
  late String _gsPaymentReceivedBy;
  late Timestamp _gtNeedOn;
  late DateTime _gdNeedOn;
  late bool _gbMaxFab;
  late bool _gbFold;
  late bool _gbMix;
  late int _giBasket;
  late int _giBag;
  late int _giKulang;
  late int _giMaySukli;

  late int _giFinalKilo;
  late int _giFinalLoad;
  late int _giFinalPrice;
  late int _giExtraDryPrice;
  late bool _gbWithFinalLoad;
  late bool _gbWithFinalPrice;

  //JobsOnGoing
  late int _giFinalVacantJobsId;
  late int _giJobsId;
  late Timestamp _gtDateW, _gtDateD;

  List<DropdownMenuItem<String>> dropdownItems = [];

  late List<String> listNumbering;

  String _selectedNumber = "#1";

  final _formKeyQueueMobile = GlobalKey<FormState>();

  late bool _bRiderPickup = false;

  @override
  void initState() {
    super.initState();

    empIdGlobal = widget.empidClass;

    bDelAddOnsVar = true;

    //putEntries();
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
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 200,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataJobsOnQueue(),
            //     ]),
            //   ),
            // ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 200,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataJobsOnGoing(),
            //     ]),
            //   ),
            // ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 200,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataJobsDoneFilter('D8_WaitCustomerPickup'),
            //     ]),
            //   ),
            // ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 200,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataJobsDoneFilter('D9_WaitRiderDelivery'),
            //     ]),
            //   ),
            // ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 200,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataJobsDoneFilter('E1_NasaCustomerNa'),
            //     ]),
            //   ),
            // ),
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
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Container(
            //     width: 600,
            //     color: Colors.blue,
            //     padding: const EdgeInsets.all(8.0),
            //     child: Column(children: <Widget>[
            //       const SizedBox(
            //         height: 1,
            //       ),
            //       _readDataSuppliesHistoryAll(),
            //     ]),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  //read JobsOnQueue
  Widget _readDataJobsOnQueue() {
    DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: databaseJobsOnQueue.getJobsOnQueue(),
      builder: (context, snapshot) {
        List listJOQM = snapshot.data?.docs ?? [];
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (listJOQM.isNotEmpty) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
                children: [
                  Text(
                    "Jobs On Queue",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          listJOQM.forEach((jOQMData) {
            JobsOnQueueModel jOQM = jOQMData.data();
            JobsOnQueueModel jOQMNoChange = jOQMData.data();
            List<OtherItemModel> lOIM;
            List<OtherItemModel> lOIMNoChange;
            DatabaseOtherItemsOnQueue dbOIOQ =
                DatabaseOtherItemsOnQueue(jOQMData.id);
            //_readOtherItems(jOQMData.id);
            lOIM =
                _readAllOtherItemModel(jOQMData.id.toString(), 'JobsOnQueue');
            lOIMNoChange =
                _readAllOtherItemModel(jOQMData.id.toString(), 'JobsOnQueue');
            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: zebra ? Colors.black : Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          showAlterJobsOnQueueVar(
                              context,
                              jOQMData.id.toString(),
                              jOQM,
                              lOIM,
                              jOQMNoChange,
                              lOIMNoChange);
                        },
                        child: conDisplayVar(context, false, jOQM),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read JobsOnGoing
  Widget _readDataJobsOnGoing() {
    DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
    bool zebra = false;
    int iDisplayArrow = 0;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: databaseJobsOnGoing.getJobsOnGoing(),
      builder: (context, snapshot) {
        List listJOQM = snapshot.data?.docs ?? [];
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (listJOQM.isNotEmpty) {
          iDisplayArrow = 0;
          //header
          if (bHeader) {
            refillJobsList();
            const rowData = TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
                children: [
                  Text(
                    "Jobs On Going",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //read if jobsId 25 is waiting
          for (var jOQMData in listJOQM.reversed) {
            JobsOnQueueModel jOQM = jOQMData.data();
            if (!jOQM.waiting && jOQM.jobsId == 25) {
              iDisplayArrow = 2;
            }
            break;
          }

          listJOQM.forEach((jOQMData) {
            JobsOnQueueModel jOQM = jOQMData.data();
            JobsOnQueueModel jOQMNoChange = jOQMData.data();
            if (!jOQM.waiting) {
              iDisplayArrow = 3;
            }
            iDisplayArrow--;
            if (iDisplayArrow < 0) {
              iDisplayArrow = 0;
            }

            finListNumbering
                .removeWhere((val) => val.startsWith("#${jOQM.jobsId}#"));

            List<OtherItemModel> lOIM;
            List<OtherItemModel> lOIMNoChange;

            lOIM =
                _readAllOtherItemModel(jOQMData.id.toString(), 'JobsOnGoing');
            lOIMNoChange =
                _readAllOtherItemModel(jOQMData.id.toString(), 'JobsOnGoing');
            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: zebra ? Colors.black : Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          showAlterJobsOnGoingVar(
                              context,
                              setState,
                              jOQMData.id.toString(),
                              jOQM,
                              lOIM,
                              jOQMNoChange,
                              lOIMNoChange);
                        },
                        child: conDisplayVar(
                            context, (iDisplayArrow == 0 ? true : false), jOQM),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
          });

          for (int i = 0; i < finListNumbering.length; i++) {
            print("i=$i ${finListNumbering[i]}");
            lasListNumbering
                .removeWhere((val) => val.startsWith(finListNumbering[i]));
          }

          print(finListNumbering);
          print(lasListNumbering);
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read JobsOnGoing
  Widget _readDataJobsDoneFilter(String columnFilter) {
    DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: databaseJobsDone.getJobsDoneFilter(columnFilter),
      //stream: databaseJobsDone.getJobsDone(),
      builder: (context, snapshot) {
        List listJOQM = snapshot.data?.docs ?? [];
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (listJOQM.isNotEmpty) {
          //header
          if (bHeader) {
            var rowData = TableRow(
                decoration:
                    // const BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
                    BoxDecoration(
                        color: (columnFilter == "D8_WaitCustomerPickup"
                            ? cWaitCustomerPickup
                            : (columnFilter == "D9_WaitRiderDelivery"
                                ? cWaitRiderDelivery
                                : (columnFilter == "E1_NasaCustomerNa"
                                    ? cNasaCustomerNa
                                    : cWaitCustomerPickup)))),
                children: [
                  Text(
                    "Jobs ${columnFilter.substring(3)}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          listJOQM.forEach((jOQMData) {
            JobsOnQueueModel jOQM = jOQMData.data();
            if ((jOQM.paidcash || (jOQM.paidgcash && jOQM.paidgcashverified)) &&
                (columnFilter == "E1_NasaCustomerNa")) {
            } else {
              JobsOnQueueModel jOQMNoChange = jOQMData.data();

              List<OtherItemModel> lOIM;
              List<OtherItemModel> lOIMNoChange;

              lOIM = _readAllOtherItemModel(jOQMData.id.toString(), 'JobsDone');
              lOIMNoChange =
                  _readAllOtherItemModel(jOQMData.id.toString(), 'JobsDone');
              final rowData = TableRow(
                  decoration:
                      BoxDecoration(color: zebra ? Colors.black : Colors.black),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            showAlterJobsDoneVar(
                                context,
                                setState,
                                jOQMData.id.toString(),
                                jOQM,
                                lOIM,
                                jOQMNoChange,
                                lOIMNoChange);
                          },
                          child: conDisplayVar(context, false, jOQM),
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

  //read Supplies Current
  Widget _readDataSuppliesCurrent() {
    DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
    //DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
    bool zebra = false;
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

            //addField("SuppliesCurr", sMH.docId);

            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: zebra ? Colors.black : Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // showAlterJobsOnQueueVar(
                          //     context,
                          //     jOQMData.id.toString(),
                          //     jOQM,
                          //     lOIM,
                          //     jOQMNoChange,
                          //     lOIMNoChange);
                        },
                        child: conDisplaySuppliesCurrentVar(context, sMH),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
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
    bool zebra = false;
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
                  // Checkbox(
                  //     value: bTest,
                  //     onChanged: (val) {
                  //       setState(() {
                  //         bTest = val!;
                  //       });
                  //     }),
                ]);
            rowDatas.add(rowData);

            // var rowData2 = TableRow(
            //     decoration:
            //         const BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
            //     children: [
            //       Checkbox(
            //           value: bTest,
            //           onChanged: (val) {
            //             setState(() {
            //               bTest = val!;
            //             });
            //           }),
            //     ]);
            // rowDatas.add(rowData2);
            bHeader = false;
          }

          listSMH.forEach((sMHData) {
            SuppliesModelHist sMH = sMHData.data();

            ///addField("SuppliesHist", sMH.docId);

            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: zebra ? Colors.black : Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // showAlterJobsOnQueueVar(
                          //     context,
                          //     jOQMData.id.toString(),
                          //     jOQM,
                          //     lOIM,
                          //     jOQMNoChange,
                          //     lOIMNoChange);
                        },
                        child: conDisplaySuppliesHistoryVar(context, sMH),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read Supplies History All
  Widget _readDataSuppliesHistoryAll() {
    DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: databaseSuppliesHist.getSuppliesHistory(true),
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
                    "Supplies Summary",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }
          var weekNum2 = Timestamp.now();
          var weekNum = DateTime.fromMicrosecondsSinceEpoch(
              weekNum2.microsecondsSinceEpoch);

          print("week of year=${weekNum.weekOfYear} ${weekNum.ordinalDate}");

          SuppliesModelHist sMHTemp = SuppliesModelHist(
              docId: '0',
              countId: 0,
              itemId: 0,
              itemUniqueId: 0,
              currentCounter: 0,
              currentStocks: 0,
              logDate: Timestamp.now(),
              empId: empIdGlobal,
              customerId: 0,
              remarks: '');
          listSMH.forEach((sMHData) {
            SuppliesModelHist sMH = sMHData.data();

//            addField("SuppliesHist", sMH);

            if (sMH.itemUniqueId == 4405) {
              if (sMH.itemId == sMHTemp.itemId) {
                sMHTemp.currentCounter =
                    sMHTemp.currentCounter + sMH.currentCounter;
                sMHTemp.logDate = Timestamp.now();
              } else {
                //display temp before changing
                if (sMHTemp.itemId != 0) {
                  final rowData = TableRow(
                      decoration: BoxDecoration(
                          color: zebra ? Colors.black : Colors.black),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: conDisplaySuppliesHistoryVar(
                                  context, sMHTemp),
                            ),
                          ),
                        )
                      ]);

                  rowDatas.add(rowData);
                }

                sMHTemp = SuppliesModelHist(
                    docId: sMH.docId,
                    countId: sMH.countId,
                    itemId: sMH.itemId,
                    itemUniqueId: sMH.itemUniqueId,
                    currentCounter: sMH.currentCounter,
                    currentStocks: sMH.currentStocks,
                    logDate: sMH.logDate,
                    empId: sMH.empId,
                    customerId: sMH.customerId,
                    remarks: sMH.remarks);
              }
            }
          });

          final rowDatax = TableRow(
              decoration:
                  BoxDecoration(color: zebra ? Colors.black : Colors.black),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: conDisplaySuppliesHistoryVar(context, sMHTemp),
                    ),
                  ),
                )
              ]);

          rowDatas.add(rowDatax);
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read OtherItems
  Future<void> _readOtherItems(String id) async {
    //String _readOtherItems(String id) {
    late String asdf = "";
    CollectionReference users = FirebaseFirestore.instance
        .collection('JobsOnQueue')
        .doc(id)
        .collection('OtherItems');

    users.get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        asdf = asdf + doc['itemName'];
      }
      print("asdf=" + asdf);
    }).catchError((error) => print("Failed to fetch users: $error"));
  }

  List<OtherItemModel> _readAllOtherItemModel(
      String id, String sMainCollection) {
    List<OtherItemModel> lOIM = [];

    late String asdf = "";
    CollectionReference users = FirebaseFirestore.instance
        .collection(sMainCollection)
        .doc(id)
        .collection('OtherItems');

    users.get().then((QuerySnapshot snapshot) async {
      for (var doc in snapshot.docs) {
        OtherItemModel oIM = OtherItemModel(
            docId: doc['DocId'],
            itemId: doc['ItemId'],
            itemUniqueId: doc['ItemUniqueId'],
            itemGroup: doc['ItemGroup'],
            itemName: doc['ItemName'],
            itemPrice: doc['ItemPrice'],
            stocksAlert: doc['StocksAlert'],
            stocksType: doc['StocksType']);
        print("asdf=" + oIM.itemName);
        lOIM.add(oIM);
      }
      await lOIM;
    }).catchError((error) => print("Failed to fetch users: $error"));

    return lOIM;
  }

  Future<List<OtherItemModel>> _readOtherItemsList(String id) async {
    List<OtherItemModel> listOIM = [];
    DatabaseOtherItemsOnQueue dbOIOQ = DatabaseOtherItemsOnQueue(id);

    //List listJOQM = snapshot.data?.docs ?? [];

    Stream stream = dbOIOQ.getOtherItems();

    return listOIM;
  }

  //read JobsDone Wala sa Customer
  Widget _readDataJobsDoneOld(String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsDone')
          .where('QueueStat', isNotEqualTo: 'NasaCustomerNa')
          .orderBy('D7_DateD', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration: BoxDecoration(color: Colors.green),
                children: [
                  Text(
                    "Jobs Done - Dito Damit",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //body
          final buffRecords = snapshot.data?.docs.toList();

          for (var buffRecord in buffRecords!) {
            //required initialize start
            _gbWithFinalLoad = false;
            try {
              _giFinalKilo = buffRecord['B1_FinalKilo'];
              _giFinalLoad = buffRecord['B2_FinalLoad'];
              _gbWithFinalLoad = true;
            } on Exception catch (exception) {
            } catch (error) {}

            _gbWithFinalPrice = false;
            try {
              _giFinalPrice = buffRecord['B3_FinalPrice'];
              _gbWithFinalPrice = true;
            } on Exception catch (exception) {
            } catch (error) {}
            //required initialize end

            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: zebra ? Colors.black : Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _gsId = buffRecord.id.toString();
                          _gtDateD = buffRecord['D7_DateD'];
                          _gtDateW = buffRecord['DateW'];
                          _gtDateQ = buffRecord['A1_DateQ'];
                          _gsCreatedBy = buffRecord['A4_CreatedBy'];
                          _gsCustomer = buffRecord['Customer'];
                          _giInitialKilo = buffRecord['A6_InitialKilo'];
                          _giInitialLoad = buffRecord['A7_InitialLoad'];
                          _giInitialPrice = buffRecord['A8_InitialPrice'];
                          _gsQueueStat = buffRecord['QueueStat'];
                          _gsPaymentStat = buffRecord['PaymentStat'];
                          _gsPaymentReceivedBy =
                              buffRecord['C9_PaymentReceivedBy'];
                          _gtNeedOn = buffRecord['B9_NeedOn'];
                          _gbMaxFab = buffRecord['MaxFab'];
                          _gbFold = buffRecord['C1_Fold'];
                          _gbMix = buffRecord['C2_Mix'];
                          _giBasket = buffRecord['C3_Basket'];
                          _giBag = buffRecord['C4_Bag'];
                          _giKulang = buffRecord['Kulang'];
                          _giMaySukli = buffRecord['MaySukli'];

                          _giJobsId = buffRecord['JobsId'];

                          try {
                            _giFinalKilo = buffRecord['B1_FinalKilo'];
                            _giFinalLoad = buffRecord['B2_FinalLoad'];
                          } on Exception catch (exception) {
                            _giFinalKilo = buffRecord['A6_InitialKilo'];
                            _giFinalLoad = buffRecord['A7_InitialLoad'];
                          } catch (error) {
                            _giFinalKilo = buffRecord['A6_InitialKilo'];
                            _giFinalLoad = buffRecord['A7_InitialLoad'];
                          }

                          try {
                            _giFinalPrice = buffRecord['B3_FinalPrice'];
                          } on Exception catch (exception) {
                            _giFinalPrice = buffRecord['A8_InitialPrice'];
                          } catch (error) {
                            _giFinalPrice = buffRecord['A8_InitialPrice'];
                          }

                          _gdNeedOn = _gtNeedOn.toDate();
                          _giExtraDryPrice = buffRecord['ExtraDryPrice'];

                          alterDoneMobile();
                        },
                        //Container display JobsDone
                        child: _conDisplay(
                          context,
                          false,
                          Color.fromRGBO(32, 163, 180, 1),
                          buffRecord['Customer'],
                          buffRecord['QueueStat'],
                          buffRecord['B1_FinalKilo'],
                          buffRecord['B2_FinalLoad'],
                          buffRecord['C3_Basket'],
                          buffRecord['C4_Bag'],
                          buffRecord['MaxFab'],
                          buffRecord['C2_Mix'],
                          buffRecord['C1_Fold'],
                          buffRecord['PaymentStat'],
                          buffRecord['B3_FinalPrice'],
                          buffRecord['B9_NeedOn'],
                          buffRecord['ExtraDryPrice'],
                          buffRecord['JobsId'],
                        ),
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

  //read JobsDone nasa Customer Unpaid
  Widget _readDataJobsDoneCustomerDone(
      String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsDone')
          .where("QueueStat", isEqualTo: "NasaCustomerNa")
          .orderBy('D7_DateD', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration: BoxDecoration(color: Colors.green),
                children: [
                  Text(
                    "NasaCustomerNa(Unpaid)",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //body
          final buffRecords = snapshot.data?.docs.toList();

          for (var buffRecord in buffRecords!) {
            if (buffRecord['PaymentStat'] == "Unpaid") {
              //required initialize start
              _gbWithFinalLoad = false;
              try {
                _giFinalKilo = buffRecord['B1_FinalKilo'];
                _giFinalLoad = buffRecord['B2_FinalLoad'];
                _gbWithFinalLoad = true;
              } on Exception catch (exception) {
              } catch (error) {}

              _gbWithFinalPrice = false;
              try {
                _giFinalPrice = buffRecord['B3_FinalPrice'];
                _gbWithFinalPrice = true;
              } on Exception catch (exception) {
              } catch (error) {}
              //required initialize end

              final rowData = TableRow(
                  decoration:
                      BoxDecoration(color: zebra ? Colors.black : Colors.black),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _gsId = buffRecord.id.toString();
                            _gtDateD = buffRecord['D7_DateD'];
                            _gtDateW = buffRecord['DateW'];
                            _gtDateQ = buffRecord['A1_DateQ'];
                            _gsCreatedBy = buffRecord['A4_CreatedBy'];
                            _gsCustomer = buffRecord['Customer'];
                            _giInitialKilo = buffRecord['A6_InitialKilo'];
                            _giInitialLoad = buffRecord['A7_InitialLoad'];
                            _giInitialPrice = buffRecord['A8_InitialPrice'];
                            _gsQueueStat = buffRecord['QueueStat'];
                            _gsPaymentStat = buffRecord['PaymentStat'];
                            _gsPaymentReceivedBy =
                                buffRecord['C9_PaymentReceivedBy'];
                            _gtNeedOn = buffRecord['B9_NeedOn'];
                            _gbMaxFab = buffRecord['MaxFab'];
                            _gbFold = buffRecord['C1_Fold'];
                            _gbMix = buffRecord['C2_Mix'];
                            _giBasket = buffRecord['C3_Basket'];
                            _giBag = buffRecord['C4_Bag'];
                            _giKulang = buffRecord['Kulang'];
                            _giMaySukli = buffRecord['MaySukli'];

                            _giJobsId = buffRecord['JobsId'];

                            try {
                              _giFinalKilo = buffRecord['B1_FinalKilo'];
                              _giFinalLoad = buffRecord['B2_FinalLoad'];
                            } on Exception catch (exception) {
                              _giFinalKilo = buffRecord['A6_InitialKilo'];
                              _giFinalLoad = buffRecord['A7_InitialLoad'];
                            } catch (error) {
                              _giFinalKilo = buffRecord['A6_InitialKilo'];
                              _giFinalLoad = buffRecord['A7_InitialLoad'];
                            }

                            try {
                              _giFinalPrice = buffRecord['B3_FinalPrice'];
                            } on Exception catch (exception) {
                              _giFinalPrice = buffRecord['A8_InitialPrice'];
                            } catch (error) {
                              _giFinalPrice = buffRecord['A8_InitialPrice'];
                            }

                            _gdNeedOn = _gtNeedOn.toDate();
                            _giExtraDryPrice = buffRecord['ExtraDryPrice'];

                            alterDoneMobile();
                          },
                          //Container display JobsDone
                          child: _conDisplay(
                            context,
                            false,
                            Color.fromRGBO(32, 163, 180, 1),
                            buffRecord['Customer'],
                            buffRecord['QueueStat'],
                            buffRecord['B1_FinalKilo'],
                            buffRecord['B2_FinalLoad'],
                            buffRecord['C3_Basket'],
                            buffRecord['C4_Bag'],
                            buffRecord['MaxFab'],
                            buffRecord['C2_Mix'],
                            buffRecord['C1_Fold'],
                            buffRecord['PaymentStat'],
                            buffRecord['B3_FinalPrice'],
                            buffRecord['B9_NeedOn'],
                            buffRecord['ExtraDryPrice'],
                            buffRecord['JobsId'],
                          ),
                        ),
                      ),
                    )
                  ]);
              rowDatas.add(rowData);
            }
          }
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read JobsDone nasa Customer Paid
  Widget _readDataJobsDoneCustomerDonePaid(
      String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsDone')
          .where("QueueStat", isEqualTo: "NasaCustomerNa")
          .orderBy('D7_DateD', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration: BoxDecoration(color: Colors.green),
                children: [
                  Text(
                    "NasaCustomerNa(Paid)",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //body
          final buffRecords = snapshot.data?.docs.toList();

          for (var buffRecord in buffRecords!) {
            if (buffRecord['PaymentStat'] != "Unpaid") {
              //required initialize start
              _gbWithFinalLoad = false;
              try {
                _giFinalKilo = buffRecord['B1_FinalKilo'];
                _giFinalLoad = buffRecord['B2_FinalLoad'];
                _gbWithFinalLoad = true;
              } on Exception catch (exception) {
              } catch (error) {}

              _gbWithFinalPrice = false;
              try {
                _giFinalPrice = buffRecord['B3_FinalPrice'];
                _gbWithFinalPrice = true;
              } on Exception catch (exception) {
              } catch (error) {}
              //required initialize end

              final rowData = TableRow(
                  decoration:
                      BoxDecoration(color: zebra ? Colors.black : Colors.black),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _gsId = buffRecord.id.toString();
                            _gtDateD = buffRecord['D7_DateD'];
                            _gtDateW = buffRecord['DateW'];
                            _gtDateQ = buffRecord['A1_DateQ'];
                            _gsCreatedBy = buffRecord['A4_CreatedBy'];
                            _gsCustomer = buffRecord['Customer'];
                            _giInitialKilo = buffRecord['A6_InitialKilo'];
                            _giInitialLoad = buffRecord['A7_InitialLoad'];
                            _giInitialPrice = buffRecord['A8_InitialPrice'];
                            _gsQueueStat = buffRecord['QueueStat'];
                            _gsPaymentStat = buffRecord['PaymentStat'];
                            _gsPaymentReceivedBy =
                                buffRecord['C9_PaymentReceivedBy'];
                            _gtNeedOn = buffRecord['B9_NeedOn'];
                            _gbMaxFab = buffRecord['MaxFab'];
                            _gbFold = buffRecord['C1_Fold'];
                            _gbMix = buffRecord['C2_Mix'];
                            _giBasket = buffRecord['C3_Basket'];
                            _giBag = buffRecord['C4_Bag'];
                            _giKulang = buffRecord['Kulang'];
                            _giMaySukli = buffRecord['MaySukli'];

                            _giJobsId = buffRecord['JobsId'];

                            try {
                              _giFinalKilo = buffRecord['B1_FinalKilo'];
                              _giFinalLoad = buffRecord['B2_FinalLoad'];
                            } on Exception catch (exception) {
                              _giFinalKilo = buffRecord['A6_InitialKilo'];
                              _giFinalLoad = buffRecord['A7_InitialLoad'];
                            } catch (error) {
                              _giFinalKilo = buffRecord['A6_InitialKilo'];
                              _giFinalLoad = buffRecord['A7_InitialLoad'];
                            }

                            try {
                              _giFinalPrice = buffRecord['B3_FinalPrice'];
                            } on Exception catch (exception) {
                              _giFinalPrice = buffRecord['A8_InitialPrice'];
                            } catch (error) {
                              _giFinalPrice = buffRecord['A8_InitialPrice'];
                            }

                            _gdNeedOn = _gtNeedOn.toDate();
                            _giExtraDryPrice = buffRecord['ExtraDryPrice'];

                            alterDoneMobile();
                          },
                          //Container display JobsDone
                          child: _conDisplay(
                            context,
                            false,
                            Color.fromRGBO(32, 163, 180, 1),
                            buffRecord['Customer'],
                            buffRecord['QueueStat'],
                            buffRecord['B1_FinalKilo'],
                            buffRecord['B2_FinalLoad'],
                            buffRecord['C3_Basket'],
                            buffRecord['C4_Bag'],
                            buffRecord['MaxFab'],
                            buffRecord['C2_Mix'],
                            buffRecord['C1_Fold'],
                            buffRecord['PaymentStat'],
                            buffRecord['B3_FinalPrice'],
                            buffRecord['B9_NeedOn'],
                            buffRecord['ExtraDryPrice'],
                            buffRecord['JobsId'],
                          ),
                        ),
                      ),
                    )
                  ]);
              rowDatas.add(rowData);
            }
          }
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //Display
  Container _conDisplay(
      BuildContext context,
      bool showUpArrow,
      Color buffColor,
      String buffCustomer,
      String buffQueueStat,
      int buffInitialKilo,
      int buffInitialLoad,
      int buffBasket,
      int buffBag,
      bool buffMaxFab,
      bool buffMix,
      bool buffFold,
      String buffPaymentStat,
      int buffInitialPrice,
      Timestamp buffNeedOn,
      [int buffExtraDryPrice = 0,
      int buffJobsId = 0]) {
    return Container(
      height: 80,
      color: _getCOlorStatus(buffQueueStat),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              InkWell(
                onDoubleTap: () {
                  if (buffQueueStat == "Waiting") {
                    alterNumberMobile(buffJobsId);
                  }
                },
                child: Text(
                  (buffJobsId == 0 ? "" : "#$buffJobsId"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Visibility(
                visible: showUpArrow,
                child: IconButton(
                  onPressed: () {
                    moveUp(buffJobsId);
                  },
                  icon: const Icon(Icons.arrow_upward),
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "$buffCustomer (${_gbWithFinalLoad ? _giFinalLoad.toString() : buffInitialLoad.toString()}) ${buffBasket == 0 ? "" : "${buffBasket}BK"} ${buffBag == 0 ? "" : "${buffBag}BG"}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
                Text(
                  "${_gbWithFinalLoad ? _giFinalKilo.toString() : buffInitialKilo.toString()} ${buffMaxFab ? "MaxFab" : ""} ${buffMix ? "" : "DM"} ${buffFold ? "" : "NF"} ${buffExtraDryPrice == 0 ? "" : "XD"}",
                  style: const TextStyle(fontSize: 9),
                ),
                Text(
                  "$buffPaymentStat:${(_gbWithFinalPrice ? _giFinalPrice : buffInitialPrice) + buffExtraDryPrice} Php",
                  style: TextStyle(
                      fontSize: 10,
                      backgroundColor: paymentStatColor(buffPaymentStat)),
                ),
                Text(
                  displayDate(convertTimeStamp(buffNeedOn)),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  buffQueueStat,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static displayDate(String s) {
    return "${s.substring(0, s.indexOf(',') + 1)} ${s.substring(s.indexOf(':') - 2, s.indexOf(':'))} ${s.substring(s.indexOf(':') + 4, s.indexOf(':') + 6)}";
  }

  static convertTimeStamp(Timestamp timestamp) {
    //assert(timestamp != null);
    String convertedDate;
    convertedDate = DateFormat.yMMMd().add_jm().format(timestamp.toDate());
    //return "${convertedDate.substring(0, convertedDate.indexOf(',') + 1)} ${convertedDate.substring(convertedDate.indexOf(':') - 2, convertedDate.indexOf(':'))} ${convertedDate.substring(convertedDate.indexOf(':') + 4, convertedDate.indexOf(':') + 6)}";
    return convertedDate;
  }

  void messageResult(BuildContext context, String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  color: cButtons,
                  child: const Text("Ok"),
                ),
              ],
            ));
  }

  //open new expense box json
  void alterQueueMobileJson(JobsOnQueueModel jobsOnQueueModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Change Queue",
          style: TextStyle(backgroundColor: Colors.red[400]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                //Alter Display
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {},
                        initialValue: customerName(
                            jobsOnQueueModel.customerId.toString()),
                        enabled: false,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Sort"),
                          Switch.adaptive(
                            value: _bRiderPickup,
                            onChanged: (bool value) {
                              setState(() {
                                _bRiderPickup = value;
                              });
                            },
                          ),
                          Text("RiderPickup"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _updateQueueRecord(),

          //move to JobsOnGoing automatically
          _autoOnGoing(),

          //move to JobsOnGoing manually
          _deleteQueue(),
        ],
      ),
    );
  }

  //open new expense box
  void alterQueueMobile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Change Queue",
          style: TextStyle(backgroundColor: Colors.red[400]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                //Alter Display
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    // //QueueStat
                    // DropdownMenu(
                    //   label: Text("Status",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       )),
                    //   inputDecorationTheme: getThemeDropDownQueueMobile(),
                    //   hintText: "Status",
                    //   dropdownMenuEntries: const [
                    //     DropdownMenuEntry(
                    //         value: "ForSorting", label: "ForSorting"),
                    //     DropdownMenuEntry(
                    //         value: "RiderPickup", label: "RiderPickup"),
                    //   ],
                    //   onSelected: (val) {
                    //     _gsQueueStat = val!;
                    //   },
                    //   initialSelection: _gsQueueStat,
                    // ),
                    // QeueeStat CheckBox
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: decoAmber(),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Flexible(
                    //         child: CheckboxListTile(
                    //             title: Flexible(
                    //                 child: Text(
                    //                     mapQueueStat[forSorting].toString())),
                    //             value: _bForSorting,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 _bForSorting = false;
                    //                 _bRiderPickup = false;
                    //                 if (val!) {
                    //                   _bForSorting = val!;
                    //                 }
                    //               });
                    //             }),
                    //       ),
                    //       Flexible(
                    //         child: CheckboxListTile(
                    //             title: Flexible(
                    //                 child: Text(
                    //                     mapQueueStat[riderPickup].toString())),
                    //             value: _bRiderPickup,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 _bForSorting = false;
                    //                 _bRiderPickup = false;
                    //                 if (val!) {
                    //                   _bRiderPickup = val!;
                    //                 }
                    //               });
                    //             }),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    //Customer
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {},
                        initialValue: _gsCustomer,
                        enabled: false,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Sort"),
                          Switch.adaptive(
                            value: _bRiderPickup,
                            onChanged: (bool value) {
                              setState(() {
                                _bRiderPickup = value;
                              });
                            },
                          ),
                          Text("RiderPickup"),
                        ],
                      ),
                    ),
                    //New Estimate load
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        children: [
                          //New estimate load +-8 kilo
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-8 kilo"),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo < 8) {
                                      setState(() => _giFinalKilo = 0);
                                      setState(() => _giFinalPrice = 0);
                                      setState(() => _giFinalLoad = 0);
                                    } else {
                                      if (_giFinalKilo % 8 != 0) {
                                        _giFinalKilo =
                                            _giFinalKilo - (_giFinalKilo % 8);
                                      } else {
                                        _giFinalKilo = _giFinalKilo - 8;
                                      }

                                      setState(
                                        () => _giFinalKilo,
                                      );

                                      setState(() => _giFinalPrice =
                                          (_giFinalKilo ~/ 8) * 155);
                                      setState(() =>
                                          _giFinalLoad = (_giFinalKilo ~/ 8));
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo % 8 != 0) {
                                      _giFinalKilo =
                                          _giFinalKilo + 8 - (_giFinalKilo % 8);
                                    } else {
                                      _giFinalKilo = _giFinalKilo + 8;
                                    }

                                    _giFinalPrice = (_giFinalKilo ~/ 8) * 155;
                                    _giFinalLoad = _giFinalKilo ~/ 8;

                                    setState(() => _giFinalKilo);
                                    setState(() => _giFinalPrice);
                                    setState(() => _giFinalLoad);
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+8 kilo"),
                              ],
                            ),
                          ),
                          //New Estimate Load display
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Weight: $_giFinalKilo kilo"),
                                Text("Load(s): $_giFinalLoad"),
                                Text(
                                    "Price: ${_PriceDisplay(_giFinalPrice)}.00"),
                              ],
                            ),
                          ),
                          //New Estimate Load (+- 1 kilo)
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 kilo"),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo > 8) {
                                      if (_giFinalKilo % 8 == 1) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                        setState(() =>
                                            _giFinalLoad = _giFinalLoad - 1);
                                      } else if (_giFinalKilo % 8 == 2) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 45);
                                      } else if (_giFinalKilo % 8 == 3) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 4) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 5) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 6) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 10);
                                      }

                                      setState(() =>
                                          _giFinalKilo = _giFinalKilo - 1);
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo >= 8) {
                                      setState(() =>
                                          _giFinalKilo = _giFinalKilo + 1);
                                    }

                                    if (_giFinalKilo % 8 == 1) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 2) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 45);
                                      setState(() =>
                                          _giFinalLoad = _giFinalLoad + 1);
                                    } else if (_giFinalKilo % 8 == 3) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 4) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 5) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else {
                                      if (_giFinalPrice % 155 != 0) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice + 10);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 kilo"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //New Estimate Load End
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //Final Estimate Load
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         "Initial Load: $_giInitialLoad",
                    //         style: TextStyle(fontSize: 10),
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           IconButton(
                    //             onPressed: () {
                    //               setState(() => _giFinalLoad--);
                    //             },
                    //             icon: const Icon(Icons.remove),
                    //             color: Colors.blueAccent,
                    //           ),
                    //           Text("Final Load: $_giFinalLoad"),
                    //           IconButton(
                    //             onPressed: () {
                    //               setState(() => _giFinalLoad++);
                    //             },
                    //             icon: const Icon(Icons.add),
                    //             color: Colors.blueAccent,
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // //Final Price
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         "Initial Price: $_giInitialPrice",
                    //         style: TextStyle(fontSize: 10),
                    //       ),
                    //       TextFormField(
                    //         keyboardType: TextInputType.number,
                    //         inputFormatters: <TextInputFormatter>[
                    //           FilteringTextInputFormatter.allow(
                    //               RegExp(r'[0-9]')),
                    //           FilteringTextInputFormatter.digitsOnly
                    //         ],
                    //         textAlign: TextAlign.center,
                    //         decoration: InputDecoration(
                    //             labelText: 'Final Price',
                    //             hintText: 'Initial Price'),
                    //         validator: (val) {
                    //           _giFinalPrice = int.parse(val!);
                    //         },
                    //         initialValue: _giFinalPrice.toString(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 5,
                    ),
                    //Basket
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _giBasket--);
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.blueAccent,
                          ),
                          Text("Basket: $_giBasket"),
                          IconButton(
                            onPressed: () {
                              setState(() => _giBasket++);
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Bag
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _giBag--);
                            },
                            icon: const Icon(Icons.remove),
                            color: Colors.blueAccent,
                          ),
                          Text("Bag: $_giBag"),
                          IconButton(
                            onPressed: () {
                              setState(() => _giBag++);
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment
                    DropdownMenu(
                      label: Text("Payment",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Payment",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Unpaid", label: "Unpaid"),
                        DropdownMenuEntry(value: "PaidCash", label: "PaidCash"),
                        DropdownMenuEntry(
                            value: "PaidGcash", label: "PaidGcash"),
                        DropdownMenuEntry(
                            value: "WaitingGcash", label: "WaitingGcash"),
                        DropdownMenuEntry(value: "Kulang", label: "Kulang"),
                        DropdownMenuEntry(value: "MaySukli", label: "MaySukli"),
                      ],
                      onSelected: (val) {
                        _gsPaymentStat = val!;
                      },
                      initialSelection: _gsPaymentStat,
                    ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //Payment Received By
                    // DropdownMenu(
                    //   label: Text("Payment Received By",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       )),
                    //   inputDecorationTheme: getThemeDropDownQueueMobile(),
                    //   hintText: "Select Staff",
                    //   dropdownMenuEntries: const [
                    //     DropdownMenuEntry(value: "N/a", label: "N/a"),
                    //     DropdownMenuEntry(value: "Jeng", label: "Jeng"),
                    //     DropdownMenuEntry(value: "Abi", label: "Abi"),
                    //     DropdownMenuEntry(value: "Ket", label: "Ket"),
                    //     DropdownMenuEntry(value: "DonP", label: "DonP"),
                    //     DropdownMenuEntry(value: "Rowel", label: "Rowel"),
                    //     DropdownMenuEntry(value: "Seigi", label: "Seigi"),
                    //     DropdownMenuEntry(value: "Let", label: "Let"),
                    //   ],
                    //   onSelected: (val) {
                    //     _gsPaymentReceivedBy = val!;
                    //   },
                    //   initialSelection: _gsPaymentReceivedBy,
                    // ),
                    SizedBox(
                      height: 5,
                    ),
                    //Need On Date +
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 day"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _gdNeedOn =
                                        _gdNeedOn.add(Duration(days: -1)));
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _gdNeedOn =
                                        _gdNeedOn.add(Duration(days: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 day"),
                              ],
                            ),
                          ),
                          //Need On date?
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Need On: ${_gdNeedOn.toString().substring(5, 14)}00",
                                ),
                              ],
                            ),
                          ),
                          //Need On Date +
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 hr"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _gdNeedOn =
                                        _gdNeedOn.add(Duration(hours: -1)));
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _gdNeedOn =
                                        _gdNeedOn.add(Duration(hours: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 hr"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Max Fab?
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Reg Fab"),
                          Switch.adaptive(
                            value: _gbMaxFab,
                            onChanged: (bool value) {
                              setState(() {
                                _gbMaxFab = value;
                              });
                            },
                          ),
                          Text("Max 100ml"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //No Fold
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Fold"),
                          Switch.adaptive(
                            value: _gbFold,
                            onChanged: (bool value) {
                              setState(() {
                                _gbFold = value;
                              });
                            },
                          ),
                          Text("Fold"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Dont mix
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dont Mix"),
                          Switch.adaptive(
                            value: _gbMix,
                            onChanged: (bool value) {
                              setState(() {
                                _gbMix = value;
                              });
                            },
                          ),
                          Text("Mix"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Kulang
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Kulang bayad',
                            hintText: 'Magkano kulang?'),
                        validator: (val) {
                          _giKulang = int.parse(val!);
                        },
                        initialValue: _giKulang.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //May Sukli
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'May Sukli', hintText: 'Magkano sukli?'),
                        validator: (val) {
                          _giMaySukli = int.parse(val!);
                        },
                        initialValue: _giMaySukli.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _updateQueueRecord(),

          //move to JobsOnGoing automatically
          _autoOnGoing(),

          //move to JobsOnGoing manually
          _deleteQueue(),
        ],
      ),
    );
  }

  //open new expense box
  void alterOnGoingMobile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Change OnGoing",
          style: TextStyle(backgroundColor: Colors.green[50]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                //Alter Display
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    DropdownMenu(
                      label: Text("Status",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Status",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Waiting", label: "Waiting"),
                        DropdownMenuEntry(value: "Washing", label: "Washing"),
                        DropdownMenuEntry(value: "Drying", label: "Drying"),
                        DropdownMenuEntry(value: "Folding", label: "Folding"),
                      ],
                      onSelected: (val) {
                        _gsQueueStat = val!;
                      },
                      initialSelection: _gsQueueStat,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Customer
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {},
                        initialValue: _gsCustomer,
                        enabled: false,
                      ),
                    ),
//New Estimate load
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        children: [
                          //New estimate load +-8 kilo
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-8 kilo"),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo < 8) {
                                      setState(() => _giFinalKilo = 0);
                                      setState(() => _giFinalPrice = 0);
                                      setState(() => _giFinalLoad = 0);
                                    } else {
                                      if (_giFinalKilo % 8 != 0) {
                                        _giFinalKilo =
                                            _giFinalKilo - (_giFinalKilo % 8);
                                      } else {
                                        _giFinalKilo = _giFinalKilo - 8;
                                      }

                                      setState(
                                        () => _giFinalKilo,
                                      );

                                      setState(() => _giFinalPrice =
                                          (_giFinalKilo ~/ 8) * 155);
                                      setState(() =>
                                          _giFinalLoad = (_giFinalKilo ~/ 8));
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo % 8 != 0) {
                                      _giFinalKilo =
                                          _giFinalKilo + 8 - (_giFinalKilo % 8);
                                    } else {
                                      _giFinalKilo = _giFinalKilo + 8;
                                    }

                                    _giFinalPrice = (_giFinalKilo ~/ 8) * 155;
                                    _giFinalLoad = _giFinalKilo ~/ 8;

                                    setState(() => _giFinalKilo);
                                    setState(() => _giFinalPrice);
                                    setState(() => _giFinalLoad);
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+8 kilo"),
                              ],
                            ),
                          ),
                          //New Estimate Load display
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Weight: $_giFinalKilo kilo"),
                                Text("Load(s): $_giFinalLoad"),
                                Text(
                                    "Price: ${_PriceDisplay(_giFinalPrice)}.00"),
                              ],
                            ),
                          ),
                          //New Estimate Load (+- 1 kilo)
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 kilo"),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo > 8) {
                                      if (_giFinalKilo % 8 == 1) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                        setState(() =>
                                            _giFinalLoad = _giFinalLoad - 1);
                                      } else if (_giFinalKilo % 8 == 2) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 45);
                                      } else if (_giFinalKilo % 8 == 3) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 4) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 5) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 25);
                                      } else if (_giFinalKilo % 8 == 6) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice - 10);
                                      }

                                      setState(() =>
                                          _giFinalKilo = _giFinalKilo - 1);
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (_giFinalKilo >= 8) {
                                      setState(() =>
                                          _giFinalKilo = _giFinalKilo + 1);
                                    }

                                    if (_giFinalKilo % 8 == 1) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 2) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 45);
                                      setState(() =>
                                          _giFinalLoad = _giFinalLoad + 1);
                                    } else if (_giFinalKilo % 8 == 3) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 4) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else if (_giFinalKilo % 8 == 5) {
                                      setState(() =>
                                          _giFinalPrice = _giFinalPrice + 25);
                                    } else {
                                      if (_giFinalPrice % 155 != 0) {
                                        setState(() =>
                                            _giFinalPrice = _giFinalPrice + 10);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 kilo"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //New Estimate Load End

                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //Final Estimate Load
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         "Initial Load: $_giInitialLoad",
                    //         style: TextStyle(fontSize: 10),
                    //       ),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           IconButton(
                    //             onPressed: () {
                    //               setState(() => _giFinalLoad--);
                    //             },
                    //             icon: const Icon(Icons.remove),
                    //             color: Colors.blueAccent,
                    //           ),
                    //           Text("Final Load: $_giFinalLoad"),
                    //           IconButton(
                    //             onPressed: () {
                    //               setState(() => _giFinalLoad++);
                    //             },
                    //             icon: const Icon(Icons.add),
                    //             color: Colors.blueAccent,
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // //Final Price
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         "Initial Price: $_giInitialPrice",
                    //         style: TextStyle(fontSize: 10),
                    //       ),
                    //       TextFormField(
                    //         keyboardType: TextInputType.number,
                    //         inputFormatters: <TextInputFormatter>[
                    //           FilteringTextInputFormatter.allow(
                    //               RegExp(r'[0-9]')),
                    //           FilteringTextInputFormatter.digitsOnly
                    //         ],
                    //         textAlign: TextAlign.center,
                    //         decoration: InputDecoration(
                    //             labelText: 'Final Price',
                    //             hintText: 'Initial Price'),
                    //         validator: (val) {
                    //           _giFinalPrice = int.parse(val!);
                    //         },
                    //         initialValue: _giFinalPrice.toString(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //extra dry
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Extra dry(15=10min, 30=20min, 45=30min)",
                            style: TextStyle(fontSize: 9),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() =>
                                      _giExtraDryPrice = _giExtraDryPrice - 15);
                                  if (_giExtraDryPrice < 0) {
                                    _giExtraDryPrice = 0;
                                  }
                                },
                                icon: const Icon(Icons.remove),
                                color: Colors.blueAccent,
                              ),
                              Text("Extra Dry: $_giExtraDryPrice Php"),
                              IconButton(
                                onPressed: () {
                                  setState(() =>
                                      _giExtraDryPrice = _giExtraDryPrice + 15);

                                  if (_giExtraDryPrice > 45) {
                                    _giExtraDryPrice = 45;
                                  }
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment
                    DropdownMenu(
                      label: Text("Payment",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Payment",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Unpaid", label: "Unpaid"),
                        DropdownMenuEntry(value: "PaidCash", label: "PaidCash"),
                        DropdownMenuEntry(
                            value: "PaidGcash", label: "PaidGcash"),
                        DropdownMenuEntry(
                            value: "WaitingGcash", label: "WaitingGcash"),
                        DropdownMenuEntry(value: "Kulang", label: "Kulang"),
                        DropdownMenuEntry(value: "MaySukli", label: "MaySukli"),
                      ],
                      onSelected: (val) {
                        _gsPaymentStat = val!;
                      },
                      initialSelection: _gsPaymentStat,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment Received By
                    DropdownMenu(
                      label: Text("Payment Received By",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Select Staff",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "N/a", label: "N/a"),
                        DropdownMenuEntry(value: "Jeng", label: "Jeng"),
                        DropdownMenuEntry(value: "Abi", label: "Abi"),
                        DropdownMenuEntry(value: "Ket", label: "Ket"),
                        DropdownMenuEntry(value: "DonP", label: "DonP"),
                        DropdownMenuEntry(value: "Rowel", label: "Rowel"),
                        DropdownMenuEntry(value: "Seigi", label: "Seigi"),
                        DropdownMenuEntry(value: "Let", label: "Let"),
                      ],
                      onSelected: (val) {
                        _gsPaymentReceivedBy = val!;
                      },
                      initialSelection: _gsPaymentReceivedBy,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Kulang
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Kulang bayad',
                            hintText: 'Magkano kulang?'),
                        validator: (val) {
                          _giKulang = int.parse(val!);
                        },
                        initialValue: _giKulang.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //May Sukli
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'May Sukli', hintText: 'Magkano sukli?'),
                        validator: (val) {
                          _giMaySukli = int.parse(val!);
                        },
                        initialValue: _giMaySukli.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _udpateOnGoingRecord(),

          //move to JobsDone
          _autoDone(),

          //go back to Queue
          _deleteOnGoing(),
        ],
      ),
    );
  }

  //open new expense box
  void alterNumberMobile(int jobsId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Swapping no. #$jobsId",
          style: TextStyle(backgroundColor: Colors.green[50]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                //Alter Display
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    DropdownButton<String>(
                      hint: Text("Select"),
                      value: _selectedNumber,
                      onChanged: (val) {
                        setState(() {
                          _selectedNumber = val!;
                        });
                      },
                      items: listNumbering
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.amberAccent)),
                        onPressed: () {
                          updateSwap("#$jobsId", _selectedNumber);
                        },
                        child: Text(
                            "Click this to swap number #$jobsId to $_selectedNumber")),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _closeButton(),

          //swap jobs id
          //_swapJobsId("#$jobsId", _selectedNumber)
        ],
      ),
    );
  }

  //open new expense box
  void alterDoneMobile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Change JobsDone",
          style: TextStyle(backgroundColor: Colors.green[50]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                //Alter Display
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    DropdownMenu(
                      label: Text("Status",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Status",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                            value: "WaitCustomerPickup",
                            label: "WaitCustomerPickup"),
                        DropdownMenuEntry(
                            value: "WaitRiderDelivery",
                            label: "WaitRiderDelivery"),
                        DropdownMenuEntry(
                            value: "NasaCustomerNa", label: "NasaCustomerNa"),
                        DropdownMenuEntry(
                            value: "RiderOnDelivery", label: "RiderOnDelivery"),
                      ],
                      onSelected: (val) {
                        _gsQueueStat = val!;
                      },
                      initialSelection: _gsQueueStat,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Customer
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {},
                        initialValue: _gsCustomer,
                        enabled: false,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    //Final Estimate Load
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Initial Load: $_giInitialLoad",
                            style: TextStyle(fontSize: 10),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() => _giFinalLoad--);
                                },
                                icon: const Icon(Icons.remove),
                                color: Colors.blueAccent,
                              ),
                              Text("Final Load: $_giFinalLoad"),
                              IconButton(
                                onPressed: () {
                                  setState(() => _giFinalLoad++);
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Final Price
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        children: [
                          Text(
                            "Initial Price: $_giInitialPrice",
                            style: TextStyle(fontSize: 10),
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                labelText: 'Final Price',
                                hintText: 'Initial Price'),
                            validator: (val) {
                              _giFinalPrice = int.parse(val!);
                            },
                            initialValue: _giFinalPrice.toString(),
                          ),
                        ],
                      ),
                    ),
                    //extra dry
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Extra dry(+15Php=10min, +30Php=20min, +45Php=30min)",
                            style: TextStyle(fontSize: 10),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() =>
                                      _giExtraDryPrice = _giExtraDryPrice - 15);
                                  if (_giExtraDryPrice < 0) {
                                    _giExtraDryPrice = 0;
                                  }
                                },
                                icon: const Icon(Icons.remove),
                                color: Colors.blueAccent,
                              ),
                              Text("Extra Dry: $_giExtraDryPrice Php"),
                              IconButton(
                                onPressed: () {
                                  setState(() =>
                                      _giExtraDryPrice = _giExtraDryPrice + 15);
                                  if (_giExtraDryPrice > 45) {
                                    _giExtraDryPrice = 45;
                                  }
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment
                    DropdownMenu(
                      label: Text("Payment",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Payment",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "Unpaid", label: "Unpaid"),
                        DropdownMenuEntry(value: "PaidCash", label: "PaidCash"),
                        DropdownMenuEntry(
                            value: "PaidGcash", label: "PaidGcash"),
                        DropdownMenuEntry(
                            value: "WaitingGcash", label: "WaitingGcash"),
                        DropdownMenuEntry(value: "Kulang", label: "Kulang"),
                        DropdownMenuEntry(value: "MaySukli", label: "MaySukli"),
                      ],
                      onSelected: (val) {
                        _gsPaymentStat = val!;
                      },
                      initialSelection: _gsPaymentStat,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment Received By
                    DropdownMenu(
                      label: Text("Payment Received By",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDownQueueMobile(),
                      hintText: "Select Staff",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: "N/a", label: "N/a"),
                        DropdownMenuEntry(value: "Jeng", label: "Jeng"),
                        DropdownMenuEntry(value: "Abi", label: "Abi"),
                        DropdownMenuEntry(value: "Ket", label: "Ket"),
                        DropdownMenuEntry(value: "DonP", label: "DonP"),
                        DropdownMenuEntry(value: "Rowel", label: "Rowel"),
                        DropdownMenuEntry(value: "Seigi", label: "Seigi"),
                        DropdownMenuEntry(value: "Let", label: "Let"),
                      ],
                      onSelected: (val) {
                        _gsPaymentReceivedBy = val!;
                      },
                      initialSelection: _gsPaymentReceivedBy,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Kulang
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Kulang bayad',
                            hintText: 'Magkano kulang?'),
                        validator: (val) {
                          _giKulang = int.parse(val!);
                        },
                        initialValue: _giKulang.toString(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //May Sukli
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'May Sukli', hintText: 'Magkano sukli?'),
                        validator: (val) {
                          _giMaySukli = int.parse(val!);
                        },
                        initialValue: _giMaySukli.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _udpateDoneRecord(),

          //move to JobsDone

          //go back to Queue
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Cancel"));
  }

  Widget _closeButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Close"));
  }

  Widget _updateQueueRecord() {
    return MaterialButton(
      onPressed: () {
        if (_formKeyQueueMobile.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          _updateDataQueueMobile();
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
  }

  Widget _udpateOnGoingRecord() {
    return MaterialButton(
      onPressed: () {
        if (_formKeyQueueMobile.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          _updateDataOnGoingMobile();
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
  }

  Widget _udpateDoneRecord() {
    return MaterialButton(
      onPressed: () {
        if (_formKeyQueueMobile.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          _updateDataDoneMobile();
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
  }

  Widget _autoOnGoing() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        if (_giFinalVacantJobsId <= 25) {
          //insertDataJobsOnGoing();
          showAutoOnGoingDialog(context, "Move to on-going?");
        } else {
          messageResultQueueMobile(context, "On Going is full");
        }
      },
      color: cButtons,
      child: Text("OnGoing"),
    );
  }

  Widget _autoDone() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        showAutoDoneDialog(context, "Move to JobsDone?");

        //insertDataJobsDone();
      },
      color: cButtons,
      child: Text("JobsDone"),
    );
  }

  void insertDataJobsOnGoing() {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnGoing');
    collRef
        .add({
          'JobsId': _giFinalVacantJobsId,
          'DateW': DateTime.now(),
          'A1_DateQ': _gtDateQ,
          'A4_CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'A6_InitialKilo': _giInitialKilo,
          'A7_InitialLoad': _giInitialLoad,
          'A8_InitialPrice': _giInitialPrice,
          'B1_FinalKilo': _giFinalKilo,
          'B2_FinalLoad': _giFinalLoad,
          'B3_FinalPrice': _giFinalPrice,
          'QueueStat': "Waiting",
          'PaymentStat': _gsPaymentStat,
          'C9_PaymentReceivedBy': _gsPaymentReceivedBy,
          'B9_NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'C1_Fold': _gbFold,
          'C2_Mix': _gbMix,
          'C3_Basket': _giBasket,
          'C4_Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
          'ExtraDryPrice': 0,
        })
        .then((value) => {
              _deleteDataQueueMobile(),
              messageResult(context, "Move to ongoing.$_gsCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));

    //re-read
  }

  void insertDataJobsDone() {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsDone');
    collRef
        .add({
          'JobsId': _giJobsId,
          'D7_DateD': DateTime.now(),
          'DateW': _gtDateW,
          'A1_DateQ': _gtDateQ,
          'A4_CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'A6_InitialKilo': _giInitialKilo,
          'A7_InitialLoad': _giInitialLoad,
          'A8_InitialPrice': _giInitialPrice,
          'B1_FinalKilo': _giFinalKilo,
          'B2_FinalLoad': _giFinalLoad,
          'B3_FinalPrice': _giFinalPrice,
          'QueueStat': "WaitCustomerPickup",
          'PaymentStat': _gsPaymentStat,
          'C9_PaymentReceivedBy': _gsPaymentReceivedBy,
          'B9_NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'C1_Fold': _gbFold,
          'C2_Mix': _gbMix,
          'C3_Basket': _giBasket,
          'C4_Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
          'ExtraDryPrice': _giExtraDryPrice,
        })
        .then((value) => {
              _deleteDataOnGoingMobile(),
              messageResult(context, "Move to Jobs Done.$_gsCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));

    //re-read
  }

  Widget _deleteQueue() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        showDeleteQueueDialog(context, "Do you want to delete $_gsCustomer?");
      },
      color: cButtons,
      child: const Text("Delete"),
    );
  }

  Widget _deleteOnGoing() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        showDeleteOnGoingDialog(context, "Delete ongoing for $_gsCustomer?");
      },
      color: cButtons,
      child: const Text("Delete"),
    );
  }

  Future<bool> showDeleteQueueDialog(
      BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        _deleteDataQueueMobile();

        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  Future<bool> showDeleteOnGoingDialog(
      BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        _deleteDataOnGoingMobile();

        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  Future<bool> showAutoOnGoingDialog(
      BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        insertDataJobsOnGoing();

        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  Future<bool> showAutoDoneDialog(BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("No"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Yes"),
      onPressed: () {
        insertDataJobsDone();

        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert!"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  void messageResultQueueMobile(BuildContext context, String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  color: cButtons,
                  child: const Text("Ok"),
                ),
              ],
            ));
  }

  getThemeDropDownQueueMobile() {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints.tight(const Size.fromHeight(40)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _updateDataQueueMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnQueue');

    collRef
        .doc(_gsId)
        .set({
          'A1_DateQ': _gtDateQ,
          'A4_CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'A6_InitialKilo': _giInitialKilo,
          'A7_InitialLoad': _giInitialLoad,
          'A8_InitialPrice': _giInitialPrice,
          'B1_FinalKilo': _giFinalKilo,
          'B2_FinalLoad': _giFinalLoad,
          'B3_FinalPrice': _giFinalPrice,
          //'QueueStat': _gsQueueStat,
          'QueueStat': (_bRiderPickup
              ? mapQueueStat[riderPickup].toString()
              : mapQueueStat[forSorting].toString()),
          'PaymentStat': _gsPaymentStat,
          'C9_PaymentReceivedBy': _gsPaymentReceivedBy,
          'B9_NeedOn': Timestamp.fromDate(_gdNeedOn),
          'MaxFab': _gbMaxFab,
          'C1_Fold': _gbFold,
          'C2_Mix': _gbMix,
          'C3_Basket': _giBasket,
          'C4_Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
        })
        .then((value) => {
              messageResultQueueMobile(context, "Updates Done on $_gsCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
  }

  Future<void> moveUp(int jobsId) async {
    var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
    var querySnapshots = await collection.get();
    for (var doc in querySnapshots.docs) {
      if (jobsId == 1) {
        //updatePrevOne25(jobsId);
        //break;
        if (doc['JobsId'] == 1) {
          await doc.reference.update({
            'JobsId': 25,
          });
        }
        if (doc['JobsId'] == 25) {
          await doc.reference.update({
            'JobsId': 1,
          });
        }
      } else {
        if ((jobsId - 1) == doc['JobsId']) {
          await doc.reference.update({
            'JobsId': jobsId,
          });
        } else if ((jobsId) == doc['JobsId']) {
          await doc.reference.update({
            'JobsId': jobsId - 1,
          });
        }
      }
    }
  }

  void updateSwap(String sourceJobsId, String destinationJobsId) async {
    var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
    var querySnapshots = await collection.get();
    for (var doc in querySnapshots.docs) {
      if (destinationJobsId == "#${doc['JobsId']}") {
        await doc.reference.update({
          'JobsId': int.parse(sourceJobsId.replaceAll("#", "")),
        }).catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
        ;
      } else if (sourceJobsId == "#${doc['JobsId']}") {
        await doc.reference.update({
          'JobsId': int.parse(destinationJobsId.replaceAll("#", "")),
        }).catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
      }
    }
  }

  Future<void> updatePrevOne25(int jobsId) async {
    var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
    var querySnapshots = await collection.get();
    bool b25isWaiting = false;
    for (var doc in querySnapshots.docs.reversed) {
      if (jobsId == 1) {
        if (doc['JobsId'] == 25 && doc['QueueStat'] == "Waiting") {
          b25isWaiting = true;
          await doc.reference.update({
            'JobsId': 25,
          });
        } else if (doc['JobsId'] == 1 && b25isWaiting) {
          await doc.reference.update({
            'JobsId': 1,
          });
        }
      }
    }
  }

  void _updateDataOnGoingMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnGoing');
    collRef
        .doc(_gsId)
        .set({
          'JobsId': _giJobsId,
          'DateW': _gtDateW,
          'A1_DateQ': _gtDateQ,
          'A4_CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'A6_InitialKilo': _giInitialKilo,
          'A7_InitialLoad': _giInitialLoad,
          'A8_InitialPrice': _giInitialPrice,
          'B1_FinalKilo': _giFinalKilo,
          'B2_FinalLoad': _giFinalLoad,
          'B3_FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'C9_PaymentReceivedBy': _gsPaymentReceivedBy,
          'B9_NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'C1_Fold': _gbFold,
          'C2_Mix': _gbMix,
          'C3_Basket': _giBasket,
          'C4_Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
          'ExtraDryPrice': _giExtraDryPrice,
        })
        .then((value) => {
              messageResultQueueMobile(context, "Updates Done on $_gsCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
  }

  void _updateDataDoneMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsDone');
    collRef
        .doc(_gsId)
        .set({
          'JobsId': _giJobsId,
          'D7_DateD': _gtDateD,
          'DateW': _gtDateW,
          'A1_DateQ': _gtDateQ,
          'A4_CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'A6_InitialKilo': _giInitialKilo,
          'A7_InitialLoad': _giInitialLoad,
          'A8_InitialPrice': _giInitialPrice,
          'B1_FinalKilo': _giFinalKilo,
          'B2_FinalLoad': _giFinalLoad,
          'B3_FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'C9_PaymentReceivedBy': _gsPaymentReceivedBy,
          'B9_NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'C1_Fold': _gbFold,
          'C2_Mix': _gbMix,
          'C3_Basket': _giBasket,
          'C4_Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
          'ExtraDryPrice': _giExtraDryPrice,
        })
        .then((value) => {
              messageResultQueueMobile(context, "Updates Done on $_gsCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
  }

  void _deleteDataQueueMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnQueue');
    collRef
        .doc(_gsId)
        .delete()
        .then((value) => {})
        // ignore: invalid_return_type_for_catch_error
        .catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
  }

  void _deleteDataOnGoingMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnGoing');
    collRef
        .doc(_gsId)
        .delete()
        .then((value) => {})
        // ignore: invalid_return_type_for_catch_error
        .catchError(
            (error) => messageResultQueueMobile(context, "Failed : $error"));
  }

  Color _getCOlorStatus(String stat) {
//JobsOnQueue Colors
    if (stat == mapQueueStat[riderPickup].toString()) {
      return cRiderPickup;
    } else if (stat == mapQueueStat[forSorting].toString()) {
      return cForSorting;
    } else if (stat == mapQueueStat[waitingStat].toString()) {
      return cWaiting;
    } else if (stat == mapQueueStat[washingStat].toString()) {
      return cWashing;
    } else if (stat == mapQueueStat[dryingStat].toString()) {
      return cDrying;
    } else if (stat == mapQueueStat[foldingStat].toString()) {
      return cFolding;
    } else if (stat == mapQueueStat[waitCustomerPickup].toString()) {
      return cWaitCustomerPickup;
    } else if (stat == mapQueueStat[waitRiderDelivery].toString()) {
      return cWaitRiderDelivery;
    } else if (stat == mapQueueStat[nasaCustomerNa].toString()) {
      return cNasaCustomerNa;
    } else if (stat == "RiderOnDelivery") {
      return cRiderOnDelivery;
    } else {
      return cRiderOnDelivery;
    }
    ;
  }

  Color _getCOlorStatusJson(JobsOnQueueModel jobsOnQueueModel) {
//JobsOnQueue Colors
    if (jobsOnQueueModel.riderPickup) {
      return cRiderPickup;
    } else if (jobsOnQueueModel.forSorting) {
      return cForSorting;
    } else if (jobsOnQueueModel.waiting) {
      return cWaiting;
    } else if (jobsOnQueueModel.washing) {
      return cWashing;
    } else if (jobsOnQueueModel.drying) {
      return cDrying;
    } else if (jobsOnQueueModel.folding) {
      return cFolding;
    } else if (jobsOnQueueModel.waitCustomerPickup) {
      return cWaitCustomerPickup;
    } else if (jobsOnQueueModel.waitRiderDelivery) {
      return cWaitRiderDelivery;
    } else if (jobsOnQueueModel.nasaCustomerNa) {
      return cNasaCustomerNa;
    } else {
      return cRiderOnDelivery;
    }
    ;
  }

  String _PriceDisplay(int price) {
    int x = 0, y = 0, z = 0;
    if (price % 155 == 0) {
      return "Php $price";
    } else {
      if (price ~/ 155 == 1) {
        return "Php $price";
      } else {
        x = price ~/ 155;
        x--;
        x = x * 155;
        y = price % 155;
        y = y + 155;
        z = x + y;
        return "$x($y)=Php $z";
      }
    }
  }

  //jobsonqueuejson
  void editAll(
    JobsOnQueueModel jobsOnQueueModelEditAll,
    bool bRiderPickupEditAll,
    bool bRegularSabonEditAll,
    bool bSayoSabonEditAll,
    bool bOtherServicesEditAll,
    bool bNotOtherServicesEditAll,
    bool bAddOnEditAll,
    bool bDetAddOnEditAll,
    bool bFabAddOnEditAll,
    bool bBleAddOnEditAll,
    bool bOthAddOnEditAll,
    bool bUnpaidEditAll,
    bool bPaidCashEditAll,
    bool bPaidGCashEditAll,
    TextEditingController remarksControllerEditAll,
    DateTime dNeedOnEditAll,
    String docId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit All ${DateTime.now().toString().substring(5, 13)}",
          style: TextStyle(backgroundColor: Colors.amber[300]),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                key: _formKeyQueueMobile,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {},
                        initialValue: customerName(
                            jobsOnQueueModelEditAll.customerId.toString()),
                        enabled: false,
                      ),
                    ),
                    //QueueStat
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Sort"),
                          Switch.adaptive(
                            value: bRiderPickupEditAll,
                            onChanged: (bool value) {
                              setState(() {
                                /*
                                jobsOnQueueModelEditAll.queueStat = (value
                                    ? mapQueueStat[riderPickup].toString()
                                    : mapQueueStat[forSorting].toString());
                                    */

                                bRiderPickupEditAll = value;
                              });
                            },
                          ),
                          Text("RiderPickup"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Regular",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Checkbox(
                                      value: bRegularSabonEditAll,
                                      onChanged: (val) {
                                        jobsOnQueueModelEditAll = resetRegular(
                                            jobsOnQueueModelEditAll);

                                        if (val!) {
                                          setState(
                                            () {
                                              bRegularSabonEditAll = val;
                                            },
                                          );
                                        }

                                        jobsOnQueueModelEditAll.initialKilo = 8;
                                        jobsOnQueueModelEditAll.initialPrice =
                                            (jobsOnQueueModelEditAll
                                                        .initialKilo ~/
                                                    8) *
                                                iPriceDivider(
                                                    bRegularSabonEditAll);
                                        jobsOnQueueModelEditAll.initialLoad =
                                            (jobsOnQueueModelEditAll
                                                    .initialKilo ~/
                                                8);
                                      })
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Sayo Sabon",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Checkbox(
                                      value: bSayoSabonEditAll,
                                      onChanged: (val) {
                                        jobsOnQueueModelEditAll = resetRegular(
                                            jobsOnQueueModelEditAll);

                                        if (val!) {
                                          setState(
                                            () {
                                              bSayoSabonEditAll = val;
                                            },
                                          );
                                        }

                                        jobsOnQueueModelEditAll.initialKilo = 8;
                                        jobsOnQueueModelEditAll.initialPrice =
                                            (jobsOnQueueModelEditAll
                                                        .initialKilo ~/
                                                    8) *
                                                iPriceDivider(
                                                    bRegularSabonEditAll);
                                        jobsOnQueueModelEditAll.initialLoad =
                                            (jobsOnQueueModelEditAll
                                                    .initialKilo ~/
                                                8);
                                      })
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Others",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Checkbox(
                                      value: bOtherServicesEditAll,
                                      onChanged: (val) {
                                        jobsOnQueueModelEditAll = resetRegular(
                                            jobsOnQueueModelEditAll);
                                        bNotOtherServicesEditAll = false;

                                        if (val!) {
                                          setState(
                                            () {
                                              bOtherServicesEditAll = val;
                                            },
                                          );
                                        }

                                        jobsOnQueueModelEditAll.initialKilo = 0;
                                        jobsOnQueueModelEditAll.initialPrice =
                                            0;
                                        jobsOnQueueModelEditAll.initialLoad = 0;
                                      })
                                ],
                              ),
                            ],
                          ),
                          //New estimate load +-8 kilo
                          Visibility(
                            visible: bNotOtherServicesEditAll,
                            child: Container(
                              padding: EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 3, bottom: 0, top: 0, right: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.amber[200],
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (jobsOnQueueModelEditAll
                                                    .initialKilo <
                                                8) {
                                              jobsOnQueueModelEditAll
                                                  .initialKilo = 8;
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  (jobsOnQueueModelEditAll
                                                              .initialKilo ~/
                                                          8) *
                                                      iPriceDivider(
                                                          bRegularSabonEditAll);
                                              jobsOnQueueModelEditAll
                                                      .initialLoad =
                                                  (jobsOnQueueModelEditAll
                                                          .initialKilo ~/
                                                      8);
                                            } else {
                                              if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 !=
                                                  0) {
                                                jobsOnQueueModelEditAll
                                                        .initialKilo =
                                                    jobsOnQueueModelEditAll
                                                            .initialKilo -
                                                        (jobsOnQueueModelEditAll
                                                                .initialKilo %
                                                            8);
                                              } else {
                                                jobsOnQueueModelEditAll
                                                        .initialKilo =
                                                    jobsOnQueueModelEditAll
                                                            .initialKilo -
                                                        8;
                                              }

                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  (jobsOnQueueModelEditAll
                                                              .initialKilo ~/
                                                          8) *
                                                      iPriceDivider(
                                                          bRegularSabonEditAll);

                                              jobsOnQueueModelEditAll
                                                      .initialLoad =
                                                  (jobsOnQueueModelEditAll
                                                          .initialKilo ~/
                                                      8);
                                            }
                                            setState(() {
                                              jobsOnQueueModelEditAll
                                                  .initialKilo;
                                              jobsOnQueueModelEditAll
                                                  .initialLoad;
                                              jobsOnQueueModelEditAll
                                                  .initialPrice;
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_outlined),
                                          color: Colors.blueAccent,
                                        ),
                                        Text("-8 kg"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 3, bottom: 0, top: 0, right: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.amber[200],
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("+8 kg"),
                                        IconButton(
                                          onPressed: () {
                                            if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 !=
                                                0) {
                                              jobsOnQueueModelEditAll
                                                      .initialKilo =
                                                  jobsOnQueueModelEditAll
                                                          .initialKilo +
                                                      8 -
                                                      (jobsOnQueueModelEditAll
                                                              .initialKilo %
                                                          8);
                                            } else {
                                              jobsOnQueueModelEditAll
                                                      .initialKilo =
                                                  jobsOnQueueModelEditAll
                                                          .initialKilo +
                                                      8;
                                            }

                                            jobsOnQueueModelEditAll
                                                    .initialPrice =
                                                (jobsOnQueueModelEditAll
                                                            .initialKilo ~/
                                                        8) *
                                                    (iPriceDivider(
                                                        bRegularSabonEditAll));
                                            jobsOnQueueModelEditAll
                                                    .initialLoad =
                                                jobsOnQueueModelEditAll
                                                        .initialKilo ~/
                                                    8;
                                            setState(() {
                                              jobsOnQueueModelEditAll
                                                  .initialKilo;
                                              jobsOnQueueModelEditAll
                                                  .initialLoad;
                                              jobsOnQueueModelEditAll
                                                  .initialPrice;
                                            });
                                          },
                                          icon: const Icon(Icons.add_circle),
                                          color: Colors.blueAccent,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          //New Estimate Load display
                          Visibility(
                            visible: bNotOtherServicesEditAll,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Weight:"),
                                        Text(
                                            "${kiloDisplay(jobsOnQueueModelEditAll.initialKilo)} kilo"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Load:"),
                                        Text(
                                            "${jobsOnQueueModelEditAll.initialKilo}"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Load Price:"),
                                        Text(
                                            "${autoPriceDisplay(jobsOnQueueModelEditAll.initialPrice, bRegularSabonEditAll)}.00"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Price:"),
                                        Text(
                                            "Php ${jobsOnQueueModelEditAll.initialPrice + jobsOnQueueModelEditAll.initialOthersPrice}.00"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //New Estimate Load (+- 1 kilo)
                          Visibility(
                            visible: bNotOtherServicesEditAll,
                            child: Container(
                              padding: EdgeInsets.all(0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 3, bottom: 0, top: 0, right: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.amber[200],
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (jobsOnQueueModelEditAll
                                                    .initialKilo >
                                                8) {
                                              if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  1) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 25
                                                            : 25); //8-9kilo 25

                                                jobsOnQueueModelEditAll
                                                        .initialLoad =
                                                    jobsOnQueueModelEditAll
                                                            .initialLoad -
                                                        1;
                                              } else if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  2) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 45
                                                            : 50); //9-10kilo 45
                                              } else if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  3) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 25
                                                            : 25); //10-11kilo 25
                                              } else if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  4) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 25
                                                            : 25); //11-12kilo
                                              } else if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  5) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 25
                                                            : 0); //12-13kilo
                                              } else if (jobsOnQueueModelEditAll
                                                          .initialKilo %
                                                      8 ==
                                                  6) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice -
                                                        (bRegularSabonEditAll
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }

                                              jobsOnQueueModelEditAll
                                                      .initialKilo =
                                                  jobsOnQueueModelEditAll
                                                          .initialKilo -
                                                      1;
                                            }
                                            setState(() {
                                              jobsOnQueueModelEditAll
                                                  .initialKilo;
                                              jobsOnQueueModelEditAll
                                                  .initialLoad;
                                              jobsOnQueueModelEditAll
                                                  .initialPrice;
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_outlined),
                                          color: Colors.blueAccent,
                                        ),
                                        Text("-1 kg"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 3, bottom: 0, top: 0, right: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.amber[200],
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20))),
                                    child: Row(
                                      children: [
                                        Text("+1 kg"),
                                        IconButton(
                                          onPressed: () {
                                            if (jobsOnQueueModelEditAll
                                                    .initialKilo >=
                                                8) {
                                              jobsOnQueueModelEditAll
                                                      .initialKilo =
                                                  jobsOnQueueModelEditAll
                                                          .initialKilo +
                                                      1;
                                            }

                                            if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 ==
                                                1) {
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  jobsOnQueueModelEditAll
                                                          .initialPrice +
                                                      (bRegularSabonEditAll
                                                          ? 25
                                                          : 25); //8-9kilo
                                            } else if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 ==
                                                2) {
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  jobsOnQueueModelEditAll
                                                          .initialPrice +
                                                      (bRegularSabonEditAll
                                                          ? 45
                                                          : 50); //9-10kilo
                                              setState(() =>
                                                  jobsOnQueueModelEditAll
                                                          .initialLoad =
                                                      jobsOnQueueModelEditAll
                                                              .initialLoad +
                                                          1);
                                            } else if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 ==
                                                3) {
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  jobsOnQueueModelEditAll
                                                          .initialPrice +
                                                      (bRegularSabonEditAll
                                                          ? 25
                                                          : 25); //10-11kilo
                                            } else if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 ==
                                                4) {
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  jobsOnQueueModelEditAll
                                                          .initialPrice +
                                                      (bRegularSabonEditAll
                                                          ? 25
                                                          : 25); //11-12kilo
                                            } else if (jobsOnQueueModelEditAll
                                                        .initialKilo %
                                                    8 ==
                                                5) {
                                              jobsOnQueueModelEditAll
                                                      .initialPrice =
                                                  jobsOnQueueModelEditAll
                                                          .initialPrice +
                                                      (bRegularSabonEditAll
                                                          ? 25
                                                          : 0); //12-13kilo
                                            } else {
                                              if (jobsOnQueueModelEditAll
                                                          .initialPrice %
                                                      (iPriceDivider(
                                                          bRegularSabonEditAll)) !=
                                                  0) {
                                                jobsOnQueueModelEditAll
                                                        .initialPrice =
                                                    jobsOnQueueModelEditAll
                                                            .initialPrice +
                                                        (bRegularSabonEditAll
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }
                                            }

                                            setState(() {
                                              jobsOnQueueModelEditAll
                                                  .initialKilo;
                                              jobsOnQueueModelEditAll
                                                  .initialLoad;
                                              jobsOnQueueModelEditAll
                                                  .initialPrice;
                                            });
                                          },
                                          icon: const Icon(Icons.add_circle),
                                          color: Colors.blueAccent,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Add On
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: decoLightBlue(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Add On",
                                style: TextStyle(fontSize: 10),
                              ),
                              Checkbox(
                                  value: bAddOnEditAll,
                                  onChanged: (val) {
                                    if (listAddOnItemsGlobal.isNotEmpty) {
                                      if (!val!) {
                                        //pop box
                                        Navigator.pop(context);
                                        messageResultEditAll(
                                            jobsOnQueueModelEditAll,
                                            bRiderPickupEditAll,
                                            bRegularSabonEditAll,
                                            bSayoSabonEditAll,
                                            bOtherServicesEditAll,
                                            bNotOtherServicesEditAll,
                                            bAddOnEditAll,
                                            bDetAddOnEditAll,
                                            bFabAddOnEditAll,
                                            bBleAddOnEditAll,
                                            bOthAddOnEditAll,
                                            bUnpaidEditAll,
                                            bPaidCashEditAll,
                                            bPaidGCashEditAll,
                                            remarksControllerEditAll,
                                            dNeedOnEditAll,
                                            docId,
                                            "Uncheck will delete add on?");
                                      }
                                    }

                                    setState(
                                      () {
                                        bAddOnEditAll = val!;
                                      },
                                    );
                                  }),
                              //checkboxes add on
                              Visibility(
                                visible: bAddOnEditAll,
                                child: Container(
                                  padding: EdgeInsets.all(1.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "Det",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Checkbox(
                                              value: bDetAddOnEditAll,
                                              onChanged: (val) {
                                                resetAddOnVar();
                                                setState(
                                                  () {
                                                    bDetAddOnEditAll = val!;
                                                  },
                                                );
                                              })
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Fab",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Checkbox(
                                              value: bFabAddOnEditAll,
                                              onChanged: (val) {
                                                resetAddOnVar();
                                                setState(
                                                  () {
                                                    bFabAddOnEditAll = val!;
                                                  },
                                                );
                                              })
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Ble",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Checkbox(
                                              value: bBleAddOnEditAll,
                                              onChanged: (val) {
                                                resetAddOnVar();
                                                setState(
                                                  () {
                                                    bBleAddOnEditAll = val!;
                                                  },
                                                );
                                              })
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "Oth",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Checkbox(
                                              value: bOthAddOnEditAll,
                                              onChanged: (val) {
                                                resetAddOnVar();
                                                setState(
                                                  () {
                                                    bOthAddOnEditAll = val!;
                                                  },
                                                );
                                              })
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //dropdown det
                              addOnDropDownEditAll(
                                bDetAddOnEditAll,
                                selectedDetVar,
                                listDetItems,
                                jobsOnQueueModelEditAll,
                                bRiderPickupEditAll,
                                bRegularSabonEditAll,
                                bSayoSabonEditAll,
                                bOtherServicesEditAll,
                                bNotOtherServicesEditAll,
                                bAddOnEditAll,
                                bDetAddOnEditAll,
                                bFabAddOnEditAll,
                                bBleAddOnEditAll,
                                bOthAddOnEditAll,
                                bUnpaidEditAll,
                                bPaidCashEditAll,
                                bPaidGCashEditAll,
                                remarksControllerEditAll,
                                dNeedOnEditAll,
                                docId,
                              ),
                              //dropdown fab
                              addOnDropDownEditAll(
                                bFabAddOnEditAll,
                                selectedFabVar,
                                listFabItems,
                                jobsOnQueueModelEditAll,
                                bRiderPickupEditAll,
                                bRegularSabonEditAll,
                                bSayoSabonEditAll,
                                bOtherServicesEditAll,
                                bNotOtherServicesEditAll,
                                bAddOnEditAll,
                                bDetAddOnEditAll,
                                bFabAddOnEditAll,
                                bBleAddOnEditAll,
                                bOthAddOnEditAll,
                                bUnpaidEditAll,
                                bPaidCashEditAll,
                                bPaidGCashEditAll,
                                remarksControllerEditAll,
                                dNeedOnEditAll,
                                docId,
                              ),
                              //dropdown ble
                              addOnDropDownEditAll(
                                bBleAddOnEditAll,
                                selectedBleVar,
                                listBleItems,
                                jobsOnQueueModelEditAll,
                                bRiderPickupEditAll,
                                bRegularSabonEditAll,
                                bSayoSabonEditAll,
                                bOtherServicesEditAll,
                                bNotOtherServicesEditAll,
                                bAddOnEditAll,
                                bDetAddOnEditAll,
                                bFabAddOnEditAll,
                                bBleAddOnEditAll,
                                bOthAddOnEditAll,
                                bUnpaidEditAll,
                                bPaidCashEditAll,
                                bPaidGCashEditAll,
                                remarksControllerEditAll,
                                dNeedOnEditAll,
                                docId,
                              ),
                              //dropdown oth
                              addOnDropDownEditAll(
                                bOthAddOnEditAll,
                                selectedOthVar,
                                listOthItems,
                                jobsOnQueueModelEditAll,
                                bRiderPickupEditAll,
                                bRegularSabonEditAll,
                                bSayoSabonEditAll,
                                bOtherServicesEditAll,
                                bNotOtherServicesEditAll,
                                bAddOnEditAll,
                                bDetAddOnEditAll,
                                bFabAddOnEditAll,
                                bBleAddOnEditAll,
                                bOthAddOnEditAll,
                                bUnpaidEditAll,
                                bPaidCashEditAll,
                                bPaidGCashEditAll,
                                remarksControllerEditAll,
                                dNeedOnEditAll,
                                docId,
                              ),
                              readAddedDataEditAll(listAddOnItemsGlobal),
                              //_dtAddedOthers(addOnItems),
                              //_addedOn(addOnItems),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Basket
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => jobsOnQueueModelEditAll.basket--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Basket: ${jobsOnQueueModelEditAll.basket}"),
                          IconButton(
                            onPressed: () {
                              setState(() => jobsOnQueueModelEditAll.basket++);
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    //Bag
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => jobsOnQueueModelEditAll.bag--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Bag: ${jobsOnQueueModelEditAll.bag}"),
                          IconButton(
                            onPressed: () {
                              setState(() => jobsOnQueueModelEditAll.bag++);
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    //Payment New
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Unpaid",
                                style: TextStyle(fontSize: 10),
                              ),
                              Checkbox(
                                  value: bUnpaidEditAll,
                                  onChanged: (val) {
                                    jobsOnQueueModelEditAll =
                                        resetPaymentQueueBool(
                                            jobsOnQueueModelEditAll);
                                    if (val!) {
                                      setState(
                                        () {
                                          bUnpaidEditAll = val;
                                        },
                                      );
                                    }
                                  })
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "PaidCash",
                                style: TextStyle(fontSize: 10),
                              ),
                              Checkbox(
                                  value: bPaidCashEditAll,
                                  onChanged: (val) {
                                    jobsOnQueueModelEditAll =
                                        resetPaymentQueueBool(
                                            jobsOnQueueModelEditAll);
                                    if (val!) {
                                      setState(
                                        () {
                                          bPaidCashEditAll = val;
                                        },
                                      );
                                    }
                                  })
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "PaidGcash",
                                style: TextStyle(fontSize: 10),
                              ),
                              Checkbox(
                                  value: bPaidGCashEditAll,
                                  onChanged: (val) {
                                    jobsOnQueueModelEditAll =
                                        resetPaymentQueueBool(
                                            jobsOnQueueModelEditAll);
                                    if (val!) {
                                      setState(
                                        () {
                                          bPaidGCashEditAll = val;
                                        },
                                      );
                                    }
                                  })
                            ],
                          ),
                        ],
                      ),
                    ),
                    //No Fold
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Fold"),
                          Switch.adaptive(
                            value: jobsOnQueueModelEditAll.fold,
                            onChanged: (bool value) {
                              setState(() {
                                jobsOnQueueModelEditAll.fold = value;
                              });
                            },
                          ),
                          Text("Fold"),
                        ],
                      ),
                    ),
                    //Dont mix
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dont Mix"),
                          Switch.adaptive(
                            value: jobsOnQueueModelEditAll.mix,
                            onChanged: (bool value) {
                              setState(() {
                                jobsOnQueueModelEditAll.mix = value;
                              });
                            },
                          ),
                          Text("Mix"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Remarks
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        textAlign: TextAlign.start,
                        controller: remarksControllerEditAll,
                        decoration: InputDecoration(
                            labelText: 'C5_Remarks', hintText: 'Anu kakaiba'),
                        validator: (val) {},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Need On Date +
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: decoAmber(),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 day"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => dNeedOnEditAll =
                                        dNeedOnEditAll.add(Duration(days: -1)));
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => dNeedOnEditAll =
                                        dNeedOnEditAll.add(Duration(days: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 day"),
                              ],
                            ),
                          ),
                          //Need On date?
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Need On: ${dNeedOnEditAll.toString().substring(5, 14)}00",
                                ),
                              ],
                            ),
                          ),
                          //Need On Date +
                          Container(
                            padding: EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(0, 212, 212, 212),
                                    width: 0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("-1 hr"),
                                IconButton(
                                  onPressed: () {
                                    setState(() => dNeedOnEditAll =
                                        dNeedOnEditAll
                                            .add(Duration(hours: -1)));
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => dNeedOnEditAll =
                                        dNeedOnEditAll.add(Duration(hours: 1)));
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                Text("+1 hr"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          //_createNewRecord(),

          //update
          _updateQueueRecordEditAll(
              docId, jobsOnQueueModelEditAll, bRiderPickupEditAll),

          //save button new
          // createNewRecordJsonEditAll(
          //   jobsOnQueueModelEditAll,
          //   bRiderPickupEditAll,
          //   bRegularSabonEditAll,
          //   bSayoSabonEditAll,
          //   bOtherServicesEditAll,
          //   bNotOtherServicesEditAll,
          //   bAddOnEditAll,
          //   bDetAddOnEditAll,
          //   bFabAddOnEditAll,
          //   bBleAddOnEditAll,
          //   bOthAddOnEditAll,
          //   bUnpaidEditAll,
          //   bPaidCashEditAll,
          //   bPaidGCashEditAll,
          //   remarksControllerEditAll,
          //   dNeedOnEditAll,
          // ),
        ],
      ),
    );
  }

  void messageResultEditAll(
      JobsOnQueueModel jobsOnQueueModelEditAll,
      bool bRiderPickupEditAll,
      bool bRegularSabonEditAll,
      bool bSayoSabonEditAll,
      bool bOtherServicesEditAll,
      bool bNotOtherServicesEditAll,
      bool bAddOnEditAll,
      bool bDetAddOnEditAll,
      bool bFabAddOnEditAll,
      bool bBleAddOnEditAll,
      bool bOthAddOnEditAll,
      bool bUnpaidEditAll,
      bool bPaidCashEditAll,
      bool bPaidGCashEditAll,
      TextEditingController remarksControllerEditAll,
      DateTime dNeedOnEditAll,
      String docId,
      String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetAddOnsGlobalVar();
                    jobsOnQueueModelEditAll.initialOthersPrice = 0;
                    resetAddOnVar();
                    editAll(
                      jobsOnQueueModelEditAll,
                      bRiderPickupEditAll,
                      bRegularSabonEditAll,
                      bSayoSabonEditAll,
                      bOtherServicesEditAll,
                      bNotOtherServicesEditAll,
                      bAddOnEditAll,
                      bDetAddOnEditAll,
                      bFabAddOnEditAll,
                      bBleAddOnEditAll,
                      bOthAddOnEditAll,
                      bUnpaidEditAll,
                      bPaidCashEditAll,
                      bPaidGCashEditAll,
                      remarksControllerEditAll,
                      dNeedOnEditAll,
                      docId,
                    );
                  },
                  color: cButtons,
                  child: const Text("Ok"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    bAddOnEditAll = true;
                    editAll(
                      jobsOnQueueModelEditAll,
                      bRiderPickupEditAll,
                      bRegularSabonEditAll,
                      bSayoSabonEditAll,
                      bOtherServicesEditAll,
                      bNotOtherServicesEditAll,
                      bAddOnEditAll,
                      bDetAddOnEditAll,
                      bFabAddOnEditAll,
                      bBleAddOnEditAll,
                      bOthAddOnEditAll,
                      bUnpaidEditAll,
                      bPaidCashEditAll,
                      bPaidGCashEditAll,
                      remarksControllerEditAll,
                      dNeedOnEditAll,
                      docId,
                    );
                  },
                  color: cButtons,
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  Visibility addOnDropDownEditAll(
    bool bDisplay,
    OtherItemModel selectedItemModel,
    List<OtherItemModel> thisListOtherItemModel,
    JobsOnQueueModel jobsOnQueueModelEditAll,
    bool bRiderPickupEditAll,
    bool bRegularSabonEditAll,
    bool bSayoSabonEditAll,
    bool bOtherServicesEditAll,
    bool bNotOtherServicesEditAll,
    bool bAddOnEditAll,
    bool bDetAddOnEditAll,
    bool bFabAddOnEditAll,
    bool bBleAddOnEditAll,
    bool bOthAddOnEditAll,
    bool bUnpaidEditAll,
    bool bPaidCashEditAll,
    bool bPaidGCashEditAll,
    TextEditingController remarksControllerEditAll,
    DateTime dNeedOnEditAll,
    String docId,
  ) {
    print('size=' + thisListOtherItemModel.length.toString());
    return Visibility(
      visible: bDisplay,
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Row(
          children: [
            DropdownButton<OtherItemModel>(
              value: selectedItemModel,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.purple[700]),
              underline: Container(
                height: 2,
                color: Colors.purple[700],
              ),
              onChanged: (newItemModel) {
                selectedItemModel = newItemModel!;
              },
              items: thisListOtherItemModel.map((OtherItemModel map) {
                return DropdownMenuItem<OtherItemModel>(
                    value: map,
                    child: Text(
                        "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
              }).toList(),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                listAddOnItemsGlobal.add(selectedItemModel);
                //reset dropdowns
                if (listDetItems.contains(selectedItemModel)) {
                  selectedDetVar = selectedItemModel;
                } else if (listFabItems.contains(selectedItemModel)) {
                  selectedFabVar = selectedItemModel;
                } else if (listBleItems.contains(selectedItemModel)) {
                  selectedBleVar = selectedItemModel;
                } else if (listOthItems.contains(selectedItemModel)) {
                  selectedOthVar = selectedItemModel;
                }
                jobsOnQueueModelEditAll.initialOthersPrice =
                    jobsOnQueueModelEditAll.initialOthersPrice +
                        selectedItemModel.itemPrice;
                editAll(
                  jobsOnQueueModelEditAll,
                  bRiderPickupEditAll,
                  bRegularSabonEditAll,
                  bSayoSabonEditAll,
                  bOtherServicesEditAll,
                  bNotOtherServicesEditAll,
                  bAddOnEditAll,
                  bDetAddOnEditAll,
                  bFabAddOnEditAll,
                  bBleAddOnEditAll,
                  bOthAddOnEditAll,
                  bUnpaidEditAll,
                  bPaidCashEditAll,
                  bPaidGCashEditAll,
                  remarksControllerEditAll,
                  dNeedOnEditAll,
                  docId,
                );
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget readAddedDataEditAll(List<OtherItemModel> listAddedOthers) {
    bool zebra = false;
    //read

    List<TableRow> rowDatas = [];

    if (listAddedOthers.isNotEmpty) {
      const rowData = TableRow(
          decoration: BoxDecoration(color: Colors.blueGrey),
          children: [
            Text(
              "Group ",
              style: TextStyle(fontSize: 10),
            ),
            Text(
              "Product ",
              style: TextStyle(fontSize: 10),
            ),
            Text(
              "Price",
              style: TextStyle(fontSize: 10),
            ),
          ]);
      rowDatas.add(rowData);
    }

    listAddedOthers.forEach((listAddedOther) {
      if (zebra) {
        zebra = false;
      } else {
        zebra = true;
      }
      final rowData = TableRow(
          decoration: BoxDecoration(color: zebra ? Colors.grey : Colors.white),
          children: [
            Text(
              listAddedOther.itemGroup,
              style: TextStyle(fontSize: 10),
            ),
            Text(
              listAddedOther.itemName,
              style: TextStyle(fontSize: 10),
            ),
            Text(
              "${listAddedOther.itemPrice}.00",
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.end,
            ),
          ]);
      rowDatas.add(rowData);
    });

    return Table(
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: rowDatas,
    );
  }

  //new createNewRecord
  Widget createNewRecordJsonEditAll(
    JobsOnQueueModel jobsOnQueueModelEditAll,
    bool bRiderPickupEditAll,
    bool bRegularSabonEditAll,
    bool bSayoSabonEditAll,
    bool bOtherServicesEditAll,
    bool bNotOtherServicesEditAll,
    bool bAddOnEditAll,
    bool bDetAddOnEditAll,
    bool bFabAddOnEditAll,
    bool bBleAddOnEditAll,
    bool bOthAddOnEditAll,
    bool bUnpaidEditAll,
    bool bPaidCashEditAll,
    bool bPaidGCashEditAll,
    TextEditingController remarksControllerEditAll,
    DateTime dNeedOnEditAll,
  ) {
    return MaterialButton(
      onPressed: () {
        if (jobsOnQueueModelEditAll.customerId == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cannot save, please add name in loyalty records first.')),
          );
        } else if (_formKeyQueueMobile.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);
          jobsOnQueueModelEditAll.dateQ = Timestamp.now();
          //jobsOnQueueModelEditAll.customerId = autocompleteSelected.customerId;
          //jobsOnQueueModelEditAll.initialOthersPrice = jobsOnQueueModelEditAll.initialOthersPrice;
          jobsOnQueueModelEditAll.finalKilo = 0;
          jobsOnQueueModelEditAll.finalLoad = 0;
          jobsOnQueueModelEditAll.finalPrice = 0;
          jobsOnQueueModelEditAll.finalOthersPrice = 0;
          // jobsOnQueueModelEditAll.queueStat = (bRiderPickupEditAll
          //     ? mapQueueStat[riderPickup].toString()
          //     : mapQueueStat[forSorting].toString());
          // jobsOnQueueModelEditAll.paymentStat = (bUnpaidEditAll
          //     ? mapPaymentStat[unpaid].toString()
          //     : (bPaidCashEditAll
          //         ? mapPaymentStat[paidCash].toString()
          //         : (bPaidGCashEditAll
          //             ? mapPaymentStat[paidGCash].toString()
          //             : mapPaymentStat[waitGCash].toString())));
          jobsOnQueueModelEditAll.paymentReceivedBy =
              (bUnpaidEditAll ? "" : empIdGlobal);
          jobsOnQueueModelEditAll.paidD = (bUnpaidEditAll
              ? Timestamp.fromDate(DateTime(2000))
              : Timestamp.now());
          jobsOnQueueModelEditAll.remarks = remarksControllerEditAll.text;

          insertDataJobsOnQueueJson(jobsOnQueueModelEditAll);
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
  }

  //insert new
  void insertDataJobsOnQueueJson(JobsOnQueueModel jobsOnQueueModel) {
    DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();

    databaseJobsOnQueue.addJobsOnQueue(jobsOnQueueModel, listAddOnItemsGlobal);

    //databaseJobsOnQueue.addJobsOnQueueSolo(jobsOnQueueModel);
  }

  Widget _updateQueueRecordEditAll(String docId,
      JobsOnQueueModel jobsOnQueueModelEditAll, bool bRiderPickupEditAll) {
    return MaterialButton(
      onPressed: () {
        if (_formKeyQueueMobile.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          _updateDataQueueMobileEditAll(docId, jobsOnQueueModelEditAll);

          // print(
          //     "Anu status $docId ${jobsOnQueueModelEditAll.queueStat}${bRiderPickupEditAll ? "Riderpickup" : "ForSorting"}");
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
  }

  void _updateDataQueueMobileEditAll(
      String docId, JobsOnQueueModel jobsOnQueueModelEditAll) {
    DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();

    ///databaseJobsOnQueue.updateJobsOnQueue(docId, jobsOnQueueModelEditAll);
  }
}
