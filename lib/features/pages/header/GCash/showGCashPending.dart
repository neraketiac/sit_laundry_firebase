//floating button new record  ###########################################################
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerAmount.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerNumber.dart';
import 'package:laundry_firebase/shared/widgets/actions/fundTypeToggle.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/actions/showUploadedImage.dart';

void showGCashPending(BuildContext context) async {
  GCashRepository gRepo = GCashRepository();

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

  // Pending Funds In toggle — local only, only for staff names
  bool pendingFundsUntilPaid = false;

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
    gRepo.isPendingFundsUntilPaid = pendingFundsUntilPaid;

    // If CashOut and picture is uploaded, set status to 0.75
    final isCashOut = gRepo.selectedFundCode == menuOthUniqIdCashOut;
    if (isCashOut && gRepo.cashOutImageUrl.isNotEmpty) {
      gRepo.gCashStatus = 0.75;
    }

    await callDatabaseGCashPendingAdd(context, gRepo.getModel()!);

    // Only generate Supplies Hist/Curr for Cash-In and Load, NOT for Cash-Out
    final isCashOutTransaction = gRepo.selectedFundCode == menuOthUniqIdCashOut;

    if (!isCashOutTransaction) {
      // If Pending Funds In, skip funds recording (will be done in readDataGCashPending)
      if (pendingFundsUntilPaid && isStaffSelected()) {
        // Skip funds recording - will be done when status moves to next and user confirms "Pay Now?"
        return;
      } else if (!skipSuppliesThisSave) {
        // Normal funds recording for Cash-In and Load
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
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final nameIsStaff = isStaffSelected();
        final s = AppScale.of(context);

        final isCashOut = gRepo.selectedFundCode == menuOthUniqIdCashOut;

        return Dialog(
          backgroundColor: Colors.lightBlue,
          insetPadding: EdgeInsets.symmetric(
            horizontal: s.isTablet ? 40 : 40,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: s.isTablet ? 600 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "GCash Request",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: s.isTablet ? 18 : 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blueAccent, width: 2.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Fund Type toggle
                          fundTypeToggle(
                            () => setState(() {}),
                            fundTypeCodes1stLayer,
                            gRepo,
                          ),

                          // 6.5 Picture Upload (only for Cash-Out)
                          if (isCashOut)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Upload Receipt Picture',
                                      style: TextStyle(
                                          fontSize: s.small,
                                          color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: showUploadedImage(
                                      context,
                                      gRepo,
                                      onImageUploaded: () => setState(() {}),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),

                          // 2. Customer Number field
                          customerNumber(context, gRepo.customerNumberVar),

                          // 3. Amount field (wrapped in Padding horizontal: 8)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: customerAmount(
                                context, gRepo.customerAmountVar),
                          ),

                          // 4. Fee field (Row with "Fee:" label + TextField, scaled with s.body)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Text('Fee:',
                                    style: TextStyle(
                                        fontSize: s.body,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: feeController,
                                    focusNode: feeFocusNode,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: s.body, color: Colors.white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: '0',
                                      hintStyle: const TextStyle(
                                          color: Colors.white54),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.white38)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.white38)),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: s.gapSmall + 4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 5. Name field (only visible if NOT Cash-out) — plain TextField, optional, with staff name chips below
                          if (!isCashOut)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name (optional)',
                                      style: TextStyle(
                                          fontSize: s.small,
                                          color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: gRepo.customerNameVar,
                                    style: TextStyle(
                                        fontSize: s.body, color: Colors.white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter name or leave blank',
                                      hintStyle: const TextStyle(
                                          color: Colors.white38),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.white38)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: const BorderSide(
                                              color: Colors.white38)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {
                                      if (!isStaffSelected()) {
                                        pendingFundsUntilPaid = false;
                                      }
                                    }),
                                  ),
                                  // Staff name quick-select buttons
                                  if (empNameToId.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: empNameToId.keys
                                          .where(
                                              (n) => n != 'Ket' && n != 'DonF')
                                          .map((name) => GestureDetector(
                                                onTap: () => setState(() {
                                                  gRepo.customerNameVar.text =
                                                      name;
                                                  if (!isStaffSelected()) {
                                                    pendingFundsUntilPaid =
                                                        false;
                                                  }
                                                }),
                                                child: Chip(
                                                  label: Text(name,
                                                      style: TextStyle(
                                                          fontSize: s.small)),
                                                  backgroundColor: gRepo
                                                              .customerNameVar
                                                              .text ==
                                                          name
                                                      ? Colors
                                                          .deepOrange.shade400
                                                      : Colors.white24,
                                                  labelStyle: const TextStyle(
                                                      color: Colors.white),
                                                  padding: EdgeInsets.zero,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          // 6. Remarks / Notes / GCash Reference No field
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Remarks / Notes / GCash Reference No',
                                    style: TextStyle(
                                        fontSize: s.small,
                                        color: Colors.white70)),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: gRepo.remarksVar,
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: s.body, color: Colors.white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText:
                                        'Enter remarks, notes, or GCash reference number',
                                    hintStyle:
                                        const TextStyle(color: Colors.white38),
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
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),

                          // 7. "Pending Funds In" toggle (only visible if NOT Cash-out AND name is staff)
                          if (!isCashOut && nameIsStaff)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pending Funds In',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Pause funds recording for ${gRepo.customerNameVar.text}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: pendingFundsUntilPaid,
                                    activeThumbColor: Colors.deepOrange,
                                    onChanged: (v) => setState(() {
                                      pendingFundsUntilPaid = v;
                                      if (v) skipSuppliesThisSave = false;
                                    }),
                                  ),
                                ],
                              ),
                            ),

                          // 7.5 Procedure display when pending funds is enabled
                          if (!isCashOut &&
                              nameIsStaff &&
                              pendingFundsUntilPaid)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Procedure:',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Ticket',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          '>',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Attach SS',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          '>',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Payment',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepOrange.shade700,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          '>',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Complete',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '• Ticket (by Staff) • Attach SS (by Ket) • Payment (by Staff) • Complete (by Staff/Ket)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 8. "Skip Funds Recording" toggle (only visible if admin AND NOT pendingFundsUntilPaid AND NOT Cash-out)
                          if (isAdmin && !pendingFundsUntilPaid && !isCashOut)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Skip Funds Recording',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                  Switch(
                                    value: skipSuppliesThisSave,
                                    activeThumbColor: Colors.orange,
                                    onChanged: (v) => setState(
                                        () => skipSuppliesThisSave = v),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                              int.tryParse(gRepo.customerAmountVar.text
                                      .replaceAll(',', '')) ==
                                  null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter amount.')),
                            );
                            return false;
                          } else if ((gRepo.selectedFundCode ==
                                      menuOthUniqIdCashIn ||
                                  gRepo.selectedFundCode ==
                                      menuOthUniqIdLoad) &&
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
                                  content:
                                      Text('Please select transaction type.')),
                            );
                            return false;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
