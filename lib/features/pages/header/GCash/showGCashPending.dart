//floating button new record  ###########################################################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerAmount.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerNumber.dart';
import 'package:laundry_firebase/shared/widgets/actions/fundTypeToggle.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

void showGCashPending(BuildContext context) {
  GCashRepository gRepo = GCashRepository();
  final JobModelRepository jobRepo = JobModelRepository();
  jobRepo.reset();

  final List<int> fundTypeCodes1stLayer = [
    menuOthUniqIdCashIn,
    menuOthUniqIdLoad,
    menuOthUniqIdCashOut,
  ];

  if (!fundTypeCodes1stLayer.contains(gRepo.selectedFundCode)) {
    gRepo.selectedFundCode = menuOthUniqIdCashIn;
  }

  // Fee controller — auto-selects on focus
  final feeController = TextEditingController(text: '0');
  final feeFocusNode = FocusNode();
  feeFocusNode.addListener(() {
    if (feeFocusNode.hasFocus) {
      feeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: feeController.text.length,
      );
    }
  });

  // Per-save skip toggle — local only, resets every time dialog opens
  bool skipSuppliesThisSave = false;

  // Deduct from salary toggle — local only, only for staff names
  bool deductFromSalary = false;

  /// Returns true if the typed name is a staff (excluding Ket and DonF)
  bool isStaffSelected() {
    final name = gRepo.customerNameVar.text.trim();
    if (name.isEmpty) return false;
    if (name == 'Ket' || name == 'DonF') return false;
    return empNameToId.containsKey(name);
  }

  Future<void> saveButtonSetRepository() async {
    gRepo.customerNumber = gRepo.customerNumberVar.text;
    gRepo.customerName = gRepo.customerNameVar.text.trim();
    gRepo.itemName =
        getItemNameOnly(menuOthCashInOutFunds, gRepo.selectedFundCode);
    gRepo.itemId = menuOthCashInOutFunds;
    gRepo.itemUniqueId = gRepo.selectedFundCode;
    gRepo.remarks = gRepo.remarksVar.text;
    gRepo.customerAmount =
        int.parse(gRepo.customerAmountVar.text.replaceAll(',', ''));
    gRepo.logDate = Timestamp.now();
    gRepo.logBy = empIdGlobal;

    await callDatabaseGCashPendingAdd(context, gRepo.getModel()!);

    if (deductFromSalary && isStaffSelected()) {
      // Deduct from staff salary — same pattern as showSalaryMaintenance
      // menuOthUniqIdCashIn with isGcashCredit=true triggers employee deduction
      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, menuOthUniqIdCashIn));
      SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
      SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdCashIn);
      SuppliesHistRepository.instance.setCurrentCounter(gRepo.customerAmount);
      SuppliesHistRepository.instance.setCustomerName(gRepo.customerName);
      SuppliesHistRepository.instance.setCustomerId(0);
      SuppliesHistRepository.instance
          .setRemarks('GCash deduct ${gRepo.itemName} ${gRepo.remarks}');
      isGcashCredit = true; // triggers employee balance deduction
      await setSuppliesRepository(context);
    } else if (!skipSuppliesThisSave) {
      // Normal funds recording
      // Cash-in/Load → positive, Cash-out → negative (handled by callDatabaseSuppliesCurrentAdd)
      SuppliesHistRepository.instance.setItemName(
          getItemNameOnly(menuOthCashInOutFunds, gRepo.selectedFundCode));
      SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
      SuppliesHistRepository.instance.setItemUniqueId(gRepo.selectedFundCode);
      SuppliesHistRepository.instance.setCurrentCounter(gRepo.customerAmount);
      SuppliesHistRepository.instance.setCustomerName(gRepo.customerName);
      SuppliesHistRepository.instance.setCustomerId(0);
      SuppliesHistRepository.instance
          .setRemarks('GCash ${gRepo.itemName} ${gRepo.remarks}');
      await setSuppliesRepository(context);

      // Fee record
      final fee = int.tryParse(feeController.text.replaceAll(',', '')) ?? 0;
      if (fee > 0) {
        final feeSMH = SuppliesModelHist(
          docId: '',
          countId: 0,
          itemId: menuOthCashInOutFunds,
          itemUniqueId: menuOthUniqIdFee,
          itemName: 'Gcash Fee',
          currentCounter: fee,
          currentStocks: 0,
          logDate: Timestamp.now(),
          empId: empIdGlobal,
          customerId: 0,
          customerName: gRepo.customerName,
          remarks: gRepo.remarksVar.text,
        );
        await DatabaseSuppliesCurrent().addSuppliesCurr(feeSMH);
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final nameIsStaff = isStaffSelected();

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
          title: const Text(
            "GCash Request",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customerNumber(context, gRepo.customerNumberVar),
                    // Amount
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: customerAmount(context, gRepo.customerAmountVar),
                    ),
                    // Fee input
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          const Text('Fee:',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: feeController,
                              focusNode: feeFocusNode,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '0',
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                        color: Colors.white38)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                        color: Colors.white38)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Customer name — optional, free text + staff autocomplete hint
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Name (optional)',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white70)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: gRepo.customerNameVar,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Enter name or leave blank',
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      const BorderSide(color: Colors.white38)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide:
                                      const BorderSide(color: Colors.white38)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            onChanged: (_) => setState(() {
                              if (!isStaffSelected()) {
                                deductFromSalary = false;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    conRemarks(
                        context, () => setState(() {}), gRepo.remarksVar),
                    fundTypeToggle(
                      () => setState(() {}),
                      fundTypeCodes1stLayer,
                      gRepo,
                    ),
                    // Staff-only: deduct from salary toggle
                    if (nameIsStaff)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enable this, kapag No Funds In.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Ibabawas sa sweldo ni ${gRepo.customerNameVar.text}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black54),
                                ),
                              ],
                            ),
                            Switch(
                              value: deductFromSalary,
                              activeThumbColor: Colors.deepOrange,
                              onChanged: (v) => setState(() {
                                deductFromSalary = v;
                                if (v) skipSuppliesThisSave = false;
                              }),
                            ),
                          ],
                        ),
                      ),
                    // Admin-only: skip funds recording toggle
                    if (isAdmin && !deductFromSalary)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Skip Funds Recording',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),
                            Switch(
                              value: skipSuppliesThisSave,
                              activeThumbColor: Colors.orange,
                              onChanged: (v) =>
                                  setState(() => skipSuppliesThisSave = v),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            boxButtonElevated(
              context: context,
              label: 'Save',
              onPressed: () async {
                if (gRepo.customerAmountVar.text.isEmpty ||
                    int.tryParse(
                            gRepo.customerAmountVar.text.replaceAll(',', '')) ==
                        null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount.')),
                  );
                  return false;
                } else if ((gRepo.selectedFundCode == menuOthUniqIdCashIn ||
                        gRepo.selectedFundCode == menuOthUniqIdLoad) &&
                    gRepo.customerNumberVar.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Phone number is required for Cash-in and Load.')),
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
          ],
        );
      });
    },
  );
}
