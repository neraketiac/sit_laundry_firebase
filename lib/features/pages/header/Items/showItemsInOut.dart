//floating button new record  ###########################################################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/firestore_handler.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
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
    await FsHandler.run(
      context: context,
      operation: () => DatabaseSuppliesCurrent().addItemsCurr(sMH),
      successMessage: 'Saved',
      onRetry: () => callDBCurrHist(context, sMH),
    );
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

      int expense = int.tryParse(
            jobRepo.itemExpenseControllers[item.itemId]?.text ?? "0",
          ) ??
          0;

      sMH.itemName = item.itemName;
      sMH.itemId = item.itemId;
      sMH.itemUniqueId = item.itemUniqueId;
      sMH.currentCounter = qty; //add qty here
      sMH.expenseAmount = expense;

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
          backgroundColor: Colors.blueGrey.shade50,
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
              const SizedBox(width: 8),
              const Text(
                'Inventory Check',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: visItemsOnly(context, () => setState(() {}), jobRepo),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            if (jobRepo.selectedItems.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await saveButtonSetRepository();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
          ],
        );
      });
    },
  );
}
