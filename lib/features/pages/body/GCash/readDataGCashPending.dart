import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';

import 'package:laundry_firebase/core/services/database_gcash.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/actions/showUploadedImage.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';

/// Generate Supplies Hist/Curr records for Cash-Out when status >= 0.75
Future<void> _generateCashOutSuppliesRecords(GCashRepository gRepo) async {
  // Only generate for Cash-Out
  if (gRepo.itemUniqueId != menuOthUniqIdCashOut) {
    return;
  }

  // Follow the same pattern as showFundsInFundsOut.dart
  SuppliesHistRepository.instance.setItemName(
      getItemNameOnly(menuOthCashInOutFunds, menuOthUniqIdCashOut));
  SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
  SuppliesHistRepository.instance.setItemUniqueId(menuOthUniqIdCashOut);
  SuppliesHistRepository.instance.setCurrentCounter(gRepo.customerAmount);
  SuppliesHistRepository.instance.setCustomerName(gRepo.customerName);
  SuppliesHistRepository.instance.setCustomerId(0);
  SuppliesHistRepository.instance
      .setRemarks('GCash ${gRepo.itemName} ${gRepo.remarks}');
  // Ensure LogDate uses current timestamp
  SuppliesHistRepository.instance.setLogDate(Timestamp.now());

  // This will go through callDatabaseSuppliesCurrentAdd which applies negation
  await callDatabaseSuppliesCurrentAdd(
      SuppliesHistRepository.instance.suppliesModelHist!);
}

Widget readDataGCashPending() {
  DatabaseGCashPending dbGCashPending = DatabaseGCashPending();
  int? selectedIndex;

  return StreamBuilder<List<GCashModel>>(
    stream: dbGCashPending.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading GCash pending'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final snapshotDatas = snapshot.data!;
      FsUsageTracker.instance
          .track('readDataGCashPending', snapshotDatas.length);

      return StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshotDatas.length,
            itemBuilder: (context, index) {
              final snapshotData = snapshotDatas[index];
              GCashRepository gRepo = GCashRepository();

              gRepo.setModel(snapshotData);

              final progress = 0;
              final isRunning = progress > 0 && progress < 1;
              final isSelected = selectedIndex == index;
              final isDark = Theme.of(context).brightness == Brightness.dark;

              // Different background when Pending Funds In is enabled (isPendingFundsUntilPaid = true)
              // Orange background shows from the start for pending funds, regardless of status
              final isPending = gRepo.isPendingFundsUntilPaid;
              final cardBg = isSelected
                  ? (isDark
                      ? Colors.deepPurple.shade900
                      : Colors.deepPurple.shade100)
                  : isPending
                      ? (isDark
                          ? Colors.orange.shade900.withValues(alpha: 0.3)
                          : Colors.orange.shade500)
                      : (isDark ? const Color(0xFF1E1E2E) : Colors.white);
              final borderCol = isSelected
                  ? Colors.deepPurple
                  : isPending
                      ? (isDark
                          ? Colors.orange.shade700
                          : Colors.orange.shade300)
                      : (isDark
                          ? Colors.deepPurple.shade800
                          : Colors.grey.shade300);
              final primaryText = isSelected
                  ? (isDark ? Colors.deepPurple.shade200 : Colors.deepPurple)
                  : (isDark ? Colors.white : Colors.black87);
              final secondaryText =
                  isDark ? Colors.white60 : Colors.grey.shade600;
              final remarksText =
                  isDark ? Colors.white70 : Colors.grey.shade700;
              final badgeBg = isDark
                  ? Colors.deepPurple.shade900
                  : Colors.deepPurple.shade50;
              final badgeText =
                  isDark ? Colors.deepPurple.shade200 : Colors.deepPurple;
              final amountText =
                  isDark ? Colors.green.shade300 : Colors.green.shade700;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: borderCol, width: isSelected ? 2 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.deepPurple.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 12 : 4,
                          offset: Offset(0, isSelected ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Circle
                          InkWell(
                            onTap: () async {
                              // For Pending Funds In with screenshot attached (status 0.75), show Pay Now dialog directly
                              if (gRepo.isPendingFundsUntilPaid &&
                                  gRepo.gCashStatus == 0.75) {
                                if (!context.mounted) return;
                                final payNow = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pay Now?'),
                                    content: Text(
                                      'Record funds for ${gRepo.customerName} now?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('No'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );

                                if (payNow == true && context.mounted) {
                                  // Record funds now as regular Funds In/Cash In/Load
                                  isGcashCredit = false;

                                  SuppliesHistRepository.instance.setItemName(
                                      getItemNameOnly(menuOthCashInOutFunds,
                                          gRepo.itemUniqueId));
                                  SuppliesHistRepository.instance
                                      .setItemId(menuOthCashInOutFunds);
                                  SuppliesHistRepository.instance
                                      .setItemUniqueId(gRepo.itemUniqueId);
                                  SuppliesHistRepository.instance
                                      .setCurrentCounter(gRepo.customerAmount);
                                  SuppliesHistRepository.instance
                                      .setCustomerName(gRepo.customerName);
                                  SuppliesHistRepository.instance
                                      .setCustomerId(0);
                                  SuppliesHistRepository.instance.setRemarks(
                                      'GCash ${gRepo.itemName} ${gRepo.remarks}');
                                  await setSuppliesRepository(context);

                                  // Set status to 0.85 (Payment done)
                                  gRepo.gCashStatus = 0.85;
                                  await dbGCashPending
                                      .updateVoid(gRepo.getModel()!);
                                }
                                return;
                              }

                              // Cash-Out specific flow
                              if (gRepo.itemUniqueId == menuOthUniqIdCashOut) {
                                // Initial state (0 - 0.75): Admin clicks to show "Pede na I-Bigay ang Cash?"
                                if (gRepo.gCashStatus <= 0.75) {
                                  if (!isAdmin) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Only admin can initiate cash-out'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (!context.mounted) return;
                                  final confirmCashOut = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Pede na I-Bigay ang Cash?'),
                                      content: Text(
                                        'Ready to give cash to ${gRepo.customerName}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmCashOut == true &&
                                      context.mounted) {
                                    gRepo.gCashStatus = 0.85;
                                    await dbGCashPending
                                        .updateVoid(gRepo.getModel()!);
                                  }
                                  return;
                                }

                                // After 0.85: Staff clicks to show "Complete? Naibigay na ang cash."
                                if (gRepo.gCashStatus >= 0.85 &&
                                    gRepo.gCashStatus < 1.0) {
                                  if (!context.mounted) return;
                                  final confirmComplete =
                                      await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Complete?'),
                                      content:
                                          const Text('Naibigay na ang cash.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmComplete == true &&
                                      context.mounted) {
                                    // Generate Cash-Out supplies records and move to done
                                    await _generateCashOutSuppliesRecords(
                                        gRepo);
                                    await moveToNext(gRepo.docId);
                                  }
                                  return;
                                }
                              }

                              // For other cases (Cash-In/Load), show confirmation dialog
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Comfirmation',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    content: Text(
                                      'Select available options.\nTap outside to cancel.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    actions: [
                                      if (gRepo.gCashStatus <= 0.5)
                                        TextButton(
                                          onPressed: () async {
                                            final confirmDelete =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Delete GCash Record',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete this GCash record?\nThis action cannot be undone.',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                      ),
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirmDelete == true) {
                                              await dbGCashPending.deleteVoid(
                                                  gRepo.getModel()!);
                                              if (context.mounted) {
                                                Navigator.pop(context, true);
                                              }
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      // Revert from 0.85 back to 0.75 for Pending Funds In (admin only)
                                      if (isAdmin &&
                                          gRepo.isPendingFundsUntilPaid &&
                                          gRepo.gCashStatus == 0.85)
                                        TextButton(
                                          onPressed: () async {
                                            // Show confirmation dialog
                                            final confirmRevert =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Revert Payment?',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to revert this payment?\n\nThis will automatically add a revert entry in Funds History (SuppliesHist) with a negative amount.',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.orange,
                                                      ),
                                                      child: const Text(
                                                          'Yes, Revert'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirmRevert == true &&
                                                context.mounted) {
                                              // Create negative SuppliesHist record to revert the payment
                                              SuppliesHistRepository.instance
                                                  .setItemName(getItemNameOnly(
                                                      menuOthCashInOutFunds,
                                                      gRepo.itemUniqueId));
                                              SuppliesHistRepository.instance
                                                  .setItemId(
                                                      menuOthCashInOutFunds);
                                              SuppliesHistRepository.instance
                                                  .setItemUniqueId(
                                                      gRepo.itemUniqueId);
                                              // Negative amount to revert
                                              SuppliesHistRepository.instance
                                                  .setCurrentCounter(
                                                      -gRepo.customerAmount);
                                              SuppliesHistRepository.instance
                                                  .setCustomerName(
                                                      gRepo.customerName);
                                              SuppliesHistRepository.instance
                                                  .setCustomerId(0);
                                              SuppliesHistRepository.instance
                                                  .setRemarks(
                                                      'GCash ${gRepo.itemName} ${gRepo.remarks} [REVERTED]');
                                              await setSuppliesRepository(
                                                  context);

                                              // Revert status back to 0.75
                                              gRepo.gCashStatus = 0.75;
                                              await dbGCashPending.updateVoid(
                                                  gRepo.getModel()!);

                                              if (context.mounted) {
                                                Navigator.pop(context, true);
                                              }
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.orange,
                                          ),
                                          child: const Text('Revert Payment'),
                                        ),
                                      if (gRepo.gCashStatus > 0.5)
                                        boxButtonElevated(
                                          context: context,
                                          label: 'Complete',
                                          onPressed: () async {
                                            // For Cash-In/Load: Normal flow - move to done immediately
                                            gRepo.gCashStatus = 1.0;
                                            await moveToNext(gRepo.docId);
                                            return true;
                                          },
                                        ),
                                    ],
                                  );
                                },
                              );

                              if (result == true) {
                                print('User selected YES');
                              } else {
                                print('User selected NO');
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: CircularProgressIndicator(
                                    value: gRepo.gCashStatus,
                                    strokeWidth: 4,
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.deepPurple.shade300,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: isRunning ? 1 : 0,
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.linear,
                                  child: Icon(
                                    Icons.hourglass_bottom_outlined,
                                    color: Colors.deepPurple,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone Number with Copy Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gRepo.customerNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: primaryText,
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () async {
                                          final cleanNumber =
                                              gRepo.customerNumber.replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                          await Clipboard.setData(
                                            ClipboardData(text: cleanNumber),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Copied $cleanNumber ${gRepo.remarks}'),
                                              duration:
                                                  Duration(milliseconds: 800),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.copy,
                                            size: 18,
                                            color: isSelected
                                                ? Colors.deepPurple
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Item Name Badge
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        gRepo.itemName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: badgeText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MM/dd hh:mm a')
                                          .format(gRepo.logDate.toDate()),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: secondaryText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                // Process Progress Indicator
                                if (gRepo.itemUniqueId == menuOthUniqIdCashIn ||
                                    gRepo.itemUniqueId ==
                                        menuOthUniqIdLoad) ...[
                                  const SizedBox(height: 8),
                                  if (gRepo.isPendingFundsUntilPaid)
                                    // 4-step flow for pending funds
                                    Row(
                                      children: [
                                        // Ticket
                                        Text(
                                          'Ticket',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Attach SS
                                        Text(
                                          'Attach SS',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: gRepo
                                                    .cashInImageUrl.isNotEmpty
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : (isDark
                                                    ? Colors.grey.shade600
                                                        .withValues(alpha: 0.5)
                                                    : Colors.grey.shade600
                                                        .withValues(
                                                            alpha: 0.5)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: gRepo
                                                      .cashInImageUrl.isNotEmpty
                                                  ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                  : (isDark
                                                      ? Colors.grey.shade600
                                                      : Colors.grey.shade600),
                                              decoration: gRepo
                                                      .cashInImageUrl.isNotEmpty
                                                  ? TextDecoration.none
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                        // Payment
                                        Text(
                                          'Payment',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: gRepo.gCashStatus >= 0.85
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : (isDark
                                                    ? Colors.grey.shade600
                                                        .withValues(alpha: 0.5)
                                                    : Colors.grey.shade600
                                                        .withValues(
                                                            alpha: 0.5)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: gRepo.gCashStatus >= 0.85
                                                  ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                  : (isDark
                                                      ? Colors.grey.shade600
                                                      : Colors.grey.shade600),
                                              decoration: gRepo.gCashStatus >=
                                                      0.85
                                                  ? TextDecoration.none
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                        // Complete
                                        Text(
                                          'Complete',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    // 3-step flow for normal funds
                                    Row(
                                      children: [
                                        // Ticket + Payment
                                        Text(
                                          'Ticket + Payment',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // SS (Screenshot)
                                        Text(
                                          'Attach SS',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: gRepo
                                                    .cashInImageUrl.isNotEmpty
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : (isDark
                                                    ? Colors.grey.shade600
                                                        .withValues(alpha: 0.5)
                                                    : Colors.grey.shade600
                                                        .withValues(
                                                            alpha: 0.5)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: gRepo
                                                      .cashInImageUrl.isNotEmpty
                                                  ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                  : (isDark
                                                      ? Colors.grey.shade600
                                                      : Colors.grey.shade600),
                                              decoration: gRepo
                                                      .cashInImageUrl.isNotEmpty
                                                  ? TextDecoration.none
                                                  : TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ),
                                        // Complete
                                        Text(
                                          'Complete',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                ] else if (gRepo.itemUniqueId ==
                                    menuOthUniqIdCashOut) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Ticket + SS (always active for status 0-0.75)
                                      Text(
                                        'Ticket + SS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      // Show arrow and next steps only if status >= 0.85
                                      if (gRepo.gCashStatus >= 0.85) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Check SS (active when status >= 0.85)
                                        Text(
                                          'Check SS',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        // Bigay Cash (inactive/grayed when status < 1.0)
                                        Text(
                                          'Bigay Cash',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.grey.shade600
                                                    .withValues(alpha: 0.5)
                                                : Colors.grey.shade600
                                                    .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                                // Customer Name & Remarks
                                if (gRepo.customerName.isNotEmpty ||
                                    gRepo.remarks.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${gRepo.customerName}${gRepo.customerName.isNotEmpty && gRepo.remarks.isNotEmpty ? ": " : ""}${gRepo.remarks}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: remarksText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Date and Time
                                Row(
                                  children: [],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Amount and Image
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱${NumberFormat('#,##0').format(gRepo.customerAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: amountText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              showUploadedImage(
                                context,
                                gRepo,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
