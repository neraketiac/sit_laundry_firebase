//floating button new record  ###########################################################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerAmount.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerNameGCash.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerNumber.dart';
import 'package:laundry_firebase/shared/widgets/actions/fundTypeToggle.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

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

  Future<void> saveButtonSetRepository() async {
    gRepo.customerNumber = gRepo.customerNumberVar.text;
    gRepo.customerName = gRepo.customerNameVar.text;
    //.replaceAll(RegExp(r'[^0-9]'), '');

    gRepo.itemName =
        (getItemNameOnly(menuOthCashInOutFunds, gRepo.selectedFundCode));
    gRepo.itemId = (menuOthCashInOutFunds);
    gRepo.itemUniqueId = (gRepo.selectedFundCode);
    gRepo.remarks = (gRepo.remarksVar.text);
    gRepo.customerAmount =
        int.parse(gRepo.customerAmountVar.text.replaceAll(',', ''));
    gRepo.logDate = Timestamp.now();
    gRepo.logBy = empIdGlobal;

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
                    customerNumber(context, gRepo.customerNumberVar),
                    customerAmount(context, gRepo.customerAmountVar),
                    customerNameGCash(context, gRepo.customerNameVar),
                    conRemarks(
                        context, () => setState(() {}), gRepo.remarksVar),
                    fundTypeToggle(
                      () => setState(() {}),
                      fundTypeCodes1stLayer,
                      gRepo,
                    ),
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
            boxButtonElevated(
              context: context,
              label: 'Save',
              onPressed: () async {
                if (gRepo.customerAmountVar.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount.')),
                  );
                  return false;
                } else if (fundTypeCodes1stLayer
                    .contains(gRepo.selectedFundCode)) {
                  await saveButtonSetRepository();
                  return true;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select transaction type.')),
                  );
                  return false;
                }
              },
            ),
            // ElevatedButton(
            //   onPressed: () async {
            //     if (gRepo.customerAmountVar.text == '') {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Please enter amount.')),
            //       );
            //     } else if (gRepo.selectedFundCode == null) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //             content: Text('Please select transaction type.')),
            //       );
            //     } else {
            //       if (fundTypeCodes1stLayer.contains(gRepo.selectedFundCode)) {
            //         await saveButtonSetRepository();
            //         Navigator.pop(context);
            //       } else {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(
            //               content: Text('Please select transaction type.')),
            //         );
            //       }
            //     }
            //   },
            //   child: const Text('Save'),
            // ),
          ],
        );
      });
    },
  );
}
