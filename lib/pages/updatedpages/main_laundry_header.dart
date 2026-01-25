import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/updatedpages/main_laundry_body.dart';
import 'package:laundry_firebase/services/database_employee_current.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsonqueue_repository.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

class MyMainLaundryHeader extends StatefulWidget {
  final String empid;

  const MyMainLaundryHeader(this.empid, {super.key});

  @override
  State<MyMainLaundryHeader> createState() => _MyMainLaundryHeaderState();
}

class _MyMainLaundryHeaderState extends State<MyMainLaundryHeader> {
  late String _sEmpId;

  late bool isGcashCredit = false;
  static const double _fieldIndentWidth = 40;
  //TextEditingController customerNameVar = TextEditingController();
  TextEditingController customerNumberVar = TextEditingController();
  TextEditingController customerAmountVar = TextEditingController();

  final NumberFormat pesoFormat = NumberFormat('#,##0', 'en_PH');

  //end of day
  final List<int> _denominations = [1000, 500, 200, 100, 50, 20, 10, 5, 1];

  final Map<int, int> _qtyMap = {
    for (final d in [1000, 500, 200, 100, 50, 20, 10, 5, 1]) d: 0,
  };

  int _selectedFundCode = menuOthUniqIdCashIn;
  final List<int> fundTypeCodes1stLayer = [
    menuOthUniqIdCashIn,
    menuOthUniqIdCashOut,
  ];
  final List<int> fundTypeCodes2ndLayer = [
    menuOthUniqIdFundsIn,
    menuOthUniqIdFundsOut,
  ];
  final List<int> fundTypeCodes3rdLayer = [
    menuOthLaundryPayment,
    menuOthUniqIdLoad,
  ];
  final List<int> fundTypeCodes4thLayer = [
    menuOthSalaryPayment,
  ];

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    empIdGlobal = _sEmpId;
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    JobsOnQueueRepository.instance.loadOnce();
    JobsOnQueueRepository.instance.setCreatedBy(_sEmpId);
    JobsOnQueueRepository.instance.currentEmpId(_sEmpId);
    SuppliesHistRepository.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: "JobsOnQueuex",
          //   onPressed: () {
          //     remarksControllerVar.text =
          //         ""; //fix when click with remarks then new, fix to remove remarks
          //     showNewJobsForQueue();
          //   },
          //   child: const Icon(Icons.local_laundry_service_sharp),
          // ),
          // SizedBox(
          //   height: 5,
          // ),

          FloatingActionButton(
            heroTag: "Enter New Record...",
            onPressed: () {
              _showEnterNewRecord();
            },
            child: const Text(
              "₱",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          FloatingActionButton(
            backgroundColor: cFundsEODShaded,
            hoverColor: cFundsEOD,
            heroTag: "Out",
            onPressed: () {
              _showEndOfDay();
            },
            child: const Icon(Icons.timer_off_outlined),
          ),

          FloatingActionButton(
            backgroundColor: Colors.lightBlue.shade100,
            hoverColor: Colors.lightBlue,
            onPressed: () {
              _showGcashCredit();
            },
            child: const Icon(Icons.g_mobiledata),
          ),
          Visibility(
            visible: (isAdmin ? true : allowPayment),
            child: FloatingActionButton(
              backgroundColor: Colors.yellowAccent.shade100,
              hoverColor: Colors.yellowAccent,
              heroTag: "Admin",
              onPressed: () {
                _showSalary();
              },
              child: const Icon(Icons.add_moderator_outlined),
            ),
          ),
        ],
      ),
    );
  }

//floating button new record  ###########################################################
  void _showEnterNewRecord() {
    // debugPrint('${_selectedFundCode}watata$menuOthSalaryPayment');
    if (_selectedFundCode == menuOthSalaryPayment) {
      //   debugPrint('wetete');
      _selectedFundCode = menuOthUniqIdCashIn;
    }
    // final FocusNode nameFocusNode = FocusNode();

    // void normalizeName() {
    //   final text = customerNameVar.text.trim().toLowerCase();

    //   if (nameMap.containsKey(text)) {
    //     customerNameVar.text = nameMap[text]!;
    //   }
    // }

    // nameFocusNode.addListener(() {
    //   if (!nameFocusNode.hasFocus) {
    //     normalizeName();
    //   }
    // });

    Visibility fundTypeToggle(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(6.0),
          decoration: decoLightBlue(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 TOP ROW
              ToggleButtons(
                isSelected: List.generate(
                  fundTypeCodes1stLayer.length,
                  (i) => _selectedFundCode == fundTypeCodes1stLayer[i],
                ),
                onPressed: (index) {
                  setState(() {
                    _selectedFundCode = fundTypeCodes1stLayer[index];
                    SuppliesHistRepository.instance
                        .setItemId(menuOthCashInOutFunds);
                    SuppliesHistRepository.instance
                        .setItemUniqueId(_selectedFundCode);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: Colors.black,
                constraints: const BoxConstraints(
                  minWidth: 110,
                  minHeight: 40,
                ),
                children: const [
                  Text('Cash In'),
                  Text('Cash Out'),
                ],
              ),

              const SizedBox(height: 8),

              // 🔹 SECOND ROW
              ToggleButtons(
                isSelected: List.generate(
                  fundTypeCodes2ndLayer.length,
                  (i) => _selectedFundCode == fundTypeCodes2ndLayer[i],
                ),
                onPressed: (index) {
                  setState(() {
                    _selectedFundCode = fundTypeCodes2ndLayer[index];
                    SuppliesHistRepository.instance
                        .setItemId(menuOthCashInOutFunds);
                    SuppliesHistRepository.instance
                        .setItemUniqueId(_selectedFundCode);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: Colors.black,
                constraints: const BoxConstraints(
                  minWidth: 110,
                  minHeight: 40,
                ),
                children: const [
                  Text('Funds In'),
                  Text('Funds Out'),
                ],
              ),

              const SizedBox(height: 8),

              // 🔹 THIRD ROW
              ToggleButtons(
                isSelected: List.generate(
                  fundTypeCodes3rdLayer.length,
                  (i) => _selectedFundCode == fundTypeCodes3rdLayer[i],
                ),
                onPressed: (index) {
                  setState(() {
                    _selectedFundCode = fundTypeCodes3rdLayer[index];
                    SuppliesHistRepository.instance
                        .setItemId(menuOthCashInOutFunds);
                    SuppliesHistRepository.instance
                        .setItemUniqueId(_selectedFundCode);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: Colors.black,
                constraints: const BoxConstraints(
                  minWidth: 110,
                  minHeight: 40,
                ),
                children: const [
                  Text('PayLaundry'),
                  Text('Load'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Visibility customerAmount(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (not indented)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount field
              TextFormField(
                controller: customerAmountVar,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'\d+(\.\d{0,2})?'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: const OutlineInputBorder(),
                  prefixIcon: SizedBox(
                    width: _fieldIndentWidth,
                    child: const Center(
                      child: Text(
                        '₱',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Visibility customerName(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Label + Checkbox on same row
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [],
                ),
              ),

              // 🔹 Input Field (disabled if employee is checked)
              // TextFormField(
              //   controller: customerNameVar,
              //   focusNode: nameFocusNode,
              //   textCapitalization: TextCapitalization.words,
              //   decoration: const InputDecoration(
              //     hintText: 'Enter Name',
              //     prefixIcon: SizedBox(width: _fieldIndentWidth),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              AutoCompleteCustomer(),
              SizedBox(
                height: 5,
              ),
              MaterialButton(
                color: cButtons,
                onPressed: () {
                  allCardsVar(context);
                },
                child: Text("New Account"),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      );
    }

    Future<void> saveButtonProcessCash() async {
      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, _selectedFundCode));
      SuppliesHistRepository.instance.setItemUniqueId(_selectedFundCode);
      SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
      SuppliesHistRepository.instance.setCurrentCounter(
          int.parse(customerAmountVar.text.replaceAll(',', '')));
      await _insertToFB();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Cash Funds",
              textAlign: TextAlign.center,
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
                      fundTypeToggle(setState),
                      customerAmount(setState),
                      customerName(setState),
                      conRemarksSuppliesVar(setState),
                    ],
                  ),
                ),
              ),
            ),
            // 👇 Bottom buttons
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close popup
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (customerAmountVar.text.isEmpty ||
                      int.parse(customerAmountVar.text) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter amount.')),
                    );
                  } else if (ifMenuUniqueIsFundsOut(
                          SuppliesHistRepository.instance.suppliesModelHist!) &&
                      remarksSuppliesVar.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Remarks is required for Funds Out.')),
                    );
                  } else if (ifMenuUniqueIsFundsOut(
                          SuppliesHistRepository.instance.suppliesModelHist!) &&
                      !empNameToId.containsKey(autocompleteSelected.name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Name must be an employee for Funds Out.')),
                    );
                  } else {
                    await saveButtonProcessCash();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

//floating gcash credit  ###########################################################
  void _showGcashCredit() {
    _selectedFundCode = menuOthUniqIdCashIn;
    // final FocusNode nameFocusNode = FocusNode();

    // void normalizeName() {
    //   final text = customerNameVar.text.trim().toLowerCase();

    //   if (nameMap.containsKey(text)) {
    //     customerNameVar.text = nameMap[text]!;
    //   }
    // }

    // nameFocusNode.addListener(() {
    //   if (!nameFocusNode.hasFocus) {
    //     normalizeName();
    //   }
    // });

    Visibility fundTypeToggle(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(6.0),
          decoration: decoLightBlue(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 TOP ROW
              ToggleButtons(
                isSelected: List.generate(
                  1,
                  (i) => _selectedFundCode == fundTypeCodes1stLayer[i],
                ),
                onPressed: (index) {
                  setState(() {
                    _selectedFundCode = fundTypeCodes1stLayer[index];
                    SuppliesHistRepository.instance
                        .setItemId(menuOthCashInOutFunds);
                    SuppliesHistRepository.instance
                        .setItemUniqueId(_selectedFundCode);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                color: Colors.black,
                constraints: const BoxConstraints(
                  minWidth: 110,
                  minHeight: 40,
                ),
                children: const [
                  Text('Gcash Credit'),
                ],
              ),

              const SizedBox(height: 8),
              //
            ],
          ),
        ),
      );
    }

    Visibility customerAmount(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (not indented)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount field
              TextFormField(
                controller: customerAmountVar,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'\d+(\.\d{0,2})?'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: const OutlineInputBorder(),
                  prefixIcon: SizedBox(
                    width: _fieldIndentWidth,
                    child: const Center(
                      child: Text(
                        '₱',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Visibility customerName(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Label + Checkbox on same row
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Input Field (disabled if employee is checked)
              // TextFormField(
              //   controller: customerNameVar,
              //   focusNode: nameFocusNode,
              //   textCapitalization: TextCapitalization.words,
              //   decoration: const InputDecoration(
              //     hintText: 'Enter Name',
              //     prefixIcon: SizedBox(width: _fieldIndentWidth),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              AutoCompleteCustomer(),
              // SizedBox(
              //   height: 5,
              // ),
              // MaterialButton(
              //   color: cButtons,
              //   onPressed: () {
              //     allCardsVar(context);
              //   },
              //   child: Text("New Account"),
              // ),
            ],
          ),
        ),
      );
    }

    Future<void> saveButtonProcessCash() async {
      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, _selectedFundCode));
      SuppliesHistRepository.instance.setItemUniqueId(_selectedFundCode);
      SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
      SuppliesHistRepository.instance.setCurrentCounter(
          int.parse(customerAmountVar.text.replaceAll(',', '')));
      await _insertToFB();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.lightBlue,
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Employee Credit\n",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "to be deducted ",
                    style: TextStyle(
                      fontSize: 10, // 👈 smaller
                    ),
                  ),
                  TextSpan(
                    text: "to your balance",
                    style: TextStyle(
                      fontSize: 10, // 👈 smaller
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
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
                      // fundTypeToggle(setState),
                      customerAmount(setState),
                      customerName(setState),
                      conRemarksSuppliesVar(setState),
                    ],
                  ),
                ),
              ),
            ),
            // 👇 Bottom buttons
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close popup
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (empNameToId.containsKey(autocompleteSelected.name)) {
                    isGcashCredit = true;
                    await saveButtonProcessCash();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Customer name must be an employee for Gcash Credit.')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

//floating button done jobs  ###########################################################
  void _showEndOfDay() {
    void resetAllQty() {
      _qtyMap.updateAll((key, value) => 0);
    }

    Visibility countBills(Function setState) {
      Widget _denominationRow(int denom, Function setState) {
        final qty = _qtyMap[denom]!;

        return Row(
          children: [
            // 🔹 Denomination (left)
            SizedBox(
              width: 60,
              child: Text(
                '$denom',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 6),
            // 🔹 Qty box
            Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Text(
                '$qty',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 6),

            // 🔹 -1 button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: qty > 0
                  ? () {
                      setState(() {
                        _qtyMap[denom] = qty - 1;
                      });
                    }
                  : null,
            ),

            // 🔹 +1 button
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () {
                setState(() {
                  _qtyMap[denom] = qty + 1;
                });
              },
            ),
          ],
        );
      }

      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: decoLightBlue(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 All denomination inputs
              ..._denominations.map(
                (d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: _denominationRow(d, setState),
                ),
              ),

              const Divider(height: 10),

              // 🔹 TOTAL
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'TOTAL: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₱ ${pesoFormat.format(_grandTotal)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Future<void> saveButtonProcessEOD() async {
      String buildSelectedMoneyText() {
        final List<String> parts = [];

        String formatDenom(int denom) {
          if (denom >= 1000) {
            return '${denom ~/ 1000}k';
          } else if (denom >= 100) {
            return '${denom ~/ 100}h';
          } else {
            return denom.toString();
          }
        }

        _qtyMap.forEach((denom, qty) {
          if (qty > 0) {
            //parts.add('₱$denom=$qty');
            parts.add('₱${formatDenom(denom)}');
          }
        });

        return parts.join(',');
      }

      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, menuOthUniqIdFundsEOD));
      SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdFundsEOD);
      SuppliesHistRepository.instance.setRemarks(buildSelectedMoneyText());
      SuppliesHistRepository.instance.setCurrentCounter(_grandTotal);

      await _insertToFB();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: cFundsEOD,
            title: Text(
              "Counting Bills",
              textAlign: TextAlign.center,
              style: TextStyle(backgroundColor: cFundsEOD),
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
                      countBills(setState),
                    ],
                  ),
                ),
              ),
            ),
            // 👇 Bottom buttons
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    resetAllQty();
                  });
                  Navigator.pop(context); // close popup
                },
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () async {
                  saveButtonProcessEOD();
                  setState(() {
                    resetAllQty();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

//floating salary  ###########################################################
  void _showSalary() {
    _selectedFundCode = menuOthSalaryPayment;

    Visibility customerAmount(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (not indented)
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount field
              TextFormField(
                controller: customerAmountVar,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'\d+(\.\d{0,2})?'),
                  ),
                ],
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: const OutlineInputBorder(),
                  prefixIcon: SizedBox(
                    width: _fieldIndentWidth,
                    child: const Center(
                      child: Text(
                        '₱',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Visibility customerName(Function setState) {
      return Visibility(
        visible: true,
        child: Container(
          padding: const EdgeInsets.all(1.0),
          decoration: decoAmber(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Label + Checkbox on same row
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              AutoCompleteCustomer(),
            ],
          ),
        ),
      );
    }

    Future<void> saveButtonProcessCash() async {
      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, _selectedFundCode));
      SuppliesHistRepository.instance.setItemUniqueId(_selectedFundCode);
      SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
      SuppliesHistRepository.instance.setCurrentCounter(
          int.parse(customerAmountVar.text.replaceAll(',', '')));
      await _insertToFB();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.yellowAccent,
            title: Text(
              "Salary of Employee",
              textAlign: TextAlign.center,
              style: TextStyle(backgroundColor: Colors.yellowAccent),
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
                      customerAmount(setState),
                      customerName(setState),
                      conRemarksSuppliesVar(setState),
                    ],
                  ),
                ),
              ),
            ),
            // 👇 Bottom buttons
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close popup
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (empNameToId.containsKey(autocompleteSelected.name)) {
                    isGcashCredit = true;
                    await saveButtonProcessCash();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Name must be an employee for Salary Payment.')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  //SHARED METHODS ###########################################################

  int get _grandTotal {
    int total = 0;
    _qtyMap.forEach((denom, qty) {
      total += denom * qty;
    });
    return total;
  }

  Future<void> _insertToFB() async {
    //insert to database
    //save to repository

    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setCustomerId(123); //dummy
    //SuppliesHistRepository.instance.setCustomerName(customerNameVar.text);
    //SuppliesHistRepository.instance.setCustomerName(autocompleteSelected.name);
    SuppliesHistRepository.instance
        .setLogDate(Timestamp.fromDate(DateTime.now()));

    if (await _processTypeOfPay(
        SuppliesHistRepository.instance.suppliesModelHist!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success')),
      );
      print("Sucess");
      SuppliesHistRepository.instance.reset();
      autocompleteSelected = CustomerModel(
          customerId: 0,
          name: '',
          address: '',
          contact: '',
          remarks: '',
          loyaltyCount: 0);
      customerAmountVar.text = "";
      // customerNameVar.text = "";
      remarksSuppliesVar.text = "";
      _selectedFundCode = menuOthUniqIdCashIn;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot Save')),
      );
      print("Failed");
    }
  }

  //insert new Supplies
  Future<bool> _processTypeOfPay(SuppliesModelHist sMH) async {
    //if cashout or funds out, make current counter negative
    if (ifMenuUniqueIsCashOut(sMH) ||
        ifMenuUniqueIsFundsOut(sMH) ||
        (isGcashCredit && sMH.itemUniqueId == menuOthUniqIdCashIn)) {
      sMH.currentCounter = sMH.currentCounter * -1;
    }

    // ##### insert to Employee Current if Funds Out and name exists in nameMap ######
    // checking
    // 1. name exists in nameMap
    //    * itemUniqueId is Funds Out
    //    * exclude Ket and DonF employee record for admin
    //    * isGcashCredit and itemUniqueId is Cash In
    //    * isAdmin and itemUniqueId is Salary Payment
    if (sMH.customerName != "") {
      if (nameMap[sMH.customerName.toLowerCase()] !=
                  null //check if employee exists
              &&
              (sMH.itemUniqueId == menuOthUniqIdFundsOut || //funds out employee
                  (isGcashCredit &&
                      sMH.itemUniqueId == menuOthUniqIdCashIn) //gcash credit
                  ||
                  ((isAdmin || allowPayment) &&
                      sMH.itemUniqueId ==
                          menuOthSalaryPayment) //salary payment access by admin only
              ) &&
              (sMH.customerName != 'Ket' &&
                  sMH.customerName !=
                      'DonF') //exclude employee record for admin
          ) {
        //############### start insert to Employee Current #################
        //get empId from nameMap
        final tempEmpId = empNameToId[sMH.customerName];

        DatabaseEmployeeCurrent databaseEmployeeCurrent =
            DatabaseEmployeeCurrent();

        //insert to Employee Current
        if (await databaseEmployeeCurrent.addEmployeeCurr(EmployeeModel(
          empId: tempEmpId!,
          docId: "",
          countId: 0,
          currentCounter: sMH.currentCounter,
          currentStocks: 0,
          itemId: sMH.itemId,
          itemUniqueId: sMH.itemUniqueId,
          logDate: sMH.logDate,
          logBy: empIdGlobal,
          empName: sMH.customerName,
          remarks: '${sMH.itemName} ${sMH.remarks}',
        ))) {
          debugPrint("Employee Current updated...");
          //prevent generating another record in Supplies Current
          if (isGcashCredit ||
              ((isAdmin || allowPayment) &&
                  sMH.itemUniqueId == menuOthSalaryPayment)) {
            isGcashCredit = false;
            return true;
          }
        } else {
          debugPrint("Employee Current failed to update...");
          //prevent generating another record in Supplies Current
          if (isGcashCredit ||
              ((isAdmin || allowPayment) &&
                  sMH.itemUniqueId == menuOthSalaryPayment)) {
            isGcashCredit = false;
            return false;
          }
        }
        //############### end insert to Employee Current #################
      }
    }

    //this will insert to Supplies History first then Supplies Current
    //if exists in Supplies Current, it will update
    //if not exists, it will add new record in Supplies Current
    DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
    return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
    // return false;
  }
}
