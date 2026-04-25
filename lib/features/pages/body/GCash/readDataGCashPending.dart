import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';

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

              final cardBg = isSelected
                  ? (isDark
                      ? Colors.deepPurple.shade900
                      : Colors.deepPurple.shade100)
                  : (isDark ? const Color(0xFF1E1E2E) : Colors.white);
              final borderCol = isSelected
                  ? Colors.deepPurple
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
                                        boxButtonElevated(
                                          context: context,
                                          label: 'Delete',
                                          onPressed: () async {
                                            await dbGCashPending
                                                .deleteVoid(gRepo.getModel()!);
                                            return true;
                                          },
                                        ),
                                      if (isAdmin &&
                                          gRepo.itemUniqueId ==
                                              menuOthUniqIdCashOut &&
                                          gRepo.gCashStatus <= 0.5)
                                        boxButtonElevated(
                                          context: context,
                                          label: 'BigayCashOut',
                                          onPressed: () async {
                                            gRepo.remarks = (gRepo.remarks == ''
                                                ? 'Bigay CashOut'
                                                : '${gRepo.remarks}-BigayCashOut');
                                            gRepo.gCashStatus = 0.75;
                                            await dbGCashPending
                                                .updateVoid(gRepo.getModel()!);
                                            return true;
                                          },
                                        ),
                                      if (gRepo.gCashStatus > 0.5)
                                        boxButtonElevated(
                                          context: context,
                                          label: 'Complete',
                                          onPressed: () async {
                                            // Generate Supplies Hist/Curr for Cash-Out
                                            if (gRepo.itemUniqueId ==
                                                    menuOthUniqIdCashOut &&
                                                gRepo.gCashStatus >= 0.75) {
                                              await _generateCashOutSuppliesRecords(
                                                  gRepo);
                                            }
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
                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: gRepo.customerNumber
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'), '')),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Customer number copied'),
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
