import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/updatedpages/main_laundry_body.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsonqueue_repository.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_current_repository.dart';
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
  late bool _gcashOnly = true;
  static const double _fieldIndentWidth = 40;
  int _fundTypeIndex = 0; // 0=Funds In, 1=Funds Out, 2=Cash In
  TextEditingController customerNameVar = TextEditingController();
  TextEditingController customerNumberVar = TextEditingController();
  TextEditingController customerAmountVar = TextEditingController();

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
    menuOthUniqIdLoad,
    menuOthLaundryPayment
  ];

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;

    JobsOnQueueRepository.instance.loadOnce();
    JobsOnQueueRepository.instance.setCreatedBy(_sEmpId);
    JobsOnQueueRepository.instance.currentEmpId(_sEmpId);
    SuppliesCurrentRepository.instance.reset();
    SuppliesHistRepository.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Text("watata"),
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
              showEnterNewRecord();
            },
            child: const Icon(Icons.g_mobiledata),
          ),
        ],
      ),
    );
  }

  void showEnterNewRecord() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              // "Funds In/Out ${DateTime.now().toString().substring(5, 13)}",
              "Funds In/Out \n ${DateFormat('MMM dd, yyyy h:mm a').format(DateTime.now())}",
              textAlign: TextAlign.center,
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
                      _fundTypeToggle(setState),
                      _laundryCustomer(setState),
                      _customerAmount(setState),
                      _customerName(setState),
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
                  await _saveButtonHeader();
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

  Visibility _fundTypeToggle(Function setState) {
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

  Visibility _laundryCustomer(Function setState) {
    return Visibility(
      visible: !_gcashOnly,
      child: conEnterCustomer(context, setState),
    );
  }

  Visibility _customerName(Function setState) {
    return Visibility(
      visible: _gcashOnly,
      child: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: decoAmber(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Label NOT indented
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // ✅ Input IS indented
            TextFormField(
              controller: customerNameVar,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter Name',
                prefixIcon: SizedBox(width: _fieldIndentWidth),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility _customerAmount(Function setState) {
    return Visibility(
      visible: _gcashOnly,
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

  Future<void> _saveButtonHeader() async {
    //save to repository
    SuppliesHistRepository.instance
        .setCurrentCounter(int.parse(customerAmountVar.text));
    SuppliesHistRepository.instance
        .setItemName(getItemNameOnly(menuOthCashInOutFunds, _selectedFundCode));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setItemUniqueId(_selectedFundCode);
    SuppliesHistRepository.instance.setCustomerId(123); //dummy
    SuppliesHistRepository.instance.setCustomerName(customerNameVar.text);
    SuppliesHistRepository.instance
        .setLogDate(Timestamp.fromDate(DateTime.now()));
    SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);

    //insert to database
    if (await _processTypeOfPay(
        SuppliesHistRepository.instance.suppliesModelHist!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success')),
      );
      print("Sucess");
      SuppliesCurrentRepository.instance.reset();
      customerAmountVar.text = "";
      customerNameVar.text = "";
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
    if (ifMenuUniqueIsCashOut(sMH) | ifMenuUniqueIsFundsOut(sMH)) {
      sMH.currentCounter = sMH.currentCounter * -1;
    }

    DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
    return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  }
}
