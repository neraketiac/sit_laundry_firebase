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
import 'package:laundry_firebase/core/widgets/calculator.dart';
import 'package:laundry_firebase/core/widgets/fee_reference_table.dart';

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

  // Fee reference data
  final feeReferenceData = [
    {'min': 1, 'max': 100, 'fee': 5},
    {'min': 101, 'max': 500, 'fee': 10},
    {'min': 501, 'max': 750, 'fee': 15},
    {'min': 751, 'max': 1000, 'fee': 20},
    {'min': 1001, 'max': 1500, 'fee': 30},
    {'min': 1501, 'max': 2000, 'fee': 40},
    {'min': 2001, 'max': 2500, 'fee': 50},
    {'min': 2501, 'max': 3000, 'fee': 60},
    {'min': 3001, 'max': 3500, 'fee': 70},
    {'min': 3501, 'max': 4000, 'fee': 80},
    {'min': 4001, 'max': 4500, 'fee': 90},
    {'min': 4501, 'max': 5000, 'fee': 100},
    {'min': 5001, 'max': 5500, 'fee': 110},
    {'min': 5501, 'max': 6000, 'fee': 120},
    {'min': 6001, 'max': 6500, 'fee': 130},
    {'min': 6501, 'max': 7000, 'fee': 140},
    {'min': 7001, 'max': 7500, 'fee': 150},
    {'min': 7501, 'max': 8000, 'fee': 160},
    {'min': 8001, 'max': 8500, 'fee': 170},
    {'min': 8501, 'max': 9000, 'fee': 180},
    {'min': 9001, 'max': 9500, 'fee': 190},
    {'min': 9501, 'max': 10000, 'fee': 200},
  ];

  /// Calculate fee based on amount
  int calculateFeeFromAmount(int amount) {
    for (var range in feeReferenceData) {
      final min = range['min'] as int;
      final max = range['max'] as int;
      if (amount >= min && amount <= max) {
        return range['fee'] as int;
      }
    }
    return 0;
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

  // Add listener to amount field to auto-calculate fee
  gRepo.customerAmountVar.addListener(() {
    final amount =
        int.tryParse(gRepo.customerAmountVar.text.replaceAll(',', '')) ?? 0;
    if (amount > 0) {
      final calculatedFee = calculateFeeFromAmount(amount);
      feeController.text = calculatedFee.toString();
    }
  });

  // Per-save skip toggle — local only, resets every time dialog opens
  bool skipSuppliesThisSave = false;

  // Pending Funds In toggle — local only, only for staff names
  bool pendingFundsUntilPaid = false;

  // Toggle state for staff buttons visibility — must be outside StatefulBuilder
  bool showStaffButtons = false;

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
        final s = AppScale.of(context);
        final isCashOut = gRepo.selectedFundCode == menuOthUniqIdCashOut;

        // Calculate nameIsStaff fresh on every build
        final nameIsStaff = isStaffSelected();

        // Scroll controller for auto-scrolling to focused fields
        final scrollController = ScrollController();

        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        // Setup amount field listener for auto-calculating fee
        // Remove old listener if exists
        gRepo.customerAmountVar.removeListener(() {});

        // Add new listener that respects pendingFundsUntilPaid
        gRepo.customerAmountVar.addListener(() {
          if (!pendingFundsUntilPaid) {
            final amount = int.tryParse(
                    gRepo.customerAmountVar.text.replaceAll(',', '')) ??
                0;
            if (amount > 0) {
              final calculatedFee = calculateFeeFromAmount(amount);
              feeController.text = calculatedFee.toString();
            }
          } else {
            // If pending funds, set fee to 0
            feeController.text = '0';
          }
        });

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
                // Title with Toggle Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GCash Request",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: s.isTablet ? 18 : 15,
                            fontWeight: FontWeight.bold),
                      ),
                      // Toggle staff buttons visibility
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() {
                            showStaffButtons = !showStaffButtons;
                          }),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                showStaffButtons
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: keyboardHeight),
                      child: Container(
                        padding: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.blueAccent, width: 2.0)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Fund Type toggle
                            fundTypeToggle(
                              () => setState(() {}),
                              fundTypeCodes1stLayer,
                              gRepo,
                              showProcedureLabel: showStaffButtons,
                            ),

                            // 2.5 Picture Upload (for all transaction types)
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
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),

                            // 3. Mobile Number - center alignment
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: customerNumber(
                                        context, gRepo.customerNumberVar),
                                  ),
                                ],
                              ),
                            ),

                            // 4. Amount - center alignment
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: customerAmount(
                                        context, gRepo.customerAmountVar),
                                  ),
                                ],
                              ),
                            ),

                            // 5. Name (optional) - center alignment
                            if (!isCashOut)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Name for Cash -in (optional)',
                                        style: TextStyle(
                                            fontSize: s.small,
                                            color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    TextField(
                                      textAlign: TextAlign.center,
                                      controller: gRepo.customerNameVar,
                                      style: TextStyle(
                                          fontSize: s.body,
                                          color: Colors.white),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Enter name or leave blank',
                                        hintStyle: const TextStyle(
                                            color: Colors.white38),
                                        filled: true,
                                        fillColor:
                                            Colors.black.withOpacity(0.25),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: Colors.white
                                                    .withOpacity(0.2))),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: Colors.white
                                                    .withOpacity(0.2))),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: BorderSide(
                                                color: Colors.white
                                                    .withOpacity(0.4))),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                      ),
                                      onChanged: (_) => setState(() {
                                        // Trigger rebuild to update procedure visibility
                                        if (!isStaffSelected()) {
                                          pendingFundsUntilPaid = false;
                                        }
                                      }),
                                    ),
                                    // Staff name quick-select buttons (hidden by default)
                                    if (empNameToId.isNotEmpty &&
                                        showStaffButtons) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: empNameToId.keys
                                            .where((n) =>
                                                n != 'Ket' && n != 'DonF')
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
                                                        : Colors.deepOrange
                                                            .shade200,
                                                    labelStyle: TextStyle(
                                                      color:
                                                          gRepo.customerNameVar
                                                                      .text ==
                                                                  name
                                                              ? Colors.white
                                                              : Colors.black87,
                                                    ),
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

                            // 6. Staff buttons (hidden by default)
                            if (showStaffButtons && !isCashOut)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Staff Actions',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    // Staff buttons content would go here
                                  ],
                                ),
                              ),

                            // 6.5 Procedure display - show after staff buttons when staff name selected
                            if (showStaffButtons && !isCashOut && nameIsStaff)
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

                            // 7. Remarks / Notes / GCash Reference No - center alignment
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Network / Load Name / Notes (Optional)',
                                      style: TextStyle(
                                          fontSize: s.small,
                                          color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: gRepo.remarksVar,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: s.body, color: Colors.white),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText:
                                          'Enter remarks, notes, or GCash reference number',
                                      hintStyle: const TextStyle(
                                          color: Colors.white38),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.25),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.2))),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.4))),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),

                            // 8. Fee: [fee input field] [fee button] [calc button]
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Fee:',
                                          style: TextStyle(
                                              fontSize: s.body,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                '₱',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.greenAccent,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: feeController,
                                                  focusNode: feeFocusNode,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: s.body,
                                                      color: Colors.white),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: '0',
                                                    hintStyle: const TextStyle(
                                                        color: Colors.white54),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Calculator button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            final amount = int.tryParse(gRepo
                                                    .customerAmountVar.text
                                                    .replaceAll(',', '')) ??
                                                0;
                                            final fee = int.tryParse(
                                                    feeController.text
                                                        .replaceAll(',', '')) ??
                                                0;
                                            showCalculator(
                                              context,
                                              initialAmount: amount,
                                              initialFee: fee,
                                              onClose: (customerCash, newAmount,
                                                  newFee) {
                                                // Update amount and fee fields with new values
                                                if (newAmount > 0) {
                                                  gRepo.customerAmountVar.text =
                                                      newAmount.toString();
                                                }
                                                if (newFee > 0) {
                                                  feeController.text =
                                                      newFee.toString();
                                                }
                                                // Append customer cash to remarks
                                                if (customerCash.isNotEmpty) {
                                                  final currentRemarks = gRepo
                                                      .remarksVar.text
                                                      .trim();
                                                  if (currentRemarks.isEmpty) {
                                                    gRepo.remarksVar.text =
                                                        'Sukli: ₱$customerCash';
                                                  } else {
                                                    gRepo.remarksVar.text =
                                                        '$currentRemarks | Sukli: ₱$customerCash';
                                                  }
                                                }
                                              },
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.deepOrange.shade400,
                                            ),
                                            child: const Icon(
                                              Icons.calculate,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Fee Reference Table button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            showFeeReferenceTable(
                                              context,
                                              onFeeSelected: (selectedFee) {
                                                feeController.text =
                                                    selectedFee;
                                              },
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.blue.shade700,
                                            ),
                                            child: const Text(
                                              'Fee',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // 9. Pending Funds In toggle (only visible if NOT Cash-out AND name is staff)
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
                                          'Enable, wala munang Funds In',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'Pending ni ${gRepo.customerNameVar.text} ang Funds In(Staff Only).',
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
                                        if (v) {
                                          skipSuppliesThisSave = false;
                                          // If pending funds, set fee to 0
                                          feeController.text = '0';
                                        } else {
                                          // If not pending, recalculate fee based on amount
                                          final amount = int.tryParse(gRepo
                                                  .customerAmountVar.text
                                                  .replaceAll(',', '')) ??
                                              0;
                                          if (amount > 0) {
                                            final calculatedFee =
                                                calculateFeeFromAmount(amount);
                                            feeController.text =
                                                calculatedFee.toString();
                                          }
                                        }
                                      }),
                                    ),
                                  ],
                                ),
                              ),

                            // 10. Skip Funds Recording toggle (only visible if admin AND NOT pendingFundsUntilPaid AND NOT Cash-out)
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

                            // 12. Buttons
                          ],
                        ),
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
                          } else if (isCashOut &&
                              gRepo.cashOutImageUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Receipt picture is required for Cash-Out.')),
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
