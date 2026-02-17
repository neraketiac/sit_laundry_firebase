//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

void showGCashPending(BuildContext context) {
  GCashRepository gRepo = GCashRepository();
  final List<int> fundTypeCodes1stLayer = [
    menuOthUniqIdCashIn,
    menuOthUniqIdLoad,
    menuOthUniqIdCashOut,
  ];

  if (fundTypeCodes1stLayer.contains(gRepo.selectedFundCode)) {
  } else {
    gRepo.selectedFundCode = menuOthUniqIdCashIn;
  }

  String captionHere(int value) {
    switch (value) {
      case menuOthLaundryPayment:
        return 'Bayad sa pina-laundry.\nadd funds';
      case menuOthUniqIdCashIn:
        return 'Bayad sa pa-cash-in.\nadd funds\nuse funds-in for employee';
      case menuOthUniqIdLoad:
        return 'Bayad sa pina-load.\nadd funds\n';
      case menuOthUniqIdCashOut:
        return 'Pa-cash-out si customer.\nbawas funds\nuse funds-out for employee';
      default:
        return '';
    }
  }

  Future<void> saveButtonSetRepository() async {
    gRepo.customerName = gRepo.customerNameVar.text;
    //.replaceAll(RegExp(r'[^0-9]'), '');

    gRepo.itemName =
        (getItemNameOnly(menuOthCashInOutFunds, gRepo.selectedFundCode));
    gRepo.itemId = (menuOthCashInOutFunds);
    gRepo.itemUniqueId = (gRepo.selectedFundCode);
    gRepo.remarks = (gRepo.remarksVar.text);
    gRepo.currentCounter =
        int.parse(gRepo.customerAmountVar.text.replaceAll(',', ''));

    await callDatabaseGCashPendingAdd(context, gRepo.getModel()!);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          contentPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.only(
            top: 0,
            left: 5,
            right: 5,
            bottom: 0,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          title: Text(
            "GCash Request",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customerNumber(context, setState, gRepo.customerNameVar),
                    conRemarksGcash(context, setState, gRepo.remarksVar),
                    customerAmount(context, setState, gRepo.customerAmountVar),
                    fundTypeToggle(setState, fundTypeCodes1stLayer, gRepo,
                        captionHere(gRepo.selectedFundCode)),
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (gRepo.customerAmountVar.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount.')),
                  );
                } else if (gRepo.selectedFundCode == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select transaction type.')),
                  );
                } else {
                  if (fundTypeCodes1stLayer.contains(gRepo.selectedFundCode)) {
                    await saveButtonSetRepository();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select transaction type.')),
                    );
                  }
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
