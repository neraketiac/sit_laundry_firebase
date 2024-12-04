import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/jobsonqueue.dart';
import 'package:laundry_firebase/models/otherItems.dart';
import 'package:laundry_firebase/pages/queue_mobile.dart';
import 'package:laundry_firebase/services/database_other_items.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MyQueue extends StatefulWidget {
  final String empid;

  const MyQueue(this.empid, {super.key});

  @override
  State<MyQueue> createState() => _MyQueueState();
}

class _MyQueueState extends State<MyQueue> {
  TextEditingController customerController = TextEditingController();
  TextEditingController initialLoadController = TextEditingController();
  TextEditingController initialPriceController = TextEditingController();
  //TextEditingController queueStatController = TextEditingController();
  TextEditingController paymentStatController = TextEditingController();
  TextEditingController paymentReceivedByController = TextEditingController();
  TextEditingController needOnController = TextEditingController();
  TextEditingController riderDeliverController = TextEditingController();
  TextEditingController actRiderDeliverController = TextEditingController();
  //TextEditingController kulangController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  //TextEditingController maySukliController = TextEditingController();

  TextEditingController productController = TextEditingController();

  late String _sCreatedBy;
  int _iInitialKilo = 8;
  int _iInitialPrice = 155;
  int _iInitialLoad = 1;
  int _iInitialTotalPrice = 0;

  late DateTime _dNeedOn = DateTime.now().add(Duration(minutes: 210));
  bool _bMaxFab = false;
  bool _bFold = true;
  bool _bMix = true;
  int _iBasket = 0;
  int _iBag = 0;
  final _formKey = GlobalKey<FormState>();

  late bool _bRiderPickup = false;
  late bool _bRegularSabon = true,
      _bSayoSabon = false,
      _bOtherServices = false,
      _bNotOtherServices = true;
  late bool _bUnpaid = true, _bPaidCash = false, _bPaidGCash = false;

  int _initialDet = menuDetBreezeDVal;
  int _initialFab = menuFabSurf24mlDVal;
  int _initialBle = menuBleColorSafeDVal;

  int _iDetPcs = 0, _iDetPrice = 0;
  int _iFabPcs = 0, _iFabPrice = 0;
  int _iBlePcs = 0, _iBlePrice = 0;

  static const Map<String, String> frequencyOptionsx = {
    "30 seconds": "thirty",
    "1 minute": "sixty",
    "2 minutes": "onetwenty",
  };

  late String _frequencyValuex = "Breeze(15php)";

  @override
  void initState() {
    super.initState();

    _sCreatedBy = widget.empid;

    _iInitialKilo = 8;
    _iInitialPrice = (_iInitialKilo ~/ 8) * iPriceDivider(_bRegularSabon);
    _iInitialLoad = (_iInitialKilo ~/ 8);

    putEntries();
  }

  //open new expense box
  void enterJobsOnQueue() {
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

                    /*
                    //QueueStat
                    DropdownMenu(
                      label: Text("Status",
                          style: TextStyle(
                            fontSize: 12.0,
                          )),
                      inputDecorationTheme: getThemeDropDown(),
                      controller: queueStatController,
                      hintText: "Status",
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                            value: "ForSorting", label: "ForSorting"),
                        DropdownMenuEntry(
                            value: "RiderPickup", label: "RiderPickup"),
                      ],
                      onSelected: (val) {},
                      initialSelection: "ForSorting",
                    ),
                    */
                    // QeueeStat CheckBox
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: containerQueBoxDecoration(),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       Expanded(
                    //         child: CheckboxListTile(
                    //             contentPadding: EdgeInsets.all(0),
                    //             subtitle: Text(
                    //               mapQueueStat[forSorting].toString(),
                    //             ),
                    //             // title: Expanded(
                    //             //     child: Text(
                    //             //   mapQueueStat[forSorting].toString(),
                    //             // )),
                    //             value: _bForSorting,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 _bForSorting = false;
                    //                 _bForRiderPickup = false;
                    //                 if (val!) {
                    //                   _bForSorting = val!;
                    //                 }
                    //               });
                    //             }),
                    //       ),
                    //       Expanded(
                    //         child: CheckboxListTile(
                    //             contentPadding: EdgeInsets.all(0),
                    //             subtitle: Text(
                    //               mapQueueStat[riderPickup].toString(),
                    //             ),
                    //             // title: Expanded(
                    //             //     child: Text(
                    //             //   mapQueueStat[riderPickup].toString(),
                    //             // )),
                    //             value: _bForRiderPickup,
                    //             onChanged: (val) {
                    //               setState(() {
                    //                 _bForSorting = false;
                    //                 _bForRiderPickup = false;
                    //                 if (val!) {
                    //                   _bForRiderPickup = val!;
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
                    //Customer Name
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: containerQueBoxDecoration(),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        // inputFormatters: [
                        //   FilteringTextInputFormatter.deny(RegExp(r'\s\b\w*'))
                        // ],
                        textAlign: TextAlign.center,
                        controller: customerController,
                        decoration: InputDecoration(
                            labelText: 'Customer Name',
                            hintText: 'Enter Customer Name'),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Required";
                          }
                        },
                      ),
                    ),
                    //New Estimate load
                    SizedBox(
                      height: 5,
                    ),
                    //QueueStat
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: containerQueBoxDecoration(),
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
                                      value: _bRegularSabon,
                                      onChanged: (val) {
                                        _bRegularSabon = false;
                                        _bSayoSabon = false;
                                        _bOtherServices = false;
                                        _bNotOtherServices = true;

                                        if (val!) {
                                          setState(
                                            () {
                                              _bRegularSabon = val;
                                            },
                                          );
                                        }

                                        _iInitialKilo = 8;
                                        _iInitialPrice = (_iInitialKilo ~/ 8) *
                                            iPriceDivider(_bRegularSabon);
                                        _iInitialLoad = (_iInitialKilo ~/ 8);
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
                                      value: _bSayoSabon,
                                      onChanged: (val) {
                                        _bSayoSabon = false;
                                        _bRegularSabon = false;
                                        _bOtherServices = false;
                                        _bNotOtherServices = true;

                                        if (val!) {
                                          setState(
                                            () {
                                              _bSayoSabon = val;
                                            },
                                          );
                                        }

                                        _iInitialKilo = 8;
                                        _iInitialPrice = (_iInitialKilo ~/ 8) *
                                            iPriceDivider(_bRegularSabon);
                                        _iInitialLoad = (_iInitialKilo ~/ 8);
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
                                      value: _bOtherServices,
                                      onChanged: (val) {
                                        _bSayoSabon = false;
                                        _bRegularSabon = false;
                                        _bOtherServices = false;
                                        _bNotOtherServices = false;

                                        if (val!) {
                                          setState(
                                            () {
                                              _bOtherServices = val;
                                            },
                                          );
                                        }

                                        _iInitialKilo = 0;
                                        _iInitialPrice = 0;
                                        _iInitialLoad = 0;
                                      })
                                ],
                              ),
                            ],
                          ),

                          //New estimate load +-8 kilo
                          Visibility(
                            visible: _bNotOtherServices,
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
                                            if (_iInitialKilo < 8) {
                                              _iInitialKilo = 8;
                                              _iInitialPrice = (_iInitialKilo ~/
                                                      8) *
                                                  iPriceDivider(_bRegularSabon);
                                              _iInitialLoad =
                                                  (_iInitialKilo ~/ 8);

                                              // setState(() => _iInitialKilo = 0);
                                              // setState(() => _iInitialPrice = 0);
                                              // setState(() => _iInitialLoad = 0);
                                            } else {
                                              if (_iInitialKilo % 8 != 0) {
                                                _iInitialKilo = _iInitialKilo -
                                                    (_iInitialKilo % 8);
                                              } else {
                                                _iInitialKilo =
                                                    _iInitialKilo - 8;
                                              }

                                              _iInitialPrice = (_iInitialKilo ~/
                                                      8) *
                                                  iPriceDivider(_bRegularSabon);

                                              _iInitialLoad =
                                                  (_iInitialKilo ~/ 8);

                                              // setState(
                                              //   () => _iInitialKilo,
                                              // );

                                              // setState(() => _iInitialPrice =
                                              //     (_iInitialKilo ~/ 8) *
                                              //         iPriceDivider(_bRegularSabon));
                                              // setState(() =>
                                              //     _iInitialLoad = (_iInitialKilo ~/ 8));
                                            }
                                            setState(() {
                                              _iInitialKilo;
                                              _iInitialLoad;
                                              _iInitialPrice;
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
                                            if (_iInitialKilo % 8 != 0) {
                                              _iInitialKilo = _iInitialKilo +
                                                  8 -
                                                  (_iInitialKilo % 8);
                                            } else {
                                              _iInitialKilo = _iInitialKilo + 8;
                                            }

                                            _iInitialPrice = (_iInitialKilo ~/
                                                    8) *
                                                (iPriceDivider(_bRegularSabon));
                                            _iInitialLoad = _iInitialKilo ~/ 8;

                                            // setState(() => _iInitialKilo);
                                            // setState(() => _iInitialPrice);
                                            // setState(() => _iInitialLoad);

                                            setState(() {
                                              _iInitialKilo;
                                              _iInitialLoad;
                                              _iInitialPrice;
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
                            visible: _bNotOtherServices,
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
                                            "${kiloDisplay(_iInitialKilo)} kilo"),
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
                                        Text("$_iInitialLoad"),
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
                                            "${autoPriceDisplay(_iInitialPrice, _bRegularSabon)}.00"),
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
                                            "Php ${_iInitialPrice + _iInitialTotalPrice}.00"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //New Estimate Load (+- 1 kilo)
                          Visibility(
                            visible: _bNotOtherServices,
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
                                            if (_iInitialKilo > 8) {
                                              if (_iInitialKilo % 8 == 1) {
                                                _iInitialPrice =
                                                    _iInitialPrice -
                                                        (_bRegularSabon
                                                            ? 25
                                                            : 25); //8-9kilo 25

                                                _iInitialLoad =
                                                    _iInitialLoad - 1;
                                              } else if (_iInitialKilo % 8 ==
                                                  2) {
                                                _iInitialPrice =
                                                    _iInitialPrice -
                                                        (_bRegularSabon
                                                            ? 45
                                                            : 50); //9-10kilo 45
                                              } else if (_iInitialKilo % 8 ==
                                                  3) {
                                                _iInitialPrice = _iInitialPrice -
                                                    (_bRegularSabon
                                                        ? 25
                                                        : 25); //10-11kilo 25
                                              } else if (_iInitialKilo % 8 ==
                                                  4) {
                                                _iInitialPrice =
                                                    _iInitialPrice -
                                                        (_bRegularSabon
                                                            ? 25
                                                            : 25); //11-12kilo
                                              } else if (_iInitialKilo % 8 ==
                                                  5) {
                                                _iInitialPrice =
                                                    _iInitialPrice -
                                                        (_bRegularSabon
                                                            ? 25
                                                            : 0); //12-13kilo
                                              } else if (_iInitialKilo % 8 ==
                                                  6) {
                                                _iInitialPrice =
                                                    _iInitialPrice -
                                                        (_bRegularSabon
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }

                                              _iInitialKilo = _iInitialKilo - 1;

                                              // if (_iInitialKilo % 8 == 1) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 25
                                              //               : 25)); //8-9kilo 25
                                              //   setState(() =>
                                              //       _iInitialLoad = _iInitialLoad - 1);
                                              // } else if (_iInitialKilo % 8 == 2) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 45
                                              //               : 50)); //9-10kilo 45
                                              // } else if (_iInitialKilo % 8 == 3) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 25
                                              //               : 25)); //10-11kilo 25
                                              // } else if (_iInitialKilo % 8 == 4) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 25
                                              //               : 25)); //11-12kilo
                                              // } else if (_iInitialKilo % 8 == 5) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 25
                                              //               : 0)); //12-13kilo
                                              // } else if (_iInitialKilo % 8 == 6) {
                                              //   setState(() => _iInitialPrice =
                                              //       _iInitialPrice -
                                              //           (_bRegularSabon
                                              //               ? 10
                                              //               : 0)); //13-16kilo
                                              // }

                                              // setState(() =>
                                              //     _iInitialKilo = _iInitialKilo - 1);
                                            }
                                            setState(() {
                                              _iInitialKilo;
                                              _iInitialLoad;
                                              _iInitialPrice;
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
                                            if (_iInitialKilo >= 8) {
                                              _iInitialKilo = _iInitialKilo + 1;
                                            }

                                            if (_iInitialKilo % 8 == 1) {
                                              _iInitialPrice = _iInitialPrice +
                                                  (_bRegularSabon
                                                      ? 25
                                                      : 25); //8-9kilo
                                            } else if (_iInitialKilo % 8 == 2) {
                                              _iInitialPrice = _iInitialPrice +
                                                  (_bRegularSabon
                                                      ? 45
                                                      : 50); //9-10kilo
                                              setState(() => _iInitialLoad =
                                                  _iInitialLoad + 1);
                                            } else if (_iInitialKilo % 8 == 3) {
                                              _iInitialPrice = _iInitialPrice +
                                                  (_bRegularSabon
                                                      ? 25
                                                      : 25); //10-11kilo
                                            } else if (_iInitialKilo % 8 == 4) {
                                              _iInitialPrice = _iInitialPrice +
                                                  (_bRegularSabon
                                                      ? 25
                                                      : 25); //11-12kilo
                                            } else if (_iInitialKilo % 8 == 5) {
                                              _iInitialPrice = _iInitialPrice +
                                                  (_bRegularSabon
                                                      ? 25
                                                      : 0); //12-13kilo
                                            } else {
                                              if (_iInitialPrice %
                                                      (iPriceDivider(
                                                          _bRegularSabon)) !=
                                                  0) {
                                                _iInitialPrice =
                                                    _iInitialPrice +
                                                        (_bRegularSabon
                                                            ? 10
                                                            : 0); //13-16kilo
                                              }
                                            }

                                            // if (_iInitialKilo >= 8) {
                                            //   setState(() =>
                                            //       _iInitialKilo = _iInitialKilo + 1);
                                            // }

                                            // if (_iInitialKilo % 8 == 1) {
                                            //   setState(() => _iInitialPrice =
                                            //       _iInitialPrice +
                                            //           (_bRegularSabon
                                            //               ? 25
                                            //               : 25)); //8-9kilo
                                            // } else if (_iInitialKilo % 8 == 2) {
                                            //   setState(() => _iInitialPrice =
                                            //       _iInitialPrice +
                                            //           (_bRegularSabon
                                            //               ? 45
                                            //               : 50)); //9-10kilo
                                            //   setState(() =>
                                            //       _iInitialLoad = _iInitialLoad + 1);
                                            // } else if (_iInitialKilo % 8 == 3) {
                                            //   setState(() => _iInitialPrice =
                                            //       _iInitialPrice +
                                            //           (_bRegularSabon
                                            //               ? 25
                                            //               : 25)); //10-11kilo
                                            // } else if (_iInitialKilo % 8 == 4) {
                                            //   setState(() => _iInitialPrice =
                                            //       _iInitialPrice +
                                            //           (_bRegularSabon
                                            //               ? 25
                                            //               : 25)); //11-12kilo
                                            // } else if (_iInitialKilo % 8 == 5) {
                                            //   setState(() => _iInitialPrice =
                                            //       _iInitialPrice +
                                            //           (_bRegularSabon
                                            //               ? 25
                                            //               : 0)); //12-13kilo
                                            // } else {
                                            //   if (_iInitialPrice %
                                            //           (iPriceDivider(_bRegularSabon)) !=
                                            //       0) {
                                            //     setState(() => _iInitialPrice =
                                            //         _iInitialPrice +
                                            //             (_bRegularSabon
                                            //                 ? 10
                                            //                 : 0)); //13-16kilo
                                            //   }
                                            // }

                                            setState(() {
                                              _iInitialKilo;
                                              _iInitialLoad;
                                              _iInitialPrice;
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
                    SizedBox(
                      height: 5,
                    ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //InitialLoad Estimate Load
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       IconButton(
                    //         onPressed: () {
                    //           setState(() => _iInitialLoad--);
                    //         },
                    //         icon: const Icon(Icons.remove),
                    //         color: Colors.blueAccent,
                    //       ),
                    //       Text("Estimated Load: $_iInitialLoad"),
                    //       IconButton(
                    //         onPressed: () {
                    //           setState(() => _iInitialLoad++);
                    //         },
                    //         icon: const Icon(Icons.add),
                    //         color: Colors.blueAccent,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //Initial Price
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: BoxDecoration(
                    //       border:
                    //           Border.all(color: Color(0xffD4D4D4), width: 2.0)),
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.number,
                    //     inputFormatters: <TextInputFormatter>[
                    //       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    //       FilteringTextInputFormatter.digitsOnly
                    //     ],
                    //     textAlign: TextAlign.center,
                    //     controller: initialPriceController,
                    //     decoration: InputDecoration(
                    //         labelText: 'Estimated Price',
                    //         hintText: 'Initial Price'),
                    //     validator: (val) {},
                    //   ),
                    // ),

                    //Detergent
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: containerSayoSabonBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(
                                () {
                                  _iDetPcs--;
                                  if (_iDetPcs < 0) {
                                    _iDetPcs = 0;
                                  }
                                  _iDetPrice =
                                      (mapDetPrice[_initialDet]! * (_iDetPcs));
                                  _iInitialTotalPrice =
                                      _iDetPrice + _iFabPrice + _iBlePrice;
                                },
                              );
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Detergent",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              DropdownButton<int>(
                                style: TextStyle(fontSize: 12),
                                items: mapDetNames
                                    .map((itemId, val) {
                                      return MapEntry(
                                          val,
                                          DropdownMenuItem<int>(
                                            value: itemId,
                                            child: Text(val),
                                          ));
                                    })
                                    .values
                                    .toList(),
                                value: _initialDet,
                                onChanged: (newVal) {
                                  if (newVal != null) {
                                    setState(() {
                                      _initialDet = newVal;
                                      _iDetPrice = (mapDetPrice[_initialDet]! *
                                          (_iDetPcs));
                                      _iInitialTotalPrice =
                                          _iDetPrice + _iFabPrice + _iBlePrice;
                                    });
                                  }
                                },
                              ),
                              Text(
                                "${_iDetPcs}pc Php $_iDetPrice.00",
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(
                                () {
                                  _iDetPcs++;
                                  _iDetPrice =
                                      (mapDetPrice[_initialDet]! * (_iDetPcs));
                                  _iInitialTotalPrice =
                                      _iDetPrice + _iFabPrice + _iBlePrice;
                                },
                              );
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    //Fabcon
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: containerSayoSabonBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          DropdownButton<int>(
                            style: TextStyle(fontSize: 12),
                            items: mapFabNames
                                .map((itemId, val) {
                                  return MapEntry(
                                      val,
                                      DropdownMenuItem<int>(
                                        value: itemId,
                                        child: Text(val),
                                      ));
                                })
                                .values
                                .toList(),
                            value: _initialFab,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _initialFab = newVal;
                                });
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),

                    //Bleach
                    Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: containerSayoSabonBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          DropdownButton<int>(
                            style: TextStyle(fontSize: 12),
                            items: mapBleNames
                                .map((itemId, val) {
                                  return MapEntry(
                                      val,
                                      DropdownMenuItem<int>(
                                        value: itemId,
                                        child: Text(val),
                                      ));
                                })
                                .values
                                .toList(),
                            value: _initialBle,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _initialBle = newVal;
                                });
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _iBasket--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Basket: $_iBasket"),
                          IconButton(
                            onPressed: () {
                              setState(() => _iBasket++);
                            },
                            icon: const Icon(Icons.add_circle),
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() => _iBag--);
                            },
                            icon: const Icon(Icons.remove_circle_outlined),
                            color: Colors.blueAccent,
                          ),
                          Text("Bag: $_iBag"),
                          IconButton(
                            onPressed: () {
                              setState(() => _iBag++);
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    //Payment New
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
                                  value: _bUnpaid,
                                  onChanged: (val) {
                                    _bUnpaid = false;
                                    _bPaidCash = false;
                                    _bPaidGCash = false;
                                    if (val!) {
                                      setState(
                                        () {
                                          _bUnpaid = val;
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
                                  value: _bPaidCash,
                                  onChanged: (val) {
                                    _bUnpaid = false;
                                    _bPaidCash = false;
                                    _bPaidGCash = false;
                                    if (val!) {
                                      setState(
                                        () {
                                          _bPaidCash = val;
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
                                  value: _bPaidGCash,
                                  onChanged: (val) {
                                    _bUnpaid = false;
                                    _bPaidCash = false;
                                    _bPaidGCash = false;
                                    if (val!) {
                                      setState(
                                        () {
                                          _bPaidGCash = val;
                                        },
                                      );
                                    }
                                  })
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Payment
                    // DropdownMenu(
                    //   label: Text("Payment",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       )),
                    //   inputDecorationTheme: getThemeDropDown(),
                    //   controller: paymentStatController,
                    //   hintText: "Payment",
                    //   dropdownMenuEntries: const [
                    //     DropdownMenuEntry(value: "Unpaid", label: "Unpaid"),
                    //     DropdownMenuEntry(value: "PaidCash", label: "PaidCash"),
                    //     DropdownMenuEntry(
                    //         value: "PaidGcash", label: "PaidGcash"),
                    //     DropdownMenuEntry(
                    //         value: "WaitingGcash", label: "WaitingGcash"),
                    //     DropdownMenuEntry(value: "Kulang", label: "Kulang"),
                    //     DropdownMenuEntry(value: "MaySukli", label: "MaySukli"),
                    //   ],
                    //   onSelected: (val) {
                    //     if (val != "Unpaid") {
                    //       paymentReceivedByController.text = _sCreatedBy;
                    //     } else {
                    //       paymentReceivedByController.clear();
                    //     }
                    //   },
                    //   initialSelection: "Unpaid",
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //Payment Received By
                    // DropdownMenu(
                    //   label: Text("Payment Received By",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //       )),
                    //   inputDecorationTheme: getThemeDropDown(),
                    //   controller: paymentReceivedByController,
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
                    //     setState(() {});
                    //   },
                    //   initialSelection: "N/a",
                    // ),
                    SizedBox(
                      height: 5,
                    ),

                    //Max Fab?
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(1.0),
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Reg Fab"),
                          Switch.adaptive(
                            value: _bMaxFab,
                            onChanged: (bool value) {
                              setState(() {
                                _bMaxFab = value;
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Fold"),
                          Switch.adaptive(
                            value: _bFold,
                            onChanged: (bool value) {
                              setState(() {
                                _bFold = value;
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
                      decoration: containerQueBoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dont Mix"),
                          Switch.adaptive(
                            value: _bMix,
                            onChanged: (bool value) {
                              setState(() {
                                _bMix = value;
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
                        controller: remarksController,
                        decoration: InputDecoration(
                            labelText: 'Remarks', hintText: 'Anu kakaiba'),
                        validator: (val) {},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // //Kulang
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: containerQueBoxDecoration(),
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.number,
                    //     inputFormatters: <TextInputFormatter>[
                    //       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    //       FilteringTextInputFormatter.digitsOnly
                    //     ],
                    //     textAlign: TextAlign.center,
                    //     controller: kulangController,
                    //     decoration: InputDecoration(
                    //         labelText: 'Kulang bayad',
                    //         hintText: 'Magkano kulang?'),
                    //     validator: (val) {},
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // //May Sukli
                    // Container(
                    //   padding: EdgeInsets.all(1.0),
                    //   decoration: containerQueBoxDecoration(),
                    //   child: TextFormField(
                    //     keyboardType: TextInputType.number,
                    //     inputFormatters: <TextInputFormatter>[
                    //       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    //       FilteringTextInputFormatter.digitsOnly
                    //     ],
                    //     textAlign: TextAlign.center,
                    //     controller: maySukliController,
                    //     decoration: InputDecoration(
                    //         labelText: 'May Sukli', hintText: 'Magkano sukli?'),
                    //     validator: (val) {},
                    //   ),
                    // ),
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
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(days: -1)));
                                  },
                                  icon:
                                      const Icon(Icons.remove_circle_outlined),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(days: 1)));
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
                                  "Need On: ${_dNeedOn.toString().substring(5, 14)}00",
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
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(hours: -1)));
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.blueAccent,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => _dNeedOn =
                                        _dNeedOn.add(Duration(hours: 1)));
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
          _createNewRecord(),
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
            onPressed: () {
              enterJobsOnQueue();
            },
            child: const Icon(Icons.local_laundry_service_sharp),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
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

  Widget _createNewRecord() {
    return MaterialButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing Data')),
          );

          //pop box
          Navigator.pop(context);

          insertDataJobsOnQueue(
            _sCreatedBy,
            customerController.text,
            _iInitialKilo,
            _iInitialLoad,
            _iInitialPrice,
            // int.parse(initialPriceController.text.isEmpty
            //     ? "0"
            //     : initialPriceController.text),
            //queueStatController.text,
            (_bRiderPickup
                ? mapQueueStat[riderPickup].toString()
                : mapQueueStat[forSorting].toString()),
            //paymentStatController.text,
            (_bUnpaid
                ? mapPaymentStat[unpaid].toString()
                : (_bPaidCash
                    ? mapPaymentStat[paidCash].toString()
                    : mapPaymentStat[paidGCash].toString())),
            paymentReceivedByController.text,
            _dNeedOn,
            _bMaxFab,
            _bFold,
            _bMix,
            _iBasket,
            _iBag,
            remarksController.text,
          );
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

  //insert
  void insertDataJobsOnQueue(
      String sCreatedBy,
      String sCustomer,
      int iInitialKilo,
      int iInitialLoad,
      int iInitialPrice,
      String sQueueStatus,
      String sPaymentStatus,
      String sPaymentReceivedBy,
      DateTime dNeedOn,
      bool bMaxFab,
      bool bFold,
      bool bMix,
      int iBasket,
      int iBag,
      String sRemarks) {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('JobsOnQueue');

    CollectionReference subRef =
        FirebaseFirestore.instance.collection('JobsOnQueue');
    DatabaseOtherItems databaseOtherItems;

    OtherItems otherItems =
        OtherItems(itemId: 123, itemName: "Breeze", itemPrice: 124);
    collRef
        .add({
          'DateQ': DateTime.now(),
          'CreatedBy': sCreatedBy,
          'Customer': sCustomer,
          'InitialKilo': iInitialKilo,
          'InitialLoad': iInitialLoad,
          'InitialPrice': iInitialPrice,
          'QueueStat': sQueueStatus,
          'PaymentStat': sPaymentStatus,
          'PaymentReceivedBy': sPaymentReceivedBy,
          'NeedOn': dNeedOn,
          'MaxFab': bMaxFab,
          'Fold': bFold,
          'Mix': bMix,
          'Basket': iBasket,
          'Bag': iBag,
          'Remarks': sRemarks,
        })
        .then((value) => {
              _sCreatedBy = "",
              customerController.clear(),
              _iInitialKilo = 8,
              _iInitialPrice =
                  (_iInitialKilo ~/ 8) * iPriceDivider(_bRegularSabon),
              _iInitialLoad = (_iInitialKilo ~/ 8),
              //initialPriceController.clear(),
              //queueStatController.clear(),
              _bRiderPickup = false,
              //paymentStatController.clear(),
              _bUnpaid = true,
              _bPaidCash = false,
              _bPaidGCash = false,
              paymentReceivedByController.clear(),
              dNeedOn = DateTime.now(),
              _bMaxFab = false,
              _bFold = true,
              _bMix = true,
              _iBasket = 0,
              _iBag = 0,
              remarksController.clear(),
              // subRef.doc(value.id).collection("OtherItems").add({
              //   'DateQ': DateTime.now(),
              // }),
              databaseOtherItems = DatabaseOtherItems(value.id),
              databaseOtherItems.addOtherItems(otherItems),
              messageResult(context, "Insert Done.$sCustomer"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));
    // }

    //re-read
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
}
