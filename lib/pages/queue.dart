import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/queue_mobile.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MyQueue extends StatefulWidget {
  const MyQueue({super.key});

  @override
  State<MyQueue> createState() => _MyQueueState();
}

class _MyQueueState extends State<MyQueue> {
  @override
  void initState() {
    super.initState();

    putEntries();
  }

  //textcontrollers
  TextEditingController jobidController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  int _initialJob = 0,
      _initialSelection = 0,
      _initialDet = 0,
      _initialFab = 0,
      _initialBle = 0,
      _initialOth = 0,
      _initialCount = -1;

  String selectedValue = 'Option 1';

  //open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Used products?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu(
              inputDecorationTheme: getThemeDropDown(),
              controller: jobidController,
              hintText: "Select Job Id",
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 1, label: "#1"),
                DropdownMenuEntry(value: 2, label: "#2"),
                DropdownMenuEntry(value: 3, label: "#3"),
                DropdownMenuEntry(value: 4, label: "#4"),
                DropdownMenuEntry(value: 5, label: "#5"),
                DropdownMenuEntry(value: 6, label: "#6"),
                DropdownMenuEntry(value: 7, label: "#7"),
                DropdownMenuEntry(value: 8, label: "#8"),
                DropdownMenuEntry(value: 9, label: "#9"),
                DropdownMenuEntry(value: 10, label: "#10"),
              ],
              onSelected: (val) {
                setState(() {
                  _initialJob = val!;
                });
              },
              initialSelection: _initialJob,
            ),
            DropdownMenu(
              inputDecorationTheme: getThemeDropDown(),
              controller: typeController,
              hintText: "Select type.",
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: menuDetDVal,
                  label: "Detergent",
                ),
                DropdownMenuEntry(value: menuFabDVal, label: "Fabcon"),
                DropdownMenuEntry(value: menuBleDVal, label: "Bleach"),
                DropdownMenuEntry(value: menuOthDVal, label: "Others"),
              ],
              onSelected: (val) {
                setState(() {
                  _initialSelection = val!;
                  showDet = false;
                  showFab = false;
                  showBle = false;
                  showOth = false;
                  if (val == menuDetDVal) {
                    showDet = true;
                  } else if (val == menuFabDVal) {
                    showFab = true;
                  } else if (val == menuBleDVal) {
                    showBle = true;
                  } else if (val == menuOthDVal) {
                    showOth = true;
                  }
                  reopenBox();
                });
              },
              initialSelection: _initialSelection,
            ),
            //det
            Visibility(
              visible: showDet,
              child: DropdownMenu(
                inputDecorationTheme: getThemeDropDown(),
                controller: productController,
                hintText: "Select product.",
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                      value: menuDetBreezeDVal,
                      label: mapDetNames[menuDetBreezeDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetArielDVal,
                      label: mapDetNames[menuDetArielDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetTideDVal,
                      label: mapDetNames[menuDetTideDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetWingsBlueDVal,
                      label: mapDetNames[menuDetWingsBlueDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetWingsRedDVal,
                      label: mapDetNames[menuDetWingsRedDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetPowerCleanDVal,
                      label: mapDetNames[menuDetPowerCleanDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetSurfDVal,
                      label: mapDetNames[menuDetSurfDVal].toString()),
                  DropdownMenuEntry(
                      value: menuDetKlinDVal,
                      label: mapDetNames[menuDetKlinDVal].toString()),
                ],
                onSelected: (val) {
                  _initialDet = val!;
                },
                initialSelection: _initialDet,
              ),
            ),
            //fab
            Visibility(
              visible: showFab,
              child: DropdownMenu(
                inputDecorationTheme: getThemeDropDown(),
                controller: productController,
                hintText: "Select product.",
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                      value: menuFabSurf24mlDVal,
                      label: mapFabNames[menuFabSurf24mlDVal].toString()),
                  DropdownMenuEntry(
                      value: menuFabDowny24mlDVal,
                      label: mapFabNames[menuFabDowny24mlDVal].toString()),
                  DropdownMenuEntry(
                      value: menuFabDownyTripidDVal,
                      label: mapFabNames[menuFabDownyTripidDVal].toString()),
                  DropdownMenuEntry(
                      value: menuFabDowny36mlDVal,
                      label: mapFabNames[menuFabDowny36mlDVal].toString()),
                  DropdownMenuEntry(
                      value: menuFabSurfTripidDVal,
                      label: mapFabNames[menuFabSurfTripidDVal].toString()),
                  DropdownMenuEntry(
                      value: menuFabWKL24mlDVal,
                      label: mapFabNames[menuFabWKL24mlDVal].toString()),
                ],
                onSelected: (val) {
                  _initialFab = val!;
                },
                initialSelection: _initialFab,
              ),
            ),
            //ble
            Visibility(
              visible: showBle,
              child: DropdownMenu(
                inputDecorationTheme: getThemeDropDown(),
                controller: productController,
                hintText: "Select product.",
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                      value: menuBleColorSafeDVal,
                      label: mapBleNames[menuBleColorSafeDVal].toString()),
                  DropdownMenuEntry(
                      value: menuBleOriginalDVal,
                      label: mapBleNames[menuBleOriginalDVal].toString()),
                ],
                onSelected: (val) {
                  _initialBle = val!;
                },
                initialSelection: _initialBle,
              ),
            ),
            //oth
            Visibility(
              visible: showOth,
              child: DropdownMenu(
                inputDecorationTheme: getThemeDropDown(),
                controller: productController,
                hintText: "Select product.",
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                      value: menuOthPlasticDVal,
                      label: mapOthNames[menuOthPlasticDVal].toString()),
                  DropdownMenuEntry(
                      value: menuOthScatchTapeDVal,
                      label: mapOthNames[menuOthScatchTapeDVal].toString()),
                ],
                onSelected: (val) {
                  _initialOth = val!;
                },
                initialSelection: _initialOth,
              ),
            ),
            DropdownMenu(
              inputDecorationTheme: getThemeDropDown(),
              controller: amountController,
              hintText: "Select amount.",
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: -1, label: "-1"),
                DropdownMenuEntry(value: -2, label: "-2"),
                DropdownMenuEntry(value: -3, label: "-3"),
                DropdownMenuEntry(value: -4, label: "-4"),
                DropdownMenuEntry(value: -5, label: "-5"),
                DropdownMenuEntry(value: -6, label: "-6"),
                DropdownMenuEntry(value: -7, label: "-7"),
                DropdownMenuEntry(value: -8, label: "-8"),
                DropdownMenuEntry(value: -9, label: "-9"),
                DropdownMenuEntry(value: -10, label: "-10"),
              ],
              onSelected: (val) {
                setState(() {
                  _initialCount = val!;
                });
              },
              initialSelection: _initialCount,
            ),
            DropdownButton<String>(
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            /*
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(hintText: "enter remarks"),
            ),
            */
          ],
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

  reopenBox() {
//pop box
    Navigator.pop(context);

    //clear controllers
    //productController.clear();
    typeController.clear();
    //amountController.clear();
    //remarkController.clear();
    openNewExpenseBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Text("watata"),
      body: MyQueueMobile(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openNewExpenseBox();
        },
        child: const Icon(Icons.remove_circle),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);

          //clear controllers
          productController.clear();
          amountController.clear();
          remarkController.clear();
        },
        child: const Text("Cancel"));
  }

  Widget _createNewRecord() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //run firebase add
        if (_initialSelection == menuDetDVal) {
          insertData(_initialJob, "Det", _initialDet, _initialCount);
        } else if (_initialSelection == menuFabDVal) {
          insertData(_initialJob, "Fab", _initialFab, _initialCount);
        } else if (_initialSelection == menuBleDVal) {
          insertData(_initialJob, "Ble", _initialBle, _initialCount);
        } else if (_initialSelection == menuOthDVal) {
          insertData(_initialJob, "Oth", _initialOth, _initialCount);
        }
      },
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
                  child: const Text("Ok"),
                ),
              ],
            ));
  }

  //insert
  void insertData(int jobid, String sType, int id, int count) {
    //insert
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('ProductsUsed');
    collRef
        .add({
          'jobid': jobid,
          'Id': id,
          'Count': count,
          'Type': sType,
          'Date': DateTime.now(),
        })
        .then((value) => {
              messageResult(context, "Insert Done."),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => messageResult(context, "Failed : $error"));

    //re-read
  }

  getThemeDropDown() {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints.tight(const Size.fromHeight(40)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
