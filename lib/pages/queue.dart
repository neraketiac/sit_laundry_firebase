import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/pages/loyalty_admin.dart';
import 'package:laundry_firebase/pages/queue_mobile.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/services/database_jobsonqueue.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MyQueue extends StatefulWidget {
  final String empid;

  const MyQueue(this.empid, {super.key});

  @override
  State<MyQueue> createState() => _MyQueueState();
}

class _MyQueueState extends State<MyQueue> {
  late String _sEmpId;
  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    jobsOnQueueModelGlobal.createdBy = _sEmpId;
    jobsOnQueueModelGlobal.currentEmpId = _sEmpId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Text("watata"),
      body: MyQueueMobile(_sEmpId),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "JobsOnQueue",
            onPressed: () {
              //showJobsOnQueueEntryJson();
              showJobsOnQueue();
            },
            child: const Icon(Icons.local_laundry_service_sharp),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            heroTag: "Gcash",
            onPressed: () {},
            child: const Icon(Icons.g_mobiledata),
          ),
        ],
      ),
    );
  }

  void showJobsOnQueue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "New Laundry ${DateTime.now().toString().substring(5, 13)}",
              style: TextStyle(backgroundColor: Colors.amber[300]),
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2.0)),
                child: Form(
                  //key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      conEnterCustomer(context, setState),
                      conQueueStat(setState),
                      conOrderMode(setState),
                      visAddOn(setState),
                      conTotalPrice(setState),
                      conBasket(setState),
                      conBag(setState),
                      conPayment(setState),
                      conRemarks(setState),
                      conMoreOptions(setState),
                      visFold(setState),
                      visMix(setState),
                      visNeedOn(setState),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              //cancel button
              cancelButtonVar(context),

              //save button
              createNewJOQVar(context),
            ],
          );
        });
      },
    );
  }

/*
  //jobsonqueuejson
  void showJobsOnQueueEntryJson() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "New Laundry ${DateTime.now().toString().substring(5, 13)}",
              style: TextStyle(backgroundColor: Colors.amber[300]),
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2.0)),
                child: Form(
                  //key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.all(1.0),
                        decoration: containerQueBoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Enter Customer Name',
                              style: TextStyle(fontSize: 10),
                            ),
                            AutoCompleteCustomer(),
                            SizedBox(
                              height: 5,
                            ),
                            MaterialButton(
                              color: cButtons,
                              onPressed: () {
                                _allCards(context);
                              },
                              child: Text("New Account"),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      //QueueStat
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(1.0),
                        decoration: containerQueBoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Sort"),
                            Switch.adaptive(
                              value: gjobsOnQueueModel.riderPickup,
                              onChanged: (bool value) {
                                setState(() {
                                  gjobsOnQueueModel.riderPickup = value;
                                  if (gjobsOnQueueModel.riderPickup) {
                                    gjobsOnQueueModel.forSorting = false;
                                  } else {
                                    gjobsOnQueueModel.forSorting = true;
                                  }
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
                        decoration: containerQueBoxDecoration(),
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
                                        value: gjobsOnQueueModel.regular,
                                        onChanged: (val) {
                                          gjobsOnQueueModel =
                                              resetRegular(gjobsOnQueueModel);

                                          if (val!) {
                                            setState(
                                              () {
                                                gjobsOnQueueModel.regular = val;
                                              },
                                            );
                                          }

                                          gjobsOnQueueModel.initialKilo = 8;
                                          gjobsOnQueueModel
                                              .initialPrice = (gjobsOnQueueModel
                                                      .initialKilo ~/
                                                  8) *
                                              iPriceDivider(
                                                  gjobsOnQueueModel.regular);
                                          gjobsOnQueueModel.initialLoad =
                                              (gjobsOnQueueModel.initialKilo ~/
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
                                        value: gjobsOnQueueModel.sayosabon,
                                        onChanged: (val) {
                                          gjobsOnQueueModel =
                                              resetRegular(gjobsOnQueueModel);

                                          if (val!) {
                                            setState(
                                              () {
                                                gjobsOnQueueModel.sayosabon =
                                                    val;
                                              },
                                            );
                                          }

                                          gjobsOnQueueModel.initialKilo = 8;
                                          gjobsOnQueueModel
                                              .initialPrice = (gjobsOnQueueModel
                                                      .initialKilo ~/
                                                  8) *
                                              iPriceDivider(
                                                  gjobsOnQueueModel.regular);
                                          gjobsOnQueueModel.initialLoad =
                                              (gjobsOnQueueModel.initialKilo ~/
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
                                        value: gjobsOnQueueModel.others,
                                        onChanged: (val) {
                                          gjobsOnQueueModel =
                                              resetRegular(gjobsOnQueueModel);
                                          bShowKiloLoadDisplayVar = false;

                                          if (val!) {
                                            setState(
                                              () {
                                                gjobsOnQueueModel.others = val;
                                              },
                                            );
                                          }

                                          gjobsOnQueueModel.initialKilo = 0;
                                          gjobsOnQueueModel.initialPrice = 0;
                                          gjobsOnQueueModel.initialLoad = 0;
                                        })
                                  ],
                                ),
                              ],
                            ),
                            //New estimate load +-8 kilo
                            Visibility(
                              visible: bShowKiloLoadDisplayVar,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (gjobsOnQueueModel
                                                      .initialKilo <
                                                  8) {
                                                gjobsOnQueueModel.initialKilo =
                                                    8;
                                                gjobsOnQueueModel.initialPrice =
                                                    (gjobsOnQueueModel
                                                                .initialKilo ~/
                                                            8) *
                                                        iPriceDivider(
                                                            gjobsOnQueueModel
                                                                .regular);
                                                gjobsOnQueueModel.initialLoad =
                                                    (gjobsOnQueueModel
                                                            .initialKilo ~/
                                                        8);
                                              } else {
                                                if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 !=
                                                    0) {
                                                  gjobsOnQueueModel
                                                          .initialKilo =
                                                      gjobsOnQueueModel
                                                              .initialKilo -
                                                          (gjobsOnQueueModel
                                                                  .initialKilo %
                                                              8);
                                                } else {
                                                  gjobsOnQueueModel
                                                          .initialKilo =
                                                      gjobsOnQueueModel
                                                              .initialKilo -
                                                          8;
                                                }

                                                gjobsOnQueueModel.initialPrice =
                                                    (gjobsOnQueueModel
                                                                .initialKilo ~/
                                                            8) *
                                                        iPriceDivider(
                                                            gjobsOnQueueModel
                                                                .regular);

                                                gjobsOnQueueModel.initialLoad =
                                                    (gjobsOnQueueModel
                                                            .initialKilo ~/
                                                        8);
                                              }
                                              setState(() {
                                                gjobsOnQueueModel.initialKilo;
                                                gjobsOnQueueModel.initialLoad;
                                                gjobsOnQueueModel.initialPrice;
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
                                              bottomRight:
                                                  Radius.circular(20))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text("+8 kg"),
                                          IconButton(
                                            onPressed: () {
                                              if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 !=
                                                  0) {
                                                gjobsOnQueueModel.initialKilo =
                                                    gjobsOnQueueModel
                                                            .initialKilo +
                                                        8 -
                                                        (gjobsOnQueueModel
                                                                .initialKilo %
                                                            8);
                                              } else {
                                                gjobsOnQueueModel.initialKilo =
                                                    gjobsOnQueueModel
                                                            .initialKilo +
                                                        8;
                                              }

                                              gjobsOnQueueModel.initialPrice =
                                                  (gjobsOnQueueModel
                                                              .initialKilo ~/
                                                          8) *
                                                      (iPriceDivider(
                                                          gjobsOnQueueModel
                                                              .regular));
                                              gjobsOnQueueModel.initialLoad =
                                                  gjobsOnQueueModel
                                                          .initialKilo ~/
                                                      8;
                                              setState(() {
                                                gjobsOnQueueModel.initialKilo;
                                                gjobsOnQueueModel.initialLoad;
                                                gjobsOnQueueModel.initialPrice;
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
                              visible: bShowKiloLoadDisplayVar,
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
                                              "${kiloDisplay(gjobsOnQueueModel.initialKilo)} kilo"),
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
                                              "${gjobsOnQueueModel.initialKilo}"),
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
                                              "${autoPriceDisplay(gjobsOnQueueModel.initialPrice, gjobsOnQueueModel.regular)}.00"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //New Estimate Load (+- 1 kilo)
                            Visibility(
                              visible: bShowKiloLoadDisplayVar,
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
                                              if (gjobsOnQueueModel
                                                      .initialKilo >
                                                  8) {
                                                if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    1) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 25
                                                              : 25); //8-9kilo 25

                                                  gjobsOnQueueModel
                                                          .initialLoad =
                                                      gjobsOnQueueModel
                                                              .initialLoad -
                                                          1;
                                                } else if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    2) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 45
                                                              : 50); //9-10kilo 45
                                                } else if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    3) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 25
                                                              : 25); //10-11kilo 25
                                                } else if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    4) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 25
                                                              : 25); //11-12kilo
                                                } else if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    5) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 25
                                                              : 0); //12-13kilo
                                                } else if (gjobsOnQueueModel
                                                            .initialKilo %
                                                        8 ==
                                                    6) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice -
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 10
                                                              : 0); //13-16kilo
                                                }

                                                gjobsOnQueueModel.initialKilo =
                                                    gjobsOnQueueModel
                                                            .initialKilo -
                                                        1;
                                              }
                                              setState(() {
                                                gjobsOnQueueModel.initialKilo;
                                                gjobsOnQueueModel.initialLoad;
                                                gjobsOnQueueModel.initialPrice;
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
                                              bottomRight:
                                                  Radius.circular(20))),
                                      child: Row(
                                        children: [
                                          Text("+1 kg"),
                                          IconButton(
                                            onPressed: () {
                                              if (gjobsOnQueueModel
                                                      .initialKilo >=
                                                  8) {
                                                gjobsOnQueueModel.initialKilo =
                                                    gjobsOnQueueModel
                                                            .initialKilo +
                                                        1;
                                              }

                                              if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 ==
                                                  1) {
                                                gjobsOnQueueModel.initialPrice =
                                                    gjobsOnQueueModel
                                                            .initialPrice +
                                                        (gjobsOnQueueModel
                                                                .regular
                                                            ? 25
                                                            : 25); //8-9kilo
                                              } else if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 ==
                                                  2) {
                                                gjobsOnQueueModel.initialPrice =
                                                    gjobsOnQueueModel
                                                            .initialPrice +
                                                        (gjobsOnQueueModel
                                                                .regular
                                                            ? 45
                                                            : 50); //9-10kilo
                                                setState(() => gjobsOnQueueModel
                                                        .initialLoad =
                                                    gjobsOnQueueModel
                                                            .initialLoad +
                                                        1);
                                              } else if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 ==
                                                  3) {
                                                gjobsOnQueueModel.initialPrice =
                                                    gjobsOnQueueModel
                                                            .initialPrice +
                                                        (gjobsOnQueueModel
                                                                .regular
                                                            ? 25
                                                            : 25); //10-11kilo
                                              } else if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 ==
                                                  4) {
                                                gjobsOnQueueModel.initialPrice =
                                                    gjobsOnQueueModel
                                                            .initialPrice +
                                                        (gjobsOnQueueModel
                                                                .regular
                                                            ? 25
                                                            : 25); //11-12kilo
                                              } else if (gjobsOnQueueModel
                                                          .initialKilo %
                                                      8 ==
                                                  5) {
                                                gjobsOnQueueModel.initialPrice =
                                                    gjobsOnQueueModel
                                                            .initialPrice +
                                                        (gjobsOnQueueModel
                                                                .regular
                                                            ? 25
                                                            : 0); //12-13kilo
                                              } else {
                                                if (gjobsOnQueueModel
                                                            .initialPrice %
                                                        (iPriceDivider(
                                                            gjobsOnQueueModel
                                                                .regular)) !=
                                                    0) {
                                                  gjobsOnQueueModel
                                                          .initialPrice =
                                                      gjobsOnQueueModel
                                                              .initialPrice +
                                                          (gjobsOnQueueModel
                                                                  .regular
                                                              ? 10
                                                              : 0); //13-16kilo
                                                }
                                              }

                                              setState(() {
                                                gjobsOnQueueModel.initialKilo;
                                                gjobsOnQueueModel.initialLoad;
                                                gjobsOnQueueModel.initialPrice;
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
                      Visibility(
                        visible: (bViewMoreOptions
                            ? true
                            : (gjobsOnQueueModel.others ? true : false)),
                        child: Container(
                          decoration: containerSayoSabonBoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Clear Add Ons",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        listAddOnItems.clear();
                                        gjobsOnQueueModel.initialOthersPrice =
                                            0;
                                        setState(
                                          () {
                                            gjobsOnQueueModel.others = false;
                                            bViewMoreOptions = false;
                                          },
                                        );

                                        //resetAddOn();
                                      },
                                      icon: Icon(Icons.delete_outline)),
                                  //checkboxes add on
                                  Visibility(
                                    visible: (bViewMoreOptions
                                        ? true
                                        : (gjobsOnQueueModel.others
                                            ? true
                                            : false)),
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
                                                  value: bDetAddOnVar,
                                                  onChanged: (val) {
                                                    resetAddOn();
                                                    setState(
                                                      () {
                                                        bDetAddOnVar = val!;
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
                                                  value: bFabAddOnVar,
                                                  onChanged: (val) {
                                                    resetAddOn();
                                                    setState(
                                                      () {
                                                        bFabAddOnVar = val!;
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
                                                  value: bBleAddOnVar,
                                                  onChanged: (val) {
                                                    resetAddOn();
                                                    setState(
                                                      () {
                                                        bBleAddOnVar = val!;
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
                                                  value: bOthAddOnVar,
                                                  onChanged: (val) {
                                                    resetAddOn();
                                                    setState(
                                                      () {
                                                        bOthAddOnVar = val!;
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
                                  // addOnDropDown(
                                  //     bDetAddOnVar, selectedDetVar, listDetItems),
                                  Visibility(
                                    visible: bDetAddOnVar,
                                    child: Container(
                                      padding: EdgeInsets.all(1.0),
                                      child: Row(
                                        children: [
                                          DropdownButton<OtherItemModel>(
                                            value: selectedDetVar,
                                            icon: Icon(Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.purple[700]),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.purple[700],
                                            ),
                                            items: listDetItems
                                                .map((OtherItemModel map) {
                                              return DropdownMenuItem<
                                                      OtherItemModel>(
                                                  value: map,
                                                  child: Text(
                                                      "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                                            }).toList(),
                                            onChanged: (newItemModel) {
                                              setState(
                                                () {
                                                  updateSelectedVar(
                                                      newItemModel!);
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  listAddOnItems
                                                      .add(selectedDetVar);
                                                  gjobsOnQueueModel
                                                          .initialOthersPrice =
                                                      gjobsOnQueueModel
                                                              .initialOthersPrice +
                                                          selectedDetVar
                                                              .itemPrice;
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.add_circle),
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //dropdown fab
                                  // addOnDropDown(
                                  //     bFabAddOnVar, selectedFabVar, listFabItems),
                                  Visibility(
                                    visible: bFabAddOnVar,
                                    child: Container(
                                      padding: EdgeInsets.all(1.0),
                                      child: Row(
                                        children: [
                                          DropdownButton<OtherItemModel>(
                                            value: selectedFabVar,
                                            icon: Icon(Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.purple[700]),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.purple[700],
                                            ),
                                            items: listFabItems
                                                .map((OtherItemModel map) {
                                              return DropdownMenuItem<
                                                      OtherItemModel>(
                                                  value: map,
                                                  child: Text(
                                                      "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                                            }).toList(),
                                            onChanged: (newItemModel) {
                                              setState(
                                                () {
                                                  updateSelectedVar(
                                                      newItemModel!);
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  listAddOnItems
                                                      .add(selectedFabVar);
                                                  gjobsOnQueueModel
                                                          .initialOthersPrice =
                                                      gjobsOnQueueModel
                                                              .initialOthersPrice +
                                                          selectedFabVar
                                                              .itemPrice;
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.add_circle),
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  //dropdown ble
                                  // addOnDropDown(
                                  //     bBleAddOnVar, selectedBleVar, listBleItems),
                                  Visibility(
                                    visible: bBleAddOnVar,
                                    child: Container(
                                      padding: EdgeInsets.all(1.0),
                                      child: Row(
                                        children: [
                                          DropdownButton<OtherItemModel>(
                                            value: selectedBleVar,
                                            icon: Icon(Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.purple[700]),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.purple[700],
                                            ),
                                            items: listBleItems
                                                .map((OtherItemModel map) {
                                              return DropdownMenuItem<
                                                      OtherItemModel>(
                                                  value: map,
                                                  child: Text(
                                                      "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                                            }).toList(),
                                            onChanged: (newItemModel) {
                                              setState(
                                                () {
                                                  updateSelectedVar(
                                                      newItemModel!);
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  listAddOnItems
                                                      .add(selectedBleVar);
                                                  gjobsOnQueueModel
                                                          .initialOthersPrice =
                                                      gjobsOnQueueModel
                                                              .initialOthersPrice +
                                                          selectedBleVar
                                                              .itemPrice;
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.add_circle),
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // dropdown oth
                                  // addOnDropDown(
                                  //     bOthAddOnVar, selectedOthVar, listOthItems),
                                  Visibility(
                                    visible: bOthAddOnVar,
                                    child: Container(
                                      padding: EdgeInsets.all(1.0),
                                      child: Row(
                                        children: [
                                          DropdownButton<OtherItemModel>(
                                            value: selectedOthVar,
                                            icon: Icon(Icons.arrow_downward),
                                            iconSize: 24,
                                            elevation: 16,
                                            style: TextStyle(
                                                color: Colors.purple[700]),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.purple[700],
                                            ),
                                            items: listOthItems
                                                .map((OtherItemModel map) {
                                              return DropdownMenuItem<
                                                      OtherItemModel>(
                                                  value: map,
                                                  child: Text(
                                                      "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                                            }).toList(),
                                            onChanged: (newItemModel) {
                                              setState(
                                                () {
                                                  updateSelectedVar(
                                                      newItemModel!);
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(
                                                () {
                                                  listAddOnItems
                                                      .add(selectedOthVar);
                                                  gjobsOnQueueModel
                                                          .initialOthersPrice =
                                                      gjobsOnQueueModel
                                                              .initialOthersPrice +
                                                          selectedOthVar
                                                              .itemPrice;
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.add_circle),
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _readAddedData(listAddOnItems),
                                  //_dtAddedOthers(addOnItems),
                                  //_addedOn(addOnItems),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Total Price
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: containerTotalPriceBoxDecoration(),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Price:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Php ${gjobsOnQueueModel.initialPrice + gjobsOnQueueModel.initialOthersPrice}.00",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                        decoration: containerQueBoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() => gjobsOnQueueModel.basket--);
                              },
                              icon: const Icon(Icons.remove_circle_outlined),
                              color: Colors.blueAccent,
                            ),
                            Text("Basket: ${gjobsOnQueueModel.basket}"),
                            IconButton(
                              onPressed: () {
                                setState(() => gjobsOnQueueModel.basket++);
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
                        decoration: containerQueBoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() => gjobsOnQueueModel.bag--);
                              },
                              icon: const Icon(Icons.remove_circle_outlined),
                              color: Colors.blueAccent,
                            ),
                            Text("Bag: ${gjobsOnQueueModel.bag}"),
                            IconButton(
                              onPressed: () {
                                setState(() => gjobsOnQueueModel.bag++);
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
                        decoration: containerQueBoxDecoration(),
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
                                    value: gjobsOnQueueModel.unpaid,
                                    onChanged: (val) {
                                      resetPaymentQueueBool(gjobsOnQueueModel);
                                      if (val!) {
                                        setState(
                                          () {
                                            gjobsOnQueueModel.unpaid = val;
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
                                    value: gjobsOnQueueModel.paidcash,
                                    onChanged: (val) {
                                      resetPaymentQueueBool(gjobsOnQueueModel);
                                      if (val!) {
                                        setState(
                                          () {
                                            gjobsOnQueueModel.paidcash = val;
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
                                    value: gjobsOnQueueModel.paidgcash,
                                    onChanged: (val) {
                                      resetPaymentQueueBool(gjobsOnQueueModel);
                                      if (val!) {
                                        setState(
                                          () {
                                            gjobsOnQueueModel.paidgcash = val;
                                          },
                                        );
                                      }
                                    })
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Remarks
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.all(1.0),
                        decoration: containerQueBoxDecoration(),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.words,
                          textAlign: TextAlign.start,
                          controller: remarksControllerVar,
                          decoration: InputDecoration(
                              labelText: 'Remarks', hintText: 'Notes'),
                          validator: (val) {},
                        ),
                      ),
                      //QueueStat
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(1.0),
                        decoration: containerSayoSabonBoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Hide"),
                            Switch.adaptive(
                              value: bViewMoreOptions,
                              onChanged: (bool value) {
                                setState(() {
                                  bViewMoreOptions = value;
                                });
                              },
                            ),
                            Text("More"),
                          ],
                        ),
                      ),
                      //No Fold
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: bViewMoreOptions,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(1.0),
                          decoration: containerSayoSabonBoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("No Fold"),
                              Switch.adaptive(
                                value: gjobsOnQueueModel.fold,
                                onChanged: (bool value) {
                                  setState(() {
                                    gjobsOnQueueModel.fold = value;
                                  });
                                },
                              ),
                              Text("Fold"),
                            ],
                          ),
                        ),
                      ),
                      //Dont mix
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: bViewMoreOptions,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(1.0),
                          decoration: containerSayoSabonBoxDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Dont Mix"),
                              Switch.adaptive(
                                value: gjobsOnQueueModel.mix,
                                onChanged: (bool value) {
                                  setState(() {
                                    gjobsOnQueueModel.mix = value;
                                  });
                                },
                              ),
                              Text("Mix"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //Need On Date +
                      Visibility(
                        visible: bViewMoreOptions,
                        child: Container(
                          padding: EdgeInsets.all(1.0),
                          decoration: containerSayoSabonBoxDecoration(),
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
                                        setState(() => dNeedOnVar =
                                            dNeedOnVar.add(Duration(days: -1)));
                                      },
                                      icon: const Icon(
                                          Icons.remove_circle_outlined),
                                      color: Colors.blueAccent,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => dNeedOnVar =
                                            dNeedOnVar.add(Duration(days: 1)));
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
                                      "Need On: ${dNeedOnVar.toString().substring(5, 14)}00",
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
                                        setState(() => dNeedOnVar = dNeedOnVar
                                            .add(Duration(hours: -1)));
                                      },
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      color: Colors.blueAccent,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => dNeedOnVar =
                                            dNeedOnVar.add(Duration(hours: 1)));
                                      },
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      color: Colors.blueAccent,
                                    ),
                                    Text("+1 hr"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              //cancel button
              _cancelButton(),

              //save button
              //_createNewRecord(),

              //save button new
              _createNewRecordJson(),
            ],
          );
        });
      },
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

  //new createNewRecord
  Widget _createNewRecordJson() {
    return MaterialButton(
      onPressed: () {
        if (autocompleteSelected.customerId == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cannot save, please add name in loyalty records first.')),
          );
          // } else if (_formKey.currentState!.validate()) {
        } else if (true) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);
          gjobsOnQueueModel.dateQ = Timestamp.now();
          gjobsOnQueueModel.customerId = autocompleteSelected.customerId;
          //gjobsOnQueueModel.initialOthersPrice = gjobsOnQueueModel.initialOthersPrice;
          gjobsOnQueueModel.finalKilo = 0;
          gjobsOnQueueModel.finalLoad = 0;
          gjobsOnQueueModel.finalPrice = 0;
          gjobsOnQueueModel.finalOthersPrice = 0;
          /*()
          gjobsOnQueueModel.queueStat = (bRiderPickupVar
              ? mapQueueStat[riderPickup].toString()
              : mapQueueStat[forSorting].toString());
              
          gjobsOnQueueModel.paymentStat = (bUnpaidVar
              ? mapPaymentStat[unpaid].toString()
              : (bPaidCashVar
                  ? mapPaymentStat[paidCash].toString()
                  : (bPaidGCashVar
                      ? mapPaymentStat[paidGCash].toString()
                      : mapPaymentStat[waitGCash].toString())));
                      */
          gjobsOnQueueModel.paymentReceivedBy =
              (gjobsOnQueueModel.unpaid ? "" : _sEmpId);
          gjobsOnQueueModel.paidD = (gjobsOnQueueModel.unpaid
              ? Timestamp.fromDate(DateTime(2000))
              : Timestamp.now());
          gjobsOnQueueModel.remarks = remarksControllerVar.text;

          insertDataJobsOnQueueJson(gjobsOnQueueModel);

          // insertDataJobsOnQueueJson(JobsOnQueueModel(
          //     dateQ: Timestamp.now(),
          //     createdBy: _sEmpId,
          //     customerId: autocompleteSelected.customerId,
          //     initialKilo: iInitialKiloVar,
          //     initialLoad: iInitialLoadVar,
          //     initialPrice: iInitialPriceVar,
          //     initialOthersPrice: iInitialOthersPriceVar,
          //     finalKilo: 0,
          //     finalLoad: 0,
          //     finalPrice: 0,
          //     finalOthersPrice: 0,
          //     queueStat: (bRiderPickupVar
          //         ? mapQueueStat[riderPickup].toString()
          //         : mapQueueStat[forSorting].toString()),
          //     paymentStat: (bUnpaidVar
          //         ? mapPaymentStat[unpaid].toString()
          //         : (bPaidCashVar
          //             ? mapPaymentStat[paidCash].toString()
          //             : (bPaidGCashVar
          //                 ? mapPaymentStat[paidGCash].toString()
          //                 : mapPaymentStat[waitGCash].toString()))),
          //     paymentReceivedBy: (bUnpaidVar ? "" : _sEmpId),
          //     paidD: (bUnpaidVar
          //         ? Timestamp.fromDate(DateTime(2000))
          //         : Timestamp.now()),
          //     needOn: tNeedOnVar,
          //     fold: bFoldVar,
          //     mix: bMixVar,
          //     basket: iBasketVar,
          //     bag: iBagVar,
          //     remarks: remarksControllerVar.text));
        }
      },
      color: cButtons,
      child: const Text("Save"),
    );
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

  void messageResultNew(String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    listAddOnItems.clear();
                    gjobsOnQueueModel.initialOthersPrice = 0;
                    resetAddOn();
                    //showJobsOnQueueEntryJson();
                  },
                  color: cButtons,
                  child: const Text("Ok"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    gjobsOnQueueModel.addOns = true;
                    //showJobsOnQueueEntryJson();
                  },
                  color: cButtons,
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  //insert new
  void insertDataJobsOnQueueJson(JobsOnQueueModel jobsOnQueueModel) {
    DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();

    databaseJobsOnQueue.addJobsOnQueue(jobsOnQueueModel, listAddOnItems);

    gjobsOnQueueModel.initialKilo = 8;
    gjobsOnQueueModel.initialLoad = 1;
    gjobsOnQueueModel.initialPrice = 155;
    gjobsOnQueueModel.initialOthersPrice = 0;
    gjobsOnQueueModel.riderPickup = false;
    gjobsOnQueueModel.unpaid = true;
    gjobsOnQueueModel.paidcash = false;
    gjobsOnQueueModel.paidgcash = false;
    dNeedOnVar = DateTime.now();
    gjobsOnQueueModel.fold = true;
    gjobsOnQueueModel.mix = true;
    gjobsOnQueueModel.basket = 0;
    gjobsOnQueueModel.bag = 0;
    remarksControllerVar.clear();

    //databaseJobsOnQueue.addJobsOnQueueSolo(jobsOnQueueModel);
  }

  getThemeDropDown() {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints.tight(const Size.fromHeight(20)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Visibility addOnDropDown(bool bDisplay, OtherItemModel selectedItemModel,
      List<OtherItemModel> thisListItemModel) {
    // print('size=' +
    //     thisListItemModel.length.toString() +
    //     thisListItemModel[0].itemName);
    return Visibility(
      visible: bDisplay,
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Row(
          children: [
            DropdownButton<OtherItemModel>(
              value: selectedItemModel,
              //value: selectedDetVar,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.purple[700]),
              underline: Container(
                height: 2,
                color: Colors.purple[700],
              ),
              items: thisListItemModel.map((OtherItemModel map) {
                return DropdownMenuItem<OtherItemModel>(
                    value: map,
                    child: Text(
                        "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
              }).toList(),
              onChanged: (newItemModel) {
                setState(
                  () {
                    selectedItemModel = newItemModel!;
                    updateSelectedVar(selectedItemModel);
                  },
                );
                // Navigator.pop(context);
                // showJobsOnQueueEntryJson();
                // print("watata" +
                //     selectedItemModel.itemName +
                //     selectedDetVar.itemName);
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                //listAddOnItems.add(selectedDetVar);
                listAddOnItems.add(selectedItemModel);
                gjobsOnQueueModel.initialOthersPrice =
                    gjobsOnQueueModel.initialOthersPrice +
                        // selectedDetVar.itemPrice;
                        selectedItemModel.itemPrice;
                showJobsOnQueueEntryJson();
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  void updateSelectedVar(OtherItemModel selectedItemModel) {
    if (listDetItems.contains(selectedItemModel)) {
      selectedDetVar = selectedItemModel;
    } else if (listFabItems.contains(selectedItemModel)) {
      selectedFabVar = selectedItemModel;
    } else if (listBleItems.contains(selectedItemModel)) {
      selectedBleVar = selectedItemModel;
    } else if (listOthItems.contains(selectedItemModel)) {
      selectedOthVar = selectedItemModel;
    }
  }

  Widget _readAddedData(List<OtherItemModel> listAddedOthers) {
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

  void _allCards(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoyaltyAdmin()));
  }

*/
}
