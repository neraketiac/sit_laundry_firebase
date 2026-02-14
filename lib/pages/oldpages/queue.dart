import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/oldpages/queue_mobile.dart';
import 'package:laundry_firebase/variables/oldvariables/vairables_jobsonqueue.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_det.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_ble.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

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
              remarksControllerVar.text =
                  ""; //fix when click with remarks then new, fix to remove remarks
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
    // setState(
    //   () {
    //     resetJOQMGlobalVar();
    //     resetAddOnsGlobalVar();
    //     bViewMoreOptionsQ = false;
    //   },
    // );

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
                      visITFDWDQ(setState),
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
          Text("RiderPickup"),
          Switch.adaptive(
            // value: jobsOnQueueModelGlobal.riderPickup,
            // onChanged: (bool value) {
            //   setState(() {
            //     jobsOnQueueModelGlobal.riderPickup = value;
            //     if (jobsOnQueueModelGlobal.riderPickup) {
            //       jobsOnQueueModelGlobal.forSorting = false;
            //     } else {
            //       jobsOnQueueModelGlobal.forSorting = true;
            //     }
            //   });
            value: jobsOnQueueModelGlobal.forSorting,
            onChanged: (bool value) {
              setState(() {
                jobsOnQueueModelGlobal.forSorting = value;
                if (jobsOnQueueModelGlobal.forSorting) {
                } else {
                  jobsOnQueueModelGlobal.riderPickup = true;
                }
              });
            },
          ),
          Text("Sort"),
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
                        bShowKiloDisplayOthVar = false;
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
                        bShowKiloDisplayOthVar = false;
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
                        bShowKiloDisplayOthVar = true;

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
            //visible: bShowKiloLoadDisplayVar,
            visible: true,
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
          Visibility(
            visible: bShowKiloDisplayOthVar,
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
                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo--;
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
                            setState(() {
                              jobsOnQueueModelGlobal.initialKilo++;
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
          Visibility(
            visible: bShowKiloDisplayOthVar,
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
                            setState(() {
                              jobsOnQueueModelGlobal.initialLoad--;
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outlined),
                          color: Colors.blueAccent,
                        ),
                        Text("-1 ld"),
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
                        Text("+1 ld"),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              jobsOnQueueModelGlobal.initialLoad++;
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
                          itemId: menuFabWKLDValPurpleDVal,
                          itemUniqueId: menuFabWKLDValPurple48mlDVal,
                          itemGroup: groupFab,
                          itemName: "WKL Fabcon 24ml",
                          itemPrice: 8,
                          stocksAlert: 5,
                          stocksType: "pcs",
                        ));

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
                      itemUniqueId: menuOthXD,
                      itemGroup: groupOth,
                      itemName: "Extra Dry",
                      itemPrice: 15,
                      stocksAlert: 5,
                      stocksType: "pcs",
                    ));

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
                      itemUniqueId: menuOthXW,
                      itemGroup: groupOth,
                      itemName: "Extra Wash",
                      itemPrice: 15,
                      stocksAlert: 5,
                      stocksType: "pcs",
                    ));
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
                      itemUniqueId: menuOthXR,
                      itemGroup: groupOth,
                      itemName: "Extra Rinse",
                      itemPrice: 15,
                      stocksAlert: 5,
                      stocksType: "pcs",
                    ));

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
    //remarksControllerVar.text = jobsOnQueueModelGlobal.remarks;
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.start,
        controller: remarksControllerVar,
        decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
        validator: (val) {
          remarksControllerVar.text = val!;
        },
      ),
    );
  }

  Container conCounterQ(
      BuildContext context, Function setState, SuppliesModelHist sMH) {
    counterControllerVar.text = "0";
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TextFormField(
          //   inputFormatters: <TextInputFormatter>[
          //     FilteringTextInputFormatter.allow(RegExp(getRegexStringVar())),
          //     TextInputFormatter.withFunction(
          //       (oldValue, newValue) => newValue.copyWith(
          //         text: newValue.text.replaceAll('.', ','),
          //       ),
          //     ),
          //   ],
          //   keyboardType:
          //       TextInputType.numberWithOptions(signed: true, decimal: false),
          //   textCapitalization: TextCapitalization.words,
          //   textAlign: TextAlign.start,
          //   controller: counterControllerVar,
          //   decoration:
          //       InputDecoration(labelText: 'Counters', hintText: 'Counter'),
          //   validator: (val) {},
          // ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Final: ", style: TextStyle(fontSize: 10)),
              Text(
                  '${value.format(sMH.currentCounter)} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)}',
                  style: TextStyle(
                      backgroundColor: (sMH.currentCounter < 0
                          ? Color.fromARGB(125, 244, 67, 54)
                          : const Color.fromARGB(0, 255, 193, 7)),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),

          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: bGcashFee,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sample:",
                  style: TextStyle(fontSize: 8),
                ),
                Text(
                  "${value.format(iAmountDisplay)} ",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text("Fee ", style: TextStyle(fontSize: 8)),
                Text(
                  value.format(getFee(iAmountFinal)),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Visibility(
            visible: bGcashFee,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Nagbigay ng fee?",
                  style: TextStyle(fontSize: 9),
                ),
                Checkbox(
                    value: bNagbigayFee,
                    onChanged: ((val) {
                      bNagbigayFee = val!;
                      if (bNagbigayFee) {
                        iAmountDisplay = iAmountFinal;
                      } else {
                        iAmountDisplay = iAmountFinal - getFee(iAmountFinal);
                      }

                      setState(() {
                        bNagbigayFee;
                        iAmountDisplay;
                      });
                    })),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              conClipRRectAdd(setState, sMH, 1),
              conClipRRectAdd(setState, sMH, 2),
              conClipRRectAdd(setState, sMH, 3),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              conClipRRectAdd(setState, sMH, 4),
              conClipRRectAdd(setState, sMH, 5),
              conClipRRectAdd(setState, sMH, 6),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              conClipRRectAdd(setState, sMH, 7),
              conClipRRectAdd(setState, sMH, 8),
              conClipRRectAdd(setState, sMH, 9),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              conClipRRectNegative(setState, sMH, "-"),
              conClipRRectAdd(setState, sMH, 0),
              conClipRRectBlank(setState, sMH, "B"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              conClipRRectZero(setState, sMH),
              conClipRRectBlank(setState, sMH, "B"),
              conClipRRectSave(context, setState, sMH, "save"),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  ClipRRect conClipRRectSave(BuildContext context, Function setState,
      SuppliesModelHist sMH, String s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Color.fromARGB(132, 151, 26, 26),
                Color.fromARGB(120, 233, 66, 54),
              ])),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(2),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () async {
                sMH.customerId = autocompleteSelected.customerId;

                if (sMH.customerId == 1 || !bCustomerName) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Select Customer Name')),
                  );
                } else {
                  if ((ifMenuUniqueIsCashIn(sMH) ||
                          ifMenuUniqueIsFundsIn(sMH) ||
                          ifMenuUniqueIsLaundryPayment(sMH) ||
                          ifMenuUniqueIsFee(sMH)) &&
                      sMH.currentCounter < 0) {
                    setState(() {
                      sMH.currentCounter = sMH.currentCounter * -1;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Auto-correct: should be positive number.')),
                    );
                  } else if ((ifMenuUniqueIsCashOut(sMH) ||
                          ifMenuUniqueIsFundsOut(sMH) ||
                          ifMenuUniqueIsExpense(sMH)) &&
                      sMH.currentCounter > 0) {
                    setState(() {
                      sMH.currentCounter = sMH.currentCounter * -1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Auto-correct: should be negative number.')),
                    );
                  }

                  // if (ifMenuUniqueIsCashIn(sMH) || ifMenuUniqueIsCashOut(sMH)) {
                  //   var iFee = getFee(iAmountDisplay);
                  //   if (bNagbigayFee) {
                  //     showMessageSuppliseSave(
                  //         context,
                  //         setState,
                  //         "Confirm Save",
                  //         "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} ${sMH.currentCounter} \n ${(getItemNameOnly(sMH.itemId, menuOthUniqIdFee))} $iFee?",
                  //         sMH);
                  //   } else {
                  //     if (ifMenuUniqueIsCashIn(sMH)) {
                  //       showMessageSuppliseSave(
                  //           context,
                  //           setState,
                  //           "Confirm Save",
                  //           "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} ${sMH.currentCounter - iFee} \n ${(getItemNameOnly(sMH.itemId, menuOthUniqIdFee))} $iFee?",
                  //           sMH);
                  //     } else {
                  //       showMessageSuppliseSave(
                  //           context,
                  //           setState,
                  //           "Confirm Save",
                  //           "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} ${sMH.currentCounter + iFee} \n ${(getItemNameOnly(sMH.itemId, menuOthUniqIdFee))} $iFee?",
                  //           sMH);
                  //     }
                  //   }
                  // } else {
                  // if (sMH.itemUniqueId == menuOthUniqIdFundsEOD) {
                  //   showMessageSuppliseSave(
                  //       context,
                  //       setState,
                  //       "Confirm Save",
                  //       "Your current funds is ${sMH.currentCounter}, system will compute your short/excess?",
                  //       sMH);
                  // } else {
                  showMessageSuppliseSave(
                      context,
                      setState,
                      "Confirm Save",
                      "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} (${sMH.currentCounter} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)})?",
                      sMH);
                  // }
                  ///}
                }

                // if (sMH.customerId == 1 || !bCustomerName) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('Select Customer Name')),
                //   );
                // } else if ((sMH.itemUniqueId == menuOthUniqIdCashIn ||
                //         sMH.itemUniqueId == menuOthUniqIdFundsIn ||
                //         sMH.itemUniqueId == menuOthLaundryPayment) &&
                //     sMH.currentCounter < 0) {
                //   sMH.currentCounter = sMH.currentCounter * -1;
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //         content: Text(
                //             'Cash In/Funds In/Laundry Payment should be positive number.')),
                //   );
                // } else if ((sMH.itemUniqueId == menuOthUniqIdCashOut ||
                //         sMH.itemUniqueId == menuOthUniqIdFundsOut) &&
                //     sMH.currentCounter > 0) {
                //   sMH.currentCounter = sMH.currentCounter * -1;
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //         content: Text(
                //             'Cash Out/Funds Out should be negative number.')),
                //   );
                // } else {
                //   showMessageSuppliseSave(
                //       context,
                //       setState,
                //       "Save?",
                //       "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} (${sMH.currentCounter} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)})?",
                //       sMH);
                // }
              },
              child: Text(s)),
        ],
      ),
    );
  }

  ClipRRect conClipRRectZero(Function setState, SuppliesModelHist sMH) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Color.fromARGB(132, 151, 26, 26),
                Color.fromARGB(120, 233, 66, 54),
              ])),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(2),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  sMH.currentCounter = 0;
                  iAmountFinal = 0;
                  iAmountDisplay = 0;
                  bNagbigayFee = true;
                });
              },
              child: Text(allClear)),
        ],
      ),
    );
  }

  ClipRRect conClipRRectBlank(
      Function setState, SuppliesModelHist sMH, String s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Color.fromARGB(0, 151, 26, 26),
                Color.fromARGB(0, 233, 66, 54),
              ])),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(2),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {},
              child: Text("")),
        ],
      ),
    );
  }

  ClipRRect conClipRRectNegative(
      Function setState, SuppliesModelHist sMH, String s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Color.fromARGB(132, 151, 26, 26),
                Color.fromARGB(120, 233, 66, 54),
              ])),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(2),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  //iAmountDisplay = iAmountDisplay * -1;
                  sMH.currentCounter = sMH.currentCounter * -1;
                });
              },
              child: Text(s)),
        ],
      ),
    );
  }

  ClipRRect conClipRRectAdd(Function setState, SuppliesModelHist sMH, int i) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                Color(0XFF1976D2),
                Color(0XFF42A5F5),
              ])),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(2),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                String s = "${sMH.currentCounter}$i";
                setState(() {
                  iAmountFinal = int.parse(s);
                  iAmountDisplay = int.parse(s);
                  sMH.currentCounter = int.parse(s);
                  bNagbigayFee = true;
                });
              },
              child: Text("$i")),
        ],
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

  Visibility visITFDWDQ(Function setState) {
    return Visibility(
      visible: bViewMoreOptionsQ,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CustPickup"),
            Switch.adaptive(
              value: jobsOnQueueModelGlobal.initTagForDeliveryWhenDone,
              onChanged: (bool value) {
                setState(() {
                  jobsOnQueueModelGlobal.initTagForDeliveryWhenDone = value;
                });
              },
            ),
            Text("DelToCust"),
          ],
        ),
      ),
    );
  }

  Widget cancelButtonQ(BuildContext context, Function setState) {
    return MaterialButton(
        onPressed: () {
          resetJOQMGlobalVar();
          resetAddOnsGlobalVar();
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Cancel"));
  }

  Widget cancelButtonSupp(
      BuildContext context, Function setState, SuppliesModelHist sMH) {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        color: cButtons,
        child: const Text("Cancel"));
  }

  Widget zeroButtonSupp(
      BuildContext context, Function setState, SuppliesModelHist sMH) {
    return MaterialButton(
        onPressed: () {
          setState(() {
            sMH.currentCounter = 0;
          });
        },
        color: cButtons,
        child: const Text("0"));
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
    bCustomerName = false;
    //bAutoLaundry = false;
    //bInsertDataSuppliesHist = false;
    resetSHGlobalVar();
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
                      conEnterCustomer(context, setState),
                      visAddOnSupplies(context, setState, sMH),
                      conRemarksSuppliesVar(setState),
                      conCounterQ(context, setState, sMH),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // zeroButtonSupp(context, setState, sMH),

              // //cancel button
              // cancelButtonSupp(context, setState, sMH),

              // createNewSuppVar(context, sMH),

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                            "${map.itemGroup}-${map.itemName} ${(map.itemPrice <= 0 ? "" : "(${map.itemPrice} PhP)")}")); //422 donut display price for funds, cash out
                  }).toList(),
                  onChanged: (val) {
                    bGcashFee = false;
                    selectedSupVar = val!;
                    if (val?.itemUniqueId == menuOthUniqIdCashIn ||
                        val?.itemUniqueId == menuOthUniqIdCashOut) {
                      bGcashFee = true;
                    }
                    setState(
                      () {
                        selectedSupVar;
                        bGcashFee;
                      },
                    );

                    sMH.countId = 0;
                    sMH.itemId = selectedSupVar.itemId;
                    sMH.itemUniqueId = selectedSupVar.itemUniqueId;

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
          ],
        ),
      ),
    );
  }

  void showMessageSuppliseSave(BuildContext context, Function setState,
      String title, String message, SuppliesModelHist sMH) {
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
              cancelButtonVar(context),
              createNewSuppVar(context, sMH),
            ],
          );
        });
      },
    );
  }
}
