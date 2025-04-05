import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
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
  late bool bViewMoreOptionsQ = false;
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
              showNewJobsForQueue();
            },
            child: const Icon(Icons.local_laundry_service_sharp),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            heroTag: "Supplies",
            onPressed: () {
              showSuppliesHist();
            },
            child: const Icon(Icons.g_mobiledata),
          ),
        ],
      ),
    );
  }

  void showNewJobsForQueue() {
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
                      conQueueStatQ(context, setState),
                      conOrderModeQ(context, setState),
                      conTotalPriceQ(setState),
                      conBasketQ(setState),
                      conBagQ(setState),
                      conPaymentQ(setState),
                      conRemarksQ(setState),
                      conMoreOptionsQ(setState),
                      visAddOnQ(context, setState),
                      visExtraQ(context, setState),
                      visFoldQ(setState),
                      visMixQ(setState),
                      visNeedOn(setState),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              //cancel button
              cancelButtonQ(context, setState),

              //save button
              createNewJOQVar(context),
            ],
          );
        });
      },
    );
  }

  Container conQueueStatQ(BuildContext context, Function setState) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Sort"),
          Switch.adaptive(
            value: jobsOnQueueModelGlobal.riderPickup,
            onChanged: (bool value) {
              setState(() {
                jobsOnQueueModelGlobal.riderPickup = value;
                if (jobsOnQueueModelGlobal.riderPickup) {
                  jobsOnQueueModelGlobal.forSorting = false;
                } else {
                  jobsOnQueueModelGlobal.forSorting = true;
                }
              });
            },
          ),
          Text("RiderPickup"),
        ],
      ),
    );
  }

  Container conOrderModeQ(BuildContext context, Function setState) {
    return Container(
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
                      value: jobsOnQueueModelGlobal.regular,
                      onChanged: (val) {
                        jobsOnQueueModelGlobal =
                            resetRegular(jobsOnQueueModelGlobal);

                        if (val!) {
                          setState(
                            () {
                              jobsOnQueueModelGlobal.regular = val;
                            },
                          );
                        }

                        jobsOnQueueModelGlobal.initialKilo = 8;
                        jobsOnQueueModelGlobal.initialPrice =
                            (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                iPriceDivider(jobsOnQueueModelGlobal.regular);
                        jobsOnQueueModelGlobal.initialLoad =
                            (jobsOnQueueModelGlobal.initialKilo ~/ 8);
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
                      value: jobsOnQueueModelGlobal.sayosabon,
                      onChanged: (val) {
                        jobsOnQueueModelGlobal =
                            resetRegular(jobsOnQueueModelGlobal);

                        if (val!) {
                          setState(
                            () {
                              jobsOnQueueModelGlobal.sayosabon = val;
                            },
                          );
                        }

                        jobsOnQueueModelGlobal.initialKilo = 8;
                        jobsOnQueueModelGlobal.initialPrice =
                            (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                iPriceDivider(jobsOnQueueModelGlobal.regular);
                        jobsOnQueueModelGlobal.initialLoad =
                            (jobsOnQueueModelGlobal.initialKilo ~/ 8);
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
                      value: jobsOnQueueModelGlobal.others,
                      onChanged: (val) {
                        jobsOnQueueModelGlobal =
                            resetRegular(jobsOnQueueModelGlobal);
                        bShowKiloLoadDisplayVar = false;

                        if (val!) {
                          setState(
                            () {
                              jobsOnQueueModelGlobal.others = val;
                            },
                          );
                        }

                        jobsOnQueueModelGlobal.initialKilo = 0;
                        jobsOnQueueModelGlobal.initialPrice = 0;
                        jobsOnQueueModelGlobal.initialLoad = 0;
                      })
                ],
              ),
            ],
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
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Weight:"),
                        Text(
                            "${kiloDisplay(jobsOnQueueModelGlobal.initialKilo)} kilo"),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Load:"),
                        Text("${jobsOnQueueModelGlobal.initialLoad}"),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Load Price:"),
                        Text(
                            "${autoPriceDisplay(jobsOnQueueModelGlobal.initialPrice, jobsOnQueueModelGlobal.regular)}.00"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    padding:
                        EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
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
                            if (jobsOnQueueModelGlobal.initialKilo < 8) {
                              jobsOnQueueModelGlobal.initialKilo = 8;
                              jobsOnQueueModelGlobal.initialPrice =
                                  (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                      iPriceDivider(
                                          jobsOnQueueModelGlobal.regular);
                              jobsOnQueueModelGlobal.initialLoad =
                                  (jobsOnQueueModelGlobal.initialKilo ~/ 8);
                            } else {
                              if (jobsOnQueueModelGlobal.initialKilo % 8 != 0) {
                                jobsOnQueueModelGlobal.initialKilo =
                                    jobsOnQueueModelGlobal.initialKilo -
                                        (jobsOnQueueModelGlobal.initialKilo %
                                            8);
                              } else {
                                jobsOnQueueModelGlobal.initialKilo =
                                    jobsOnQueueModelGlobal.initialKilo - 8;
                              }

                              jobsOnQueueModelGlobal.initialPrice =
                                  (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                      iPriceDivider(
                                          jobsOnQueueModelGlobal.regular);

                              jobsOnQueueModelGlobal.initialLoad =
                                  (jobsOnQueueModelGlobal.initialKilo ~/ 8);
                            }
                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo;
                              jobsOnQueueModelGlobal.initialLoad;
                              jobsOnQueueModelGlobal.initialPrice;
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outlined),
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
                    padding:
                        EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
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
                            if (jobsOnQueueModelGlobal.initialKilo % 8 != 0) {
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo +
                                      8 -
                                      (jobsOnQueueModelGlobal.initialKilo % 8);
                            } else {
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo + 8;
                            }

                            jobsOnQueueModelGlobal.initialPrice =
                                (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                    (iPriceDivider(
                                        jobsOnQueueModelGlobal.regular));
                            jobsOnQueueModelGlobal.initialLoad =
                                jobsOnQueueModelGlobal.initialKilo ~/ 8;
                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo;
                              jobsOnQueueModelGlobal.initialLoad;
                              jobsOnQueueModelGlobal.initialPrice;
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
          SizedBox(
            height: 5,
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
                    padding:
                        EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
                    decoration: BoxDecoration(
                        color: Colors.amber[200],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (jobsOnQueueModelGlobal.initialKilo > 8) {
                              if (jobsOnQueueModelGlobal.initialKilo % 8 == 1) {
                                jobsOnQueueModelGlobal.initialPrice =
                                    jobsOnQueueModelGlobal.initialPrice -
                                        (jobsOnQueueModelGlobal.regular
                                            ? 25
                                            : 25); //8-9kilo 25

                                //should be after kilo - 1;
                                // jobsOnQueueModelGlobal.initialLoad =
                                //     jobsOnQueueModelGlobal.initialLoad - 1;
                              } else if (jobsOnQueueModelGlobal.initialKilo %
                                      8 ==
                                  2) {
                                jobsOnQueueModelGlobal.initialPrice =
                                    jobsOnQueueModelGlobal.initialPrice -
                                        (jobsOnQueueModelGlobal.regular
                                            ? 45
                                            : 50); //9-10kilo 45
                              } else if (jobsOnQueueModelGlobal.initialKilo %
                                      8 ==
                                  3) {
                                jobsOnQueueModelGlobal.initialPrice =
                                    jobsOnQueueModelGlobal.initialPrice -
                                        (jobsOnQueueModelGlobal.regular
                                            ? 25
                                            : 25); //10-11kilo 25
                              } else if (jobsOnQueueModelGlobal.initialKilo %
                                      8 ==
                                  4) {
                                jobsOnQueueModelGlobal.initialPrice =
                                    jobsOnQueueModelGlobal.initialPrice -
                                        (jobsOnQueueModelGlobal.regular
                                            ? 25
                                            : 25); //11-12kilo
                              } else if (jobsOnQueueModelGlobal.initialKilo %
                                      8 ==
                                  5) {
                                jobsOnQueueModelGlobal.initialPrice =
                                    jobsOnQueueModelGlobal.initialPrice -
                                        (jobsOnQueueModelGlobal.regular
                                            ? 35
                                            : 0); //12-13kilo
                              }
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo - 1;

                              if (jobsOnQueueModelGlobal.initialKilo % 8 == 1) {
                                //8-9kilo 25

                                jobsOnQueueModelGlobal.initialLoad =
                                    jobsOnQueueModelGlobal.initialLoad - 1;
                              }
                            }
                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo;
                              jobsOnQueueModelGlobal.initialLoad;
                              jobsOnQueueModelGlobal.initialPrice;
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outlined),
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
                    padding:
                        EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
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
                            if (jobsOnQueueModelGlobal.initialKilo >= 8) {
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo + 1;
                            }

                            if (jobsOnQueueModelGlobal.initialKilo % 8 == 1) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //8-9kilo
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                2) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 45
                                          : 50); //9-10kilo
                              jobsOnQueueModelGlobal.initialLoad =
                                  jobsOnQueueModelGlobal.initialLoad + 1;
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                3) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //10-11kilo
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                4) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //11-12kilo
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                5) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 35
                                          : 0); //12-13kilo
                            }

                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo;
                              jobsOnQueueModelGlobal.initialLoad;
                              jobsOnQueueModelGlobal.initialPrice;
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
    );
  }

  Visibility visExtraQ(BuildContext context, Function setState) {
    return Visibility(
      visible: bViewMoreOptionsQ,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Add WKL Fab"),
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        listAddOnItemsGlobal.add(OtherItemModel(
                            docId: "",
                            itemId: menuFabWKL24mlDVal,
                            itemGroup: groupFab,
                            itemName: "WKL Fabcon 24ml",
                            itemPrice: 8));

                        bViewMoreOptionsQ = true;

                        jobsOnQueueModelGlobal.initialOthersPrice =
                            jobsOnQueueModelGlobal.initialOthersPrice + 8;

                        showMessage(
                            context, "Extras", "WKL Fabcon 24ml (8php).");
                      },
                    );
                  },
                  icon: const Icon(Icons.flare_outlined),
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("Extra Dry"),
                IconButton(
                  onPressed: () {
                    listAddOnItemsGlobal.add(OtherItemModel(
                        docId: "",
                        itemId: menuOthXD,
                        itemGroup: groupOth,
                        itemName: "Extra Dry",
                        itemPrice: 15));

                    setState(
                      () {
                        bViewMoreOptionsQ = true;

                        jobsOnQueueModelGlobal.initialOthersPrice =
                            jobsOnQueueModelGlobal.initialOthersPrice + 15;

                        showMessage(context, "Extras", "Extra Dry added.");
                      },
                    );
                  },
                  icon: const Icon(Icons.dry_cleaning_outlined),
                  color: Colors.blueAccent,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Extra Wash"),
                IconButton(
                  onPressed: () {
                    listAddOnItemsGlobal.add(OtherItemModel(
                        docId: "",
                        itemId: menuOthXW,
                        itemGroup: groupOth,
                        itemName: "Extra Wash",
                        itemPrice: 15));
                    setState(
                      () {
                        bViewMoreOptionsQ = true;

                        jobsOnQueueModelGlobal.initialOthersPrice =
                            jobsOnQueueModelGlobal.initialOthersPrice + 15;

                        showMessage(context, "Extras", "Extra Wash added.");
                      },
                    );
                  },
                  icon: const Icon(Icons.water_drop_outlined),
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("Extra Rinse"),
                IconButton(
                  onPressed: () {
                    listAddOnItemsGlobal.add(OtherItemModel(
                        docId: "",
                        itemId: menuOthXR,
                        itemGroup: groupOth,
                        itemName: "Extra Rinse",
                        itemPrice: 15));

                    setState(
                      () {
                        bViewMoreOptionsQ = true;

                        jobsOnQueueModelGlobal.initialOthersPrice =
                            jobsOnQueueModelGlobal.initialOthersPrice + 15;

                        showMessage(context, "Extras", "Extra Rinse added.");
                      },
                    );
                  },
                  icon: const Icon(Icons.webhook_outlined),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAddOnQ(BuildContext context, Function setState) {
    return Visibility(
      visible: (bViewMoreOptionsQ
          ? true
          : (jobsOnQueueModelGlobal.others ? true : false)),
      child: Container(
        decoration: decoLightBlue(),
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
                      showMessageDelAddOnsQ(context, setState, "Delete Add On",
                          "Are you sure you want to clear add on?");
                    },
                    icon: Icon(Icons.delete_outline)),
                //checkboxes add on
                Visibility(
                  visible: (bViewMoreOptionsQ
                      ? true
                      : (jobsOnQueueModelGlobal.others ? true : false)),
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
                                  resetAddOnVar();
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
                                  resetAddOnVar();
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
                                  resetAddOnVar();
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
                                  resetAddOnVar();
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
                          style: TextStyle(color: Colors.purple[700]),
                          underline: Container(
                            height: 2,
                            color: Colors.purple[700],
                          ),
                          items: listDetItems.map((OtherItemModel map) {
                            return DropdownMenuItem<OtherItemModel>(
                                value: map,
                                child: Text(
                                    "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                          }).toList(),
                          onChanged: (newItemModel) {
                            setState(
                              () {
                                updateSelectedVar(newItemModel!);
                              },
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(
                              () {
                                listAddOnItemsGlobal.add(selectedDetVar);
                                jobsOnQueueModelGlobal.initialOthersPrice =
                                    jobsOnQueueModelGlobal.initialOthersPrice +
                                        selectedDetVar.itemPrice;
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
                          style: TextStyle(color: Colors.purple[700]),
                          underline: Container(
                            height: 2,
                            color: Colors.purple[700],
                          ),
                          items: listFabItems.map((OtherItemModel map) {
                            return DropdownMenuItem<OtherItemModel>(
                                value: map,
                                child: Text(
                                    "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                          }).toList(),
                          onChanged: (newItemModel) {
                            setState(
                              () {
                                updateSelectedVar(newItemModel!);
                              },
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(
                              () {
                                listAddOnItemsGlobal.add(selectedFabVar);
                                jobsOnQueueModelGlobal.initialOthersPrice =
                                    jobsOnQueueModelGlobal.initialOthersPrice +
                                        selectedFabVar.itemPrice;
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
                          style: TextStyle(color: Colors.purple[700]),
                          underline: Container(
                            height: 2,
                            color: Colors.purple[700],
                          ),
                          items: listBleItems.map((OtherItemModel map) {
                            return DropdownMenuItem<OtherItemModel>(
                                value: map,
                                child: Text(
                                    "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                          }).toList(),
                          onChanged: (newItemModel) {
                            setState(
                              () {
                                updateSelectedVar(newItemModel!);
                              },
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(
                              () {
                                listAddOnItemsGlobal.add(selectedBleVar);
                                jobsOnQueueModelGlobal.initialOthersPrice =
                                    jobsOnQueueModelGlobal.initialOthersPrice +
                                        selectedBleVar.itemPrice;
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
                          style: TextStyle(color: Colors.purple[700]),
                          underline: Container(
                            height: 2,
                            color: Colors.purple[700],
                          ),
                          items: listOthItems.map((OtherItemModel map) {
                            return DropdownMenuItem<OtherItemModel>(
                                value: map,
                                child: Text(
                                    "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                          }).toList(),
                          onChanged: (newItemModel) {
                            setState(
                              () {
                                updateSelectedVar(newItemModel!);
                              },
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            setState(
                              () {
                                listAddOnItemsGlobal.add(selectedOthVar);
                                jobsOnQueueModelGlobal.initialOthersPrice =
                                    jobsOnQueueModelGlobal.initialOthersPrice +
                                        selectedOthVar.itemPrice;
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
                readAddedDataVar(listAddOnItemsGlobal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container conTotalPriceQ(Function setState) {
    return Container(
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
            "Php ${jobsOnQueueModelGlobal.initialPrice + jobsOnQueueModelGlobal.initialOthersPrice}.00",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Container conBasketQ(Function setState) {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() => jobsOnQueueModelGlobal.basket--);
            },
            icon: const Icon(Icons.remove_circle_outlined),
            color: Colors.blueAccent,
          ),
          Text("Basket: ${jobsOnQueueModelGlobal.basket}"),
          IconButton(
            onPressed: () {
              setState(() => jobsOnQueueModelGlobal.basket++);
            },
            icon: const Icon(Icons.add_circle),
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Container conBagQ(Function setState) {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() => jobsOnQueueModelGlobal.bag--);
            },
            icon: const Icon(Icons.remove_circle_outlined),
            color: Colors.blueAccent,
          ),
          Text("Bag: ${jobsOnQueueModelGlobal.bag}"),
          IconButton(
            onPressed: () {
              setState(() => jobsOnQueueModelGlobal.bag++);
            },
            icon: const Icon(Icons.add_circle),
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Container conPaymentQ(Function setState) {
    return Container(
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
                  value: jobsOnQueueModelGlobal.unpaid,
                  onChanged: (val) {
                    resetPaymentQueueBool(jobsOnQueueModelGlobal);
                    if (val!) {
                      setState(
                        () {
                          jobsOnQueueModelGlobal.unpaid = val;
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
                  value: jobsOnQueueModelGlobal.paidcash,
                  onChanged: (val) {
                    resetPaymentQueueBool(jobsOnQueueModelGlobal);
                    if (val!) {
                      setState(
                        () {
                          jobsOnQueueModelGlobal.paidcash = val;
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
                  value: jobsOnQueueModelGlobal.paidgcash,
                  onChanged: (val) {
                    resetPaymentQueueBool(jobsOnQueueModelGlobal);
                    if (val!) {
                      setState(
                        () {
                          jobsOnQueueModelGlobal.paidgcash = val;
                        },
                      );
                    }
                  })
            ],
          ),
        ],
      ),
    );
  }

  Container conRemarksQ(Function setState) {
    remarksControllerVar.text = jobsOnQueueModelGlobal.remarks;
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.start,
        controller: remarksControllerVar,
        decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
        validator: (val) {},
      ),
    );
  }

  Container conCounterQ(Function setState) {
    counterControllerVar.text = "";
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.start,
        controller: counterControllerVar,
        decoration: InputDecoration(labelText: 'Counter', hintText: 'Counter'),
        validator: (val) {},
      ),
    );
  }

  Container conMoreOptionsQ(Function setState) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hide"),
          Switch.adaptive(
            value: bViewMoreOptionsQ,
            onChanged: (bool value) {
              setState(() {
                bViewMoreOptionsQ = value;
              });
            },
          ),
          Text("More"),
        ],
      ),
    );
  }

  Visibility visFoldQ(Function setState) {
    return Visibility(
      visible: bViewMoreOptionsQ,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Fold"),
            Switch.adaptive(
              value: jobsOnQueueModelGlobal.fold,
              onChanged: (bool value) {
                setState(() {
                  jobsOnQueueModelGlobal.fold = value;
                });
              },
            ),
            Text("Fold"),
          ],
        ),
      ),
    );
  }

  Visibility visMixQ(Function setState) {
    return Visibility(
      visible: bViewMoreOptionsQ,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dont Mix"),
            Switch.adaptive(
              value: jobsOnQueueModelGlobal.mix,
              onChanged: (bool value) {
                setState(() {
                  jobsOnQueueModelGlobal.mix = value;
                });
              },
            ),
            Text("Mix"),
          ],
        ),
      ),
    );
  }

  Widget cancelButtonQ(BuildContext context, Function setState) {
    return MaterialButton(
        onPressed: () {
          resetJOQMGlobalVar();
          listAddOnItemsGlobal.clear();
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Cancel"));
  }

  void showMessageDelAddOnsQ(
      BuildContext contextx, Function setStatex, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              title,
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
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              closeAddOnsQ(context, setState),
              deleteButtonAddOnQ(contextx, setStatex),
            ],
          );
        });
      },
    );
  }

  Widget closeAddOnsQ(
    BuildContext context,
    Function setState,
  ) {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Cancel"));
  }

  Widget deleteButtonAddOnQ(
    BuildContext context,
    Function setState,
  ) {
    return MaterialButton(
      onPressed: () {
        listAddOnItemsGlobal.forEach((aOIG) {
          jobsOnQueueModelGlobal.initialOthersPrice =
              jobsOnQueueModelGlobal.initialOthersPrice - aOIG.itemPrice;
        });
        listAddOnItemsGlobal.clear();
        jobsOnQueueModelGlobal.initialOthersPrice = 0;

        setState(
          () {
            jobsOnQueueModelGlobal.others = false;
            bViewMoreOptionsQ = false;
          },
        );
        Navigator.pop(context);
      },
      color: cButtons,
      child: const Text("Delete"),
    );
  }

  void showSuppliesHist() {
    SuppliesModelHist sMH;
    sMH = suppliesModelHistGlobal;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Supplies ${DateTime.now().toString().substring(5, 13)}",
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
                      visAddOnSupplies(context, setState, sMH),
                      conCounterQ(setState),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              //cancel button
              cancelButtonQ(context, setState),

              createNewSuppVar(context, sMH),

              //save button
              //createNewJOQVar(context),
            ],
          );
        });
      },
    );
  }

  Visibility visAddOnSupplies(
      BuildContext context, Function setState, SuppliesModelHist sMH) {
    return Visibility(
      visible: true,
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Row(
          children: [
            DropdownButton<OtherItemModel>(
              value: selectedSupVar,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.purple[700]),
              underline: Container(
                height: 2,
                color: Colors.purple[700],
              ),
              items: listSuppItems.map((OtherItemModel map) {
                return DropdownMenuItem<OtherItemModel>(
                    value: map,
                    child: Text(
                        "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
              }).toList(),
              onChanged: (val) {
                setState(
                  () {
                    selectedSupVar = val!;
                  },
                );

                sMH.docId = selectedSupVar.docId;
                sMH.itemId = selectedSupVar.itemId;

                // suppliesModelHistGlobal = SuppliesModelHist(
                //     docId: selectedSupVar.docId,
                //     itemId: selectedSupVar.itemId,
                //     counter: int.parse(counterControllerVar.text),
                //     currentStocks: 50,
                //     logDate: Timestamp.now());
              },
            ),
          ],
        ),
      ),
    );
  }
}
