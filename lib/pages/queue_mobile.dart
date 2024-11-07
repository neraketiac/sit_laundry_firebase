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
*/

class MyQueueMobile extends StatefulWidget {
  const MyQueueMobile({super.key});

  @override
  State<MyQueueMobile> createState() => _MyQueueMobileState();
}

class _MyQueueMobileState extends State<MyQueueMobile> {
  bool bHeader = true;

  //JobsOnQueue Colors
  final Color _gcRiderPickup = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcForSorting = Color.fromRGBO(1, 1, 1, 1);

  //JobsOnGoing Colors
  final Color _gcOnQueue = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcWashing = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcDrying = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcFolding = Color.fromRGBO(1, 1, 1, 1);

  //JobsDone Colors
  final Color _gcWaitCustomer = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcWaitCustomerPickup = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcWaitRiderDelivery = Color.fromRGBO(1, 1, 1, 1);
  final Color _gcNasaCustomerNa = Color.fromRGBO(1, 1, 1, 1); //indi pa bayad
  final Color _gcDone =
      Color.fromRGBO(1, 1, 1, 1); //Bayad na nasa customer narin

  //List<ProductsRemaining> listRemaining = [];

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
  late bool _gbOneOccupied, _gb25Occupied;
  late int _giJobsId;
  late Timestamp _gtDateW;

  final _formKeyQueueMobile = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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

                        /*Container(
                          height: 60,
                          color: Colors.red[200],
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  buffRecord['Customer'] +
                                      " (" +
                                      (_gbWithFinalLoad
                                          ? _giFinalLoad.toString()
                                          : buffRecord['InitialLoad']
                                              .toString()) +
                                      ") " +
                                      (buffRecord['Basket'] == 0
                                          ? ""
                                          : "${buffRecord['Basket']}BK") +
                                      " " +
                                      (buffRecord['Bag'] == 0
                                          ? ""
                                          : "${buffRecord['Bag']}BG"),
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${buffRecord['MaxFab'] ? "MaxFab" : ""} ${buffRecord['Mix'] ? "" : "DM"} ${buffRecord['Fold'] ? "" : "NF"}",
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  buffRecord['PaymentStat'] +
                                      ": " +
                                      (_gbWithFinalPrice
                                          ? _giFinalPrice.toString()
                                          : buffRecord['InitialPrice']
                                              .toString()) +
                                      " Php",
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  displayDate(
                                      convertTimeStamp(buffRecord['NeedOn'])),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        */
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
      height: 60,
      color: buffColor,
      child: Center(
        child: Column(
          children: [
            Text(
              "${buffJobsId == 0 ? "" : "#$buffJobsId"} $buffCustomer-(${_gbWithFinalLoad ? _giFinalLoad.toString() : buffInitialLoad.toString()}) ${buffBasket == 0 ? "" : "${buffBasket}BK"} ${buffBag == 0 ? "" : "${buffBag}BG"}",
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              "${buffMaxFab ? "MaxFab" : ""} ${buffMix ? "" : "DM"} ${buffFold ? "" : "NF"}",
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              "$buffPaymentStat: ${_gbWithFinalPrice ? _giFinalPrice.toString() : buffInitialPrice.toString()} Php",
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              displayDate(convertTimeStamp(buffNeedOn)) + " " + buffQueueStat,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
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
                decoration: BoxDecoration(color: Colors.green),
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

                        /*
                        Container(
                          height: 60,
                          color: Colors.blueGrey,
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "#${buffRecord['JobsId']} ${buffRecord['Customer']}",
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "NF",
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  " Php",
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  displayDate(
                                      convertTimeStamp(buffRecord['DateQ'])),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        */
                      ),
                    ),
                  )
                ]);
            rowDatas.add(rowData);
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
          .orderBy('DateD')
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
                        onTap: () {},
                        //Container display JobsOnGoing
                        child: _conDisplay(
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
          _udpateQueueRecord(),

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
          _udpateOnGoingRecord(),

          //move to JobsDone
          _autoDone(),

          //go back to Queue
          //_deleteQueue(),
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
        child: const Text("Cancel"));
  }

  Widget _udpateQueueRecord() {
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
      child: const Text("Save"),
    );
  }

  Widget _autoOnGoing() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        if (_giFinalVacantJobsId <= 25) {
          insertDataJobsOnGoing();
        } else {
          messageResultQueueMobile(context, "On Going is full");
        }
      },
      child: Text("OnGoing"),
    );
  }

  Widget _autoDone() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        insertDataJobsDone();
      },
      child: Text("Done"),
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
          'JobsId': _giFinalVacantJobsId,
          'DateD': DateTime.now(),
          'DateW': _gtDateW,
          'DateQ': _gtDateQ,
          'CreatedBy': _gsCreatedBy,
          'Customer': _gsCustomer,
          'InitialLoad': _giInitialLoad,
          'InitialPrice': _giInitialPrice,
          'FinalLoad': _giFinalLoad,
          'FinalPrice': _giFinalPrice,
          'QueueStat': "WaitCustomer",
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
      child: const Text("Delete"),
    );
  }

  Widget _deleteOnGoing() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        showDeleteOnGoingDialog(context, "Mark Done for $_gsCustomer?");
      },
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

  void messageResultQueueMobile(BuildContext context, String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
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
}
