import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';

import 'package:laundry_firebase/core/services/database_gcash.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/shared/widgets/actions/showUploadedImage.dart';

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

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple.shade100
                          : Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.deepPurple,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
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
                              // USER PRESSED YES
                              print('User selected YES');
                            } else {
                              // USER PRESSED NO or dismissed
                              print('User selected NO');
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  value: gRepo
                                      .gCashStatus, // added imageUrl check for progress value
                                  // removed Tween animation value
                                  strokeWidth: 6,
                                  // backgroundColor:
                                  //     backGroundStatusColor(job),
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.deepPurple.shade300,
                                ),
                              ),
                              AnimatedRotation(
                                turns: isRunning ? 1 : 0,
                                duration: const Duration(seconds: 2),
                                curve: Curves.linear,
                                child: Icon(
                                  // statusIcon(job),
                                  Icons.hourglass_bottom_outlined,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      gRepo.customerNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: gRepo.customerNumber
                                                    .replaceAll(
                                                        RegExp(r'[^0-9]'),
                                                        '') ??
                                                ''),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Customer number copied'),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 3),
                              //Item Name
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (gRepo.itemName),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (gRepo.customerName.isNotEmpty ||
                                  gRepo.remarks.isNotEmpty)
                                const SizedBox(width: 3),
                              //Remarks
                              if (gRepo.customerName.isNotEmpty ||
                                  gRepo.remarks.isNotEmpty)
                                Text(
                                  '${gRepo.customerName}: ${gRepo.remarks}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.black,
                                      fontSize: 10),
                                ),
                              const SizedBox(width: 3),
                              //Date and Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('MM/dd hh:mm a')
                                          .format(gRepo.logDate.toDate()),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          children: [
                            Text(
                              '₱ ${gRepo.customerAmount}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            showUploadedImage(
                              context,
                              gRepo,
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                      ],
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
