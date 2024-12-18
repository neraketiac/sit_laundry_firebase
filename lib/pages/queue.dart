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
  late String _sCreatedBy;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _sCreatedBy = widget.empid;

    iInitialKiloVar = 8;
    iInitialPriceVar = (iInitialKiloVar ~/ 8) * iPriceDivider(bRegularSabonVar);
    iInitialLoadVar = (iInitialKiloVar ~/ 8);
  }

  //jobsonqueue
  void showJobsOnQueueEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "New Laundry ${DateTime.now().toString().substring(5, 13)}",
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
                key: _formKey,
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
                            value: bRiderPickupVar,
                            onChanged: (bool value) {
                              setState(() {
                                bRiderPickupVar = value;
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
                                      value: bRegularSabonVar,
                                      onChanged: (val) {
                                        resetRegular();

                                        if (val!) {
                                          setState(
                                            () {
                                              bRegularSabonVar = val;
                                            },
                                          );
                                        }

                                        iInitialKiloVar = 8;
                                        iInitialPriceVar =
                                            (iInitialKiloVar ~/ 8) *
                                                iPriceDivider(bRegularSabonVar);
                                        iInitialLoadVar =
                                            (iInitialKiloVar ~/ 8);
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
                                      value: bSayoSabonVar,
                                      onChanged: (val) {
                                        resetRegular();

                                        if (val!) {
                                          setState(
                                            () {
                                              bSayoSabonVar = val;
                                            },
                                          );
                                        }

                                        iInitialKiloVar = 8;
                                        iInitialPriceVar =
                                            (iInitialKiloVar ~/ 8) *
                                                iPriceDivider(bRegularSabonVar);
                                        iInitialLoadVar =
                                            (iInitialKiloVar ~/ 8);
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
                                      value: bOtherServicesVar,
                                      onChanged: (val) {
                                        resetRegular();
                                        bNotOtherServicesVar = false;

                                        if (val!) {
                                          setState(
                                            () {
                                              bOtherServicesVar = val;
                                            },
                                          );
                                        }

                                        iInitialKiloVar = 0;
                                        iInitialPriceVar = 0;
                                        iInitialLoadVar = 0;
                                      })
                                ],
                              ),
                            ],
                          ),
                          //New estimate load +-8 kilo
                          Visibility(
                            visible: bNotOtherServicesVar,
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
                                            if (iInitialKiloVar < 8) {
                                              iInitialKiloVar = 8;
                                              iInitialPriceVar =
                                                  (iInitialKiloVar ~/ 8) *
                                                      iPriceDivider(
                                                          bRegularSabonVar);
                                              iInitialLoadVar =
                                                  (iInitialKiloVar ~/ 8);
                                            } else {
                                              if (iInitialKiloVar % 8 != 0) {
                                                iInitialKiloVar =
                                                    iInitialKiloVar -
                                                        (iInitialKiloVar % 8);
                                              } else {
                                                iInitialKiloVar =
                                                    iInitialKiloVar - 8;
                                              }

                                              iInitialPriceVar =
                                                  (iInitialKiloVar ~/ 8) *
                                                      iPriceDivider(
                                                          bRegularSabonVar);

                                              iInitialLoadVar =
                                                  (iInitialKiloVar ~/ 8);
                                            }
                                            setState(() {
                                              iInitialKiloVar;
                                              iInitialLoadVar;
                                              iInitialPriceVar;
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
                                            if (iInitialKiloVar % 8 != 0) {
                                              iInitialKiloVar =
                                                  iInitialKiloVar +
                                                      8 -
                                                      (iInitialKiloVar % 8);
                                            } else {
                                              iInitialKiloVar =
                                                  iInitialKiloVar + 8;
                                            }

                                            iInitialPriceVar =
                                                (iInitialKiloVar ~/ 8) *
                                                    (iPriceDivider(
                                                        bRegularSabonVar));
                                            iInitialLoadVar =
                                                iInitialKiloVar ~/ 8;
                                            setState(() {
                                              iInitialKiloVar;
                                              iInitialLoadVar;
                                              iInitialPriceVar;
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
                            visible: bNotOtherServicesVar,
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
                                            "${kiloDisplay(iInitialKiloVar)} kilo"),
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
                                        Text("$iInitialLoadVar"),
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
                                            "${autoPriceDisplay(iInitialPriceVar, bRegularSabonVar)}.00"),
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
                                            "Php ${iInitialPriceVar + iInitialOthersPriceVar}.00"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //New Estimate Load (+- 1 kilo)
                          Visibility(
                            visible: bNotOtherServicesVar,
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
                                            if (iInitialKiloVar > 8) {
                                              if (iInitialKiloVar % 8 == 1) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 25
                                                            : 25); //8-9kilo 25

                                                iInitialLoadVar =
                                                    iInitialLoadVar - 1;
                                              } else if (iInitialKiloVar % 8 ==
                                                  2) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 45
                                                            : 50); //9-10kilo 45
                                              } else if (iInitialKiloVar % 8 ==
                                                  3) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 25
                                                            : 25); //10-11kilo 25
                                              } else if (iInitialKiloVar % 8 ==
                                                  4) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 25
                                                            : 25); //11-12kilo
                                              } else if (iInitialKiloVar % 8 ==
                                                  5) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 25
                                                            : 0); //12-13kilo
                                              } else if (iInitialKiloVar % 8 ==
                                                  6) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar -
                                                        (bRegularSabonVar
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }

                                              iInitialKiloVar =
                                                  iInitialKiloVar - 1;
                                            }
                                            setState(() {
                                              iInitialKiloVar;
                                              iInitialLoadVar;
                                              iInitialPriceVar;
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
                                            if (iInitialKiloVar >= 8) {
                                              iInitialKiloVar =
                                                  iInitialKiloVar + 1;
                                            }

                                            if (iInitialKiloVar % 8 == 1) {
                                              iInitialPriceVar =
                                                  iInitialPriceVar +
                                                      (bRegularSabonVar
                                                          ? 25
                                                          : 25); //8-9kilo
                                            } else if (iInitialKiloVar % 8 ==
                                                2) {
                                              iInitialPriceVar =
                                                  iInitialPriceVar +
                                                      (bRegularSabonVar
                                                          ? 45
                                                          : 50); //9-10kilo
                                              setState(() => iInitialLoadVar =
                                                  iInitialLoadVar + 1);
                                            } else if (iInitialKiloVar % 8 ==
                                                3) {
                                              iInitialPriceVar =
                                                  iInitialPriceVar +
                                                      (bRegularSabonVar
                                                          ? 25
                                                          : 25); //10-11kilo
                                            } else if (iInitialKiloVar % 8 ==
                                                4) {
                                              iInitialPriceVar =
                                                  iInitialPriceVar +
                                                      (bRegularSabonVar
                                                          ? 25
                                                          : 25); //11-12kilo
                                            } else if (iInitialKiloVar % 8 ==
                                                5) {
                                              iInitialPriceVar =
                                                  iInitialPriceVar +
                                                      (bRegularSabonVar
                                                          ? 25
                                                          : 0); //12-13kilo
                                            } else {
                                              if (iInitialPriceVar %
                                                      (iPriceDivider(
                                                          bRegularSabonVar)) !=
                                                  0) {
                                                iInitialPriceVar =
                                                    iInitialPriceVar +
                                                        (bRegularSabonVar
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }
                                            }

                                            setState(() {
                                              iInitialKiloVar;
                                              iInitialLoadVar;
                                              iInitialPriceVar;
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
                      decoration: containerSayoSabonBoxDecoration(),
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
                                  value: bAddOnVar,
                                  onChanged: (val) {
                                    if (listAddOnItems.isNotEmpty) {
                                      if (!val!) {
                                        //pop box
                                        Navigator.pop(context);
                                        messageResultNew(
                                            "Uncheck will delete add on?");
                                      }
                                    }

                                    setState(
                                      () {
                                        bAddOnVar = val!;
                                      },
                                    );
                                  }),
                              //checkboxes add on
                              Visibility(
                                visible: bAddOnVar,
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
                              addOnDropDown(
                                  bDetAddOnVar, selectedDetVar, listDetItems),
                              //dropdown fab
                              addOnDropDown(
                                  bFabAddOnVar, selectedFabVar, listFabItems),
                              //dropdown ble
                              addOnDropDown(
                                  bBleAddOnVar, selectedBleVar, listBleItems),
                              //dropdown oth
                              addOnDropDown(
                                  bOthAddOnVar, selectedOthVar, listOthItems),
                              _readAddedData(listAddOnItems),
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => iBasketVar--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Basket: $iBasketVar"),
                          IconButton(
                            onPressed: () {
                              setState(() => iBasketVar++);
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
                              setState(() => iBagVar--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Bag: $iBagVar"),
                          IconButton(
                            onPressed: () {
                              setState(() => iBagVar++);
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
                                  value: bUnpaidVar,
                                  onChanged: (val) {
                                    resetPaymentQueueBool();
                                    if (val!) {
                                      setState(
                                        () {
                                          bUnpaidVar = val;
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
                                  value: bPaidCashVar,
                                  onChanged: (val) {
                                    resetPaymentQueueBool();
                                    if (val!) {
                                      setState(
                                        () {
                                          bPaidCashVar = val;
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
                                  value: bPaidGCashVar,
                                  onChanged: (val) {
                                    resetPaymentQueueBool();
                                    if (val!) {
                                      setState(
                                        () {
                                          bPaidGCashVar = val;
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Fold"),
                          Switch.adaptive(
                            value: bFoldVar,
                            onChanged: (bool value) {
                              setState(() {
                                bFoldVar = value;
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dont Mix"),
                          Switch.adaptive(
                            value: bMixVar,
                            onChanged: (bool value) {
                              setState(() {
                                bMixVar = value;
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
                      decoration: containerQueBoxDecoration(),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        textAlign: TextAlign.start,
                        controller: remarksControllerVar,
                        decoration: InputDecoration(
                            labelText: 'Remarks', hintText: 'Anu kakaiba'),
                        validator: (val) {},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Need On Date +
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: containerQueBoxDecoration(),
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
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
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
                                    setState(() => dNeedOnVar =
                                        dNeedOnVar.add(Duration(hours: -1)));
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => dNeedOnVar =
                                        dNeedOnVar.add(Duration(hours: 1)));
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

          //save button new
          _createNewRecordJson(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Text("watata"),
      body: MyQueueMobile(_sCreatedBy),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "JobsOnQueue",
            onPressed: () {
              showJobsOnQueueEntry();
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
        } else if (_formKey.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);
          insertDataJobsOnQueueJson(JobsOnQueueModel(
              dateQ: Timestamp.now(),
              createdBy: _sCreatedBy,
              customerId: autocompleteSelected.customerId,
              initialKilo: iInitialKiloVar,
              initialLoad: iInitialLoadVar,
              initialPrice: iInitialPriceVar,
              initialOthersPrice: iInitialOthersPriceVar,
              finalKilo: 0,
              finalLoad: 0,
              finalPrice: 0,
              finalOthersPrice: 0,
              queueStat: (bRiderPickupVar
                  ? mapQueueStat[riderPickup].toString()
                  : mapQueueStat[forSorting].toString()),
              paymentStat: (bUnpaidVar
                  ? mapPaymentStat[unpaid].toString()
                  : (bPaidCashVar
                      ? mapPaymentStat[paidCash].toString()
                      : (bPaidGCashVar
                          ? mapPaymentStat[paidGCash].toString()
                          : mapPaymentStat[waitGCash].toString()))),
              paymentReceivedBy: (bUnpaidVar ? "" : _sCreatedBy),
              paidD: (bUnpaidVar
                  ? Timestamp.fromDate(DateTime(2000))
                  : Timestamp.now()),
              needOn: tNeedOnVar,
              fold: bFoldVar,
              mix: bMixVar,
              basket: iBasketVar,
              bag: iBagVar,
              remarks: remarksControllerVar.text));
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
                    iInitialOthersPriceVar = 0;
                    resetAddOn();
                    showJobsOnQueueEntry();
                  },
                  color: cButtons,
                  child: const Text("Ok"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    bAddOnVar = true;
                    showJobsOnQueueEntry();
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

    _sCreatedBy = "";
    iInitialKiloVar = 8;
    iInitialLoadVar = 0;
    iInitialPriceVar = 155;
    iInitialOthersPriceVar = 0;
    bRiderPickupVar = false;
    bUnpaidVar = false;
    bPaidCashVar = false;
    bPaidGCashVar = false;
    dNeedOnVar = DateTime.now();
    bFoldVar = true;
    bMixVar = true;
    iBasketVar = 0;
    iBagVar = 0;

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
      List<OtherItemModel> thisListOtherItemModel) {
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
                listAddOnItems.add(selectedItemModel);
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
                iInitialOthersPriceVar =
                    iInitialOthersPriceVar + selectedItemModel.itemPrice;
                showJobsOnQueueEntry();
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
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
}
