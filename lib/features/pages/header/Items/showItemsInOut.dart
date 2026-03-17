//floating button new record  ###########################################################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visItems.dart';

void showItemsInOut(BuildContext context) {
  JobModelRepository jobRepo = JobModelRepository();
  jobRepo.reset();
  const excludedSupplyItems = {
    menuOthWash,
    menuOth2W1DR,
    menuOth2W1DSS,
    menuOthDry,
    menuOth195,
    menuOth165,
    menuOthXD,
    menuOthXW,
    menuOthXR,
    menuOth155,
    menuOth125,
    menuOthDO,
    menuOthDOF,
    menuOthNF155,
    menuOthNF195,
    menuOthNF125,
    menuOthNF165,
    menuOthW8t9,
    menuOthW9t10,
    menuOthW11t12,
    menuOthXS,
    menuOthFree,
    menuOthWD98,
    menuOthUniqIdCashIn,
    menuOthUniqIdCashOut,
    menuOthUniqIdFundsIn,
    menuOthUniqIdFundsOut,
    menuOthLaundryPayment,
    menuOthSalaryPayment,
  };

  Future<void> callDBCurrHist(
      BuildContext context, SuppliesModelHist sMH) async {
    DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
    if (await databaseSuppliesCurrent.addItemsCurr(sMH)) {
      print("Success");
    } else {
      print("Failed");
    }
  }

  Future<void> saveButtonSetRepository() async {
    SuppliesModelHist sMH;
    sMH = SuppliesModelHist(
      docId: '',
      countId: 0,
      itemId: 0,
      itemUniqueId: 0,
      itemName: '',
      currentCounter: 0,
      currentStocks: 0,
      logDate: timestamp1900,
      empId: empIdGlobal,
      customerId: 0,
      customerName: '',
      remarks: '',
    );

    for (var item in jobRepo.selectedItems) {
      debugPrint('start');
      debugPrint("item ${item.itemName} type ${item.stocksType}");
      //only items, php should be in funds in/out
      if (item.stocksType == 'php') continue;
      //other items to exclude
      if (excludedSupplyItems.contains(item.itemUniqueId)) continue;

      /// get qty from textbox
      int qty = int.tryParse(
            jobRepo.itemQtyControllers[item.itemId]?.text ?? "1",
          ) ??
          1;

      sMH.itemName = item.itemName;
      sMH.itemId = item.itemId;
      sMH.itemUniqueId = item.itemUniqueId;
      sMH.currentCounter = qty; //add qty here

      sMH.customerId = 123; //dummy
      sMH.logDate = (Timestamp.fromDate(DateTime.now()));
      debugPrint('end');
      await callDBCurrHist(context, sMH);
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: cFundsInFundsOut,
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
            "Items In/Out",
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
                    visItemsOnly(context, () => setState(() {}), jobRepo)
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
                Navigator.pop(dialogContext); // close popup
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            if (jobRepo.selectedItems.isNotEmpty)
              boxButtonElevated(
                  context: context,
                  label: 'Save',
                  onPressed: () async {
                    await saveButtonSetRepository();
                    // Don't call Navigator.pop here - let the button handler do it
                    return true;
                  }),
          ],
        );
      });
    },
  );
}
