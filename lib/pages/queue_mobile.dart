//import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//import 'package:laundry_firebase/variables/item_count_helper.dart';
import 'package:laundry_firebase/variables/variables.dart';

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
  const MyQueueMobile({super.key});

  @override
  State<MyQueueMobile> createState() => _MyQueueMobileState();
}

class _MyQueueMobileState extends State<MyQueueMobile> {
  bool bHeader = true;

  //JobsOnQueue Colors
  final Color _gcRiderPickup = Color.fromRGBO(62, 255, 45, 1); //rider
  final Color _gcForSorting = Color.fromRGBO(170, 170, 170, 1);

  //JobsOnGoing Colors
  final Color _gcWaiting = Color.fromRGBO(170, 170, 170, 1);
  final Color _gcWashing =
      Color.fromRGBO(31, 255, 244, 1); //same washing, drying, folding
  final Color _gcDrying =
      Color.fromRGBO(31, 255, 244, 1); //same washing, drying, folding
  final Color _gcFolding =
      Color.fromRGBO(31, 255, 244, 1); //same washing, drying, folding

  //JobsDone Colors
  final Color _gcWaitCustomerPickup = Color.fromRGBO(170, 170, 170, 1);
  final Color _gcWaitRiderDelivery = Color.fromRGBO(62, 255, 45, 1); //rider
  final Color _gcNasaCustomerNa = Color.fromRGBO(92, 91, 91, 1);
  final Color _gcRiderOnDelivery = Color.fromRGBO(62, 255, 45, 1); //rider

  final Color _gcButtons = Color.fromRGBO(134, 218, 252, 0.733);

  //JobsOnQueue

  late String _gsId;
  late Timestamp _gtDateQ;
  late String _gsCreatedBy;
  late String _gsCustomer;
  late int _giInitialLoad;
  late int _giInitialPrice;
  late String _gsQueueStat;
  late String _gsPaymentStat;
  late String _gsPaymentReceivedBy;
  late Timestamp _gtNeedOn;
  late bool _gbMaxFab;
  late bool _gbFold;
  late bool _gbMix;
  late int _giBasket;
  late int _giBag;
  late int _giKulang;
  late int _giMaySukli;

  late int _giFinalLoad;
  late int _giFinalPrice;
  late DateTime _gdNeedOn;
  late bool _gbWithFinalLoad;
  late bool _gbWithFinalPrice;

  //JobsOnGoing
  late int _giLowestVacantJobsId,
      _giHighestVacantJobsId,
      _giTempJobsId,
      _giFinalVacantJobsId;
  late bool _gbOneOccupied = false, _gb25Occupied = false;
  late int _giJobsId;
  late Timestamp _gtDateW, _gtDateD;
  late int _giVisibleCounter; //when 0 visible false;

  List<DropdownMenuItem<String>> dropdownItems = [];

  final List<String> finListNumbering = [
    "#1",
    "#2",
    "#3",
    "#4",
    "#5",
    "#6",
    "#7",
    "#8",
    "#9",
    "#10",
    "#11",
    "#12",
    "#13",
    "#14",
    "#15",
    "#16",
    "#17",
    "#18",
    "#19",
    "#20",
    "#21",
    "#22",
    "#23",
    "#24",
    "#25"
  ];

  late List<String> listNumbering;

  String _selectedNumber = "#1";
  String selectedNumberx = "Option 1";

  final _formKeyQueueMobile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _giTempJobsId = 0;

    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: const Text("M O B I L E Q U E U E"),
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
                width: 200,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataJobsOnQueue('JobsOnQueue', context),
                ]),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 200,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataJobsOnGoing('JobsOnGoing', context),
                ]),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 200,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataJobsDone('JobsDone', context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //read JobsOnQueue
  Widget _readDataJobsOnQueue(String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsOnQueue')
          .orderBy('DateQ', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration: BoxDecoration(color: Colors.red),
                children: [
                  Text(
                    "Jobs On Queue",
                    style: TextStyle(fontSize: 10),
                  ),
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

            //required initialize start
            _gbWithFinalLoad = false;
            try {
              _giFinalLoad = buffRecord['FinalLoad'];
              _gbWithFinalLoad = true;
            } on Exception catch (exception) {
            } catch (error) {}

            _gbWithFinalPrice = false;
            try {
              _giFinalPrice = buffRecord['FinalPrice'];
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
                          _gtDateQ = buffRecord['DateQ'];
                          _gsCreatedBy = buffRecord['CreatedBy'];
                          _gsCustomer = buffRecord['Customer'];
                          _giInitialLoad = buffRecord['InitialLoad'];
                          _giInitialPrice = buffRecord['InitialPrice'];
                          _gsQueueStat = buffRecord['QueueStat'];
                          _gsPaymentStat = buffRecord['PaymentStat'];
                          _gsPaymentReceivedBy =
                              buffRecord['PaymentReceivedBy'];
                          _gtNeedOn = buffRecord['NeedOn'];
                          _gbMaxFab = buffRecord['MaxFab'];
                          _gbFold = buffRecord['Fold'];
                          _gbMix = buffRecord['Mix'];
                          _giBasket = buffRecord['Basket'];
                          _giBag = buffRecord['Bag'];
                          _giKulang = buffRecord['Kulang'];
                          _giMaySukli = buffRecord['MaySukli'];

                          try {
                            _giFinalLoad = buffRecord['FinalLoad'];
                          } on Exception catch (exception) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          } catch (error) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          }

                          try {
                            _giFinalPrice = buffRecord['FinalPrice'];
                          } on Exception catch (exception) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          } catch (error) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          }

                          _gdNeedOn = _gtNeedOn.toDate();

                          alterQueueMobile();
                        },
                        //Container display JobsOnQueue
                        child: _conDisplay(
                            context,
                            false,
                            Color.fromRGBO(250, 175, 175, 1),
                            buffRecord['Customer'],
                            buffRecord['QueueStat'],
                            buffRecord['InitialLoad'],
                            buffRecord['Basket'],
                            buffRecord['Bag'],
                            buffRecord['MaxFab'],
                            buffRecord['Mix'],
                            buffRecord['Fold'],
                            buffRecord['PaymentStat'],
                            buffRecord['InitialPrice'],
                            buffRecord['NeedOn']),
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

  //read JobsOnGoing
  Widget _readDataJobsOnGoing(String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsOnGoing')
          .orderBy('JobsId')
          .snapshots(),
      builder: (context, snapshot) {
        bHeader = true;
        List<TableRow> rowDatas = [];
        if (snapshot.hasData) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 81, 229, 248)),
                children: [
                  Text(
                    "Jobs On Going",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          //body
          final buffRecords = snapshot.data?.docs.toList();

          //initialize low and high
          _giTempJobsId = 0;
          _giLowestVacantJobsId = 0;
          _giHighestVacantJobsId = 25;
          _gbOneOccupied = false;
          _gb25Occupied = false;
          _giVisibleCounter = 0;
          bool b25isWaiting = true;

          for (var buffRecord in buffRecords!.reversed) {
            if (buffRecord['JobsId'] == 25 &&
                buffRecord['QueueStat'] != "Waiting") {
              b25isWaiting = false;
            }
            break;
          }

          listNumbering = finListNumbering;

          for (var buffRecord in buffRecords!) {
            if (buffRecord['QueueStat'] != "Waiting") {
              listNumbering.remove("#${buffRecord['JobsId']}");
            }

            //required initialize start
            _gbWithFinalLoad = false;
            try {
              _giFinalLoad = buffRecord['FinalLoad'];
              _gbWithFinalLoad = true;
            } on Exception catch (exception) {
            } catch (error) {}

            _gbWithFinalPrice = false;
            try {
              _giFinalPrice = buffRecord['FinalPrice'];
              _gbWithFinalPrice = true;
            } on Exception catch (exception) {
            } catch (error) {}
            //required initialize end

            _giTempJobsId = buffRecord['JobsId'];

            if (_giTempJobsId == 1) {
              _gbOneOccupied = true;
            }
            if (_giTempJobsId == 25) {
              _gb25Occupied = true;
            }

            if ((_giLowestVacantJobsId + 1) == _giTempJobsId) {
              _giLowestVacantJobsId++;
            }

            _giHighestVacantJobsId = _giTempJobsId + 1;

            if (buffRecord['QueueStat'] != "Waiting") {
              _giVisibleCounter = 2; //0 - visible
            }

            if (buffRecord['JobsId'] == 1) {
              if (buffRecord['QueueStat'] == "Waiting") {
                if (b25isWaiting) {
                  _giVisibleCounter = 0;
                } else {
                  _giVisibleCounter = 1;
                }
              }
            }

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
                          _gtDateQ = buffRecord['DateQ'];
                          _gsCreatedBy = buffRecord['CreatedBy'];
                          _gsCustomer = buffRecord['Customer'];
                          _giInitialLoad = buffRecord['InitialLoad'];
                          _giInitialPrice = buffRecord['InitialPrice'];
                          _gsQueueStat = buffRecord['QueueStat'];
                          _gsPaymentStat = buffRecord['PaymentStat'];
                          _gsPaymentReceivedBy =
                              buffRecord['PaymentReceivedBy'];
                          _gtNeedOn = buffRecord['NeedOn'];
                          _gbMaxFab = buffRecord['MaxFab'];
                          _gbFold = buffRecord['Fold'];
                          _gbMix = buffRecord['Mix'];
                          _giBasket = buffRecord['Basket'];
                          _giBag = buffRecord['Bag'];
                          _giKulang = buffRecord['Kulang'];
                          _giMaySukli = buffRecord['MaySukli'];

                          _gtDateW = buffRecord['DateW'];
                          _giJobsId = buffRecord['JobsId'];

                          try {
                            _giFinalLoad = buffRecord['FinalLoad'];
                          } on Exception catch (exception) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          } catch (error) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          }

                          try {
                            _giFinalPrice = buffRecord['FinalPrice'];
                          } on Exception catch (exception) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          } catch (error) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          }

                          _gdNeedOn = _gtNeedOn.toDate();

                          alterOnGoingMobile();
                        },
                        //Container display JobsOnGoing
                        child: _conDisplay(
                          context,
                          (_giVisibleCounter == 0 ? true : false),
                          Color.fromRGBO(168, 173, 168, 1),
                          buffRecord['Customer'],
                          buffRecord['QueueStat'],
                          buffRecord['FinalLoad'],
                          buffRecord['Basket'],
                          buffRecord['Bag'],
                          buffRecord['MaxFab'],
                          buffRecord['Mix'],
                          buffRecord['Fold'],
                          buffRecord['PaymentStat'],
                          buffRecord['FinalPrice'],
                          buffRecord['NeedOn'],
                          buffRecord['JobsId'],
                        ),
                      ),
                    ),
                  )
                ]);
            rowDatas.add(rowData);

            _giVisibleCounter--;

            if (_giVisibleCounter < 0) {
              _giVisibleCounter = 0;
            }
          }
        }

        if (!_gbOneOccupied) {
          if (_giTempJobsId == 0) {
            //,,,,,         - 1
            _giFinalVacantJobsId = 1;
          } else if (_gb25Occupied) {
            //,,,,,,23,24,25  - 1
            _giFinalVacantJobsId = 1;
          } else if (!_gb25Occupied) {
            //,,,7,8,9,10,,,  - 11
            _giFinalVacantJobsId = _giHighestVacantJobsId;
          }
        } else if (_gbOneOccupied) {
          if (_gb25Occupied) {
            if (_giLowestVacantJobsId == 25) {
              //1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
              _giFinalVacantJobsId = 26;
            } else {
              //1,,,,,23,24,25  - 2
              _giFinalVacantJobsId = _giLowestVacantJobsId + 1;
            }
          } else if (!_gb25Occupied) {
            //1,2,3,4,,,,,    - 5
            _giFinalVacantJobsId = _giLowestVacantJobsId + 1;
          }
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

  //read JobsOnGoing
  Widget _readDataJobsDone(String streamName, BuildContext context) {
    bool zebra = false;
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('JobsDone')
          .orderBy('DateD', descending: true)
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
                    "Jobs Done",
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
              _giFinalLoad = buffRecord['FinalLoad'];
              _gbWithFinalLoad = true;
            } on Exception catch (exception) {
            } catch (error) {}

            _gbWithFinalPrice = false;
            try {
              _giFinalPrice = buffRecord['FinalPrice'];
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
                          _gtDateD = buffRecord['DateD'];
                          _gtDateW = buffRecord['DateW'];
                          _gtDateQ = buffRecord['DateQ'];
                          _gsCreatedBy = buffRecord['CreatedBy'];
                          _gsCustomer = buffRecord['Customer'];
                          _giInitialLoad = buffRecord['InitialLoad'];
                          _giInitialPrice = buffRecord['InitialPrice'];
                          _gsQueueStat = buffRecord['QueueStat'];
                          _gsPaymentStat = buffRecord['PaymentStat'];
                          _gsPaymentReceivedBy =
                              buffRecord['PaymentReceivedBy'];
                          _gtNeedOn = buffRecord['NeedOn'];
                          _gbMaxFab = buffRecord['MaxFab'];
                          _gbFold = buffRecord['Fold'];
                          _gbMix = buffRecord['Mix'];
                          _giBasket = buffRecord['Basket'];
                          _giBag = buffRecord['Bag'];
                          _giKulang = buffRecord['Kulang'];
                          _giMaySukli = buffRecord['MaySukli'];

                          _giJobsId = buffRecord['JobsId'];

                          try {
                            _giFinalLoad = buffRecord['FinalLoad'];
                          } on Exception catch (exception) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          } catch (error) {
                            _giFinalLoad = buffRecord['InitialLoad'];
                          }

                          try {
                            _giFinalPrice = buffRecord['FinalPrice'];
                          } on Exception catch (exception) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          } catch (error) {
                            _giFinalPrice = buffRecord['InitialPrice'];
                          }

                          _gdNeedOn = _gtNeedOn.toDate();

                          alterDoneMobile();
                        },
                        //Container display JobsDone
                        child: _conDisplay(
                          context,
                          false,
                          Color.fromRGBO(32, 163, 180, 1),
                          buffRecord['Customer'],
                          buffRecord['QueueStat'],
                          buffRecord['FinalLoad'],
                          buffRecord['Basket'],
                          buffRecord['Bag'],
                          buffRecord['MaxFab'],
                          buffRecord['Mix'],
                          buffRecord['Fold'],
                          buffRecord['PaymentStat'],
                          buffRecord['FinalPrice'],
                          buffRecord['NeedOn'],
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

  //Display
  Container _conDisplay(
      BuildContext context,
      bool showUpArrow,
      Color buffColor,
      String buffCustomer,
      String buffQueueStat,
      int buffInitialLoad,
      int buffBasket,
      int buffBag,
      bool buffMaxFab,
      bool buffMix,
      bool buffFold,
      String buffPaymentStat,
      int buffInitialPrice,
      Timestamp buffNeedOn,
      [int buffJobsId = 0]) {
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
                  "${buffMaxFab ? "MaxFab" : ""} ${buffMix ? "" : "DM"} ${buffFold ? "" : "NF"}",
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  "$buffPaymentStat: ${_gbWithFinalPrice ? _giFinalPrice.toString() : buffInitialPrice.toString()} Php",
                  style: TextStyle(
                      fontSize: 10,
                      backgroundColor: (buffPaymentStat == "Unpaid"
                          ? const Color.fromARGB(115, 255, 97, 97)
                          : Colors.transparent)),
                ),
                Text(
                  displayDate(convertTimeStamp(buffNeedOn)),
                  style: const TextStyle(fontSize: 10),
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
                  color: _gcButtons,
                  child: const Text("Ok"),
                ),
              ],
            ));
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
                            value: "ForSorting", label: "ForSorting"),
                        DropdownMenuEntry(
                            value: "RiderPickup", label: "RiderPickup"),
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
                        //DropdownMenuEntry(value: "Folding", label: "Folding"),
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
        color: _gcButtons,
        child: const Text("Cancel"));
  }

  Widget _closeButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        color: _gcButtons,
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
      color: _gcButtons,
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
      color: _gcButtons,
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
      color: _gcButtons,
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
      color: _gcButtons,
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
      color: _gcButtons,
      child: Text("JobsDone"),
    );
  }

  // Widget _swapJobsId(String sourceJobsId, String destinationJobsId) {
  //   return MaterialButton(
  //     onPressed: () {
  //       //pop box
  //       Navigator.pop(context);

  //       updateSwap(sourceJobsId, destinationJobsId);
  //     },
  //     color: _gcButtons,
  //     child: Text("Swap Jobs Id to $_selectedNumber"),
  //   );
  // }

  void insertDataJobsOnGoing() {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnGoing');
    collRef
        .add({
          'JobsId': _giFinalVacantJobsId,
          'DateW': DateTime.now(),
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': "Waiting",
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          'NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
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
          'DateD': DateTime.now(),
          'DateW': _gtDateW,
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': "WaitCustomerPickup",
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          'NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
          'Kulang': _giKulang,
          'MaySukli': _giMaySukli,
        })
        .then((value) => {
              _deleteDataOnGoingMobile(),
              messageResult(context, "Move to ongoing.$_gsCustomer"),
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
      color: _gcButtons,
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
      color: _gcButtons,
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
        //_autoOnGoing();
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
                  color: _gcButtons,
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
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          //'NeedOn': _gtNeedOn,
          'NeedOn': Timestamp.fromDate(_gdNeedOn),
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
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
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          'NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
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

  void _updateDataDoneFoldingMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnGoing');
    collRef
        .doc(_gsId)
        .set({
          'JobsId': _giJobsId,
          'DateW': _gtDateW,
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          'NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
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

  void _updateDataDoneMobile() {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsDone');
    collRef
        .doc(_gsId)
        .set({
          'JobsId': _giJobsId,
          'DateD': _gtDateD,
          'DateW': _gtDateW,
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': _gsQueueStat,
          'PaymentStat': _gsPaymentStat,
          'PaymentReceivedBy': _gsPaymentReceivedBy,
          'NeedOn': _gtNeedOn,
          'MaxFab': _gbMaxFab,
          'Fold': _gbFold,
          'Mix': _gbMix,
          'Basket': _giBasket,
          'Bag': _giBag,
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
    if (stat == "RiderPicup") {
      return _gcRiderPickup;
    } else if (stat == "ForSorting") {
      return _gcForSorting;
    } else if (stat == "Waiting") {
      return _gcWaiting;
    } else if (stat == "Washing") {
      return _gcWashing;
    } else if (stat == "Drying") {
      return _gcDrying;
    } else if (stat == "Folding") {
      return _gcFolding;
    } else if (stat == "WaitCustomerPickup") {
      return _gcWaitCustomerPickup;
    } else if (stat == "WaitRiderDeivery") {
      return _gcWaitRiderDelivery;
    } else if (stat == "NasaCustomerNa") {
      return _gcNasaCustomerNa;
    } else if (stat == "RiderOnDelivery") {
      return _gcRiderOnDelivery;
    } else {
      return _gcRiderOnDelivery;
    }
    ;
  }
}
