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
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';

void showItemsInOut(BuildContext context) {
  JobModelRepository jobRepo = JobModelRepository();
  jobRepo.reset();

  final otherFirestoreItems = listOthItemsFB
      .where((item) =>
          [670425, 670437, 670439, 670441].contains(item.itemUniqueId))
      .toList();

  // Merge hardcoded shortcuts with Firestore items
  final allShortcuts = [
    ...listOthItemsFB.where((item) => [
          menuFabWKLDValAny8ml,
          menuDetWKL15,
          menuDetArielDVal,
          menuFabDowny36mlDVal,
        ].contains(item.itemId)),
    ...otherFirestoreItems,
  ];

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

    for (var entry in jobRepo.selectedItems.asMap().entries) {
      final idx = entry.key;
      final item = entry.value;
      final key = '${item.itemId}_$idx';

      debugPrint('start');
      debugPrint("item ${item.itemName} type ${item.stocksType}");
      if (item.stocksType == 'php') continue;
      if (excludedSupplyItems.contains(item.itemUniqueId)) continue;

      int qty = int.tryParse(
            jobRepo.itemQtyControllers[key]?.text.trim() ?? "1",
          ) ??
          1;

      int expense = int.tryParse(
            jobRepo.itemExpenseControllers[key]?.text.trim() ?? "0",
          ) ??
          0;

      // Apply negative sign based on checkbox state
      final qtyNegativeKey = '${key}_qty_neg';
      final expenseNegativeKey = '${key}_exp_neg';

      final isQtyNegative = jobRepo.itemNegativeFlags[qtyNegativeKey] ?? true;
      final isExpenseNegative =
          jobRepo.itemNegativeFlags[expenseNegativeKey] ?? false;

      // If checkbox is checked (true), make value negative; if unchecked (false), make value positive
      if (isQtyNegative && qty > 0) {
        qty = -qty;
      } else if (!isQtyNegative && qty < 0) {
        qty = -qty; // make it positive
      }

      if (isExpenseNegative && expense > 0) {
        expense = -expense;
      } else if (!isExpenseNegative && expense < 0) {
        expense = -expense; // make it positive
      }

      sMH.itemName = item.itemName;
      sMH.itemId = item.itemId;
      sMH.itemUniqueId = item.itemUniqueId;
      sMH.currentCounter = qty;
      sMH.expenseAmount = expense;
      sMH.remarks = jobRepo.itemRemarksControllers[key]?.text.trim() ?? '';
      sMH.docId = ''; // reset so each item gets its own SuppliesCurr lookup
      sMH.countId = 0;
      sMH.currentStocks = 0;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // All Shortcuts Section (Merged)
                if (allShortcuts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Quick Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: allShortcuts.length,
                    itemBuilder: (context, index) {
                      final item = allShortcuts[index];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        onPressed: () {
                          jobRepo.selectedItems.add(item);
                          setState(() {});
                        },
                        child: Text(
                          item.itemName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                ],
                // Original Items Section
                visItemsOnly(context, () => setState(() {}), jobRepo),
              ],
            ),
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
