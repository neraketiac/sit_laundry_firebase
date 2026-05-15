import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/pages/body/JobsCompleted/readDataJobsCompleted.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/showReceipt.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminJob.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/autocompletecustomer.dart';

import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visIconArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visNameArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnpaidArea.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';

Widget readDataJobsDone(VoidCallback dialogSetState) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();

  Future<void> sortOriginal(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(originalJobsDone);

    selectedCustomerIdCompleted = 0;
    selectedPickDate = null;

    sortedJobsCompleted.clear();
    lastCompletedDoc = null;
    hasMoreCompleted = true;

    dialogSetState();
  }

  Future<void> sortByCalendar(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? selected;

    void sortJobsByDay(DateTime selectedDay) {
      sortedJobsDone
        ..clear()
        ..addAll(
          originalJobsDone.where((job) {
            final d = job.dateD.toDate();

            return d.year == selectedDay.year &&
                d.month == selectedDay.month &&
                d.day == selectedDay.day;
          }),
        );

      selectedCustomerIdCompleted = 0;
      selectedPickDate = selectedDay;

      sortedJobsCompleted.clear();
      lastCompletedDoc = null;
      hasMoreCompleted = true;

      dialogSetState();
    }

    selected = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Container(
            color: isDark ? const Color(0xFF1E1E1E) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.today),
                  title: const Text("Today"),
                  onTap: () => Navigator.pop(
                      context, DateTime(now.year, now.month, now.day)),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Yesterday"),
                  onTap: () => Navigator.pop(
                    context,
                    DateTime(now.year, now.month, now.day - 1),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Pick Date"),
                  onTap: () async {
                    Navigator.pop(context);

                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      sortJobsByDay(picked);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      sortJobsByDay(selected);
    }
  }

  Future<void> sortClothesStillInHere(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(sortedJobsDoneClothesHere);

    dialogSetState();
  }

  Future<void> sortClothesToBeDelivered(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(sortedJobsDoneClothesHereToBeDelivered);

    dialogSetState();
  }

  Future<void> sortNoticeCash(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(sortedJobsDoneClothesGoneCash);

    dialogSetState();
  }

  Future<void> sortAdminRequest(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(sortedJobsDoneAdminRequest);

    dialogSetState();
  }

  Future<void> sortNoticeGCash(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(sortedJobsDoneClothesGoneGCash);

    dialogSetState();
  }

  Future<void> sortNoticeGCashWithSS(BuildContext context) async {
    sortedJobsDone
      ..clear()
      ..addAll(
        originalJobsDone.where(
          (job) =>
              job.unpaid &&
              job.paidGCash &&
              (job.isCustomerPickedUp || job.isDeliveredToCustomer) &&
              job.gcashReceiptUrl.isNotEmpty,
        ),
      );

    dialogSetState();
  }

  Future<void> showSearchDialog(
    BuildContext context,
  ) async {
    // Check for updated loyalty data before opening search
    await CustomerRepository.instance.loadOnce();

    JobModelRepository jobRepox = JobModelRepository();
    jobRepox.reset();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Find by Customer ID"),
          content: AutoCompleteCustomer(
            jobRepo: jobRepox,
            dialogSetState: dialogSetState,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                int totalUnpaid = 0;
                int totalCashAmount = 0;
                int totalGCashAmount = 0;
                final moneyFormatter = NumberFormat("#,##0.00");

                /// apply filter

                sortedJobsDone
                  ..clear()
                  ..addAll(
                    originalJobsDone.where(
                      (job) => job.customerId == jobRepox.selectedCustomerId,
                    ),
                  );

                selectedCustomerIdCompleted = jobRepox.selectedCustomerId;
                selectedPickDate = null;

                sortedJobsCompleted.clear();
                lastCompletedDoc = null;
                hasMoreCompleted = true;

                dialogSetState();

                /// close first dialog
                Navigator.pop(context);

                /// show selected customer message
                if (sortedJobsDone.length > 1) {
                  totalUnpaid = sortedJobsDone.fold(
                      0, (sum, job) => sum + job.finalPrice);

                  totalCashAmount = sortedJobsDone.fold(
                      0, (sum, job) => sum + job.paidCashAmount);

                  totalGCashAmount = sortedJobsDone
                      .where((job) => job.paidGCashverified == true)
                      .fold(0, (sum, job) => sum + job.paidGCashAmount);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final balance =
                          totalUnpaid - (totalCashAmount + totalGCashAmount);
                      return AlertDialog(
                        title: Text(
                          "Customer Balance",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                        content: Text(
                          "Total unpaid: ₱${moneyFormatter.format(balance)}",
                          style: TextStyle(
                            color: balance > 0
                                ? Colors.red.shade400
                                : Colors.green.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  return StreamBuilder<List<JobModel>>(
    stream: databaseJobsDone.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading jobs'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      /// 🔥 Sync Firestore → original + sorted
      if (originalJobsDone.length != snapshot.data!.length) {
        originalJobsDone
          ..clear()
          ..addAll(snapshot.data!);
        FsUsageTracker.instance
            .track('readDataJobsDone', snapshot.data!.length);

        sortedJobsDone
          ..clear()
          ..addAll(originalJobsDone);

        sortedJobsDoneClothesGoneCash
          ..clear()
          ..addAll(
            originalJobsDone.where(
              (job) =>
                  job.unpaid &&
                  !job.paidGCash &&
                  (job.isCustomerPickedUp || job.isDeliveredToCustomer),
            ),
          );

        sortedJobsDoneClothesGoneGCash
          ..clear()
          ..addAll(
            originalJobsDone.where(
              (job) =>
                  job.unpaid &&
                  job.paidGCash &&
                  (job.isCustomerPickedUp || job.isDeliveredToCustomer),
            ),
          );

        sortedJobsDoneClothesHere
          ..clear()
          ..addAll(
            originalJobsDone.where(
              (job) => !job.isCustomerPickedUp && !job.isDeliveredToCustomer,
            ),
          );

        sortedJobsDoneClothesHereToBeDelivered
          ..clear()
          ..addAll(
            originalJobsDone.where(
              (job) =>
                  job.riderPickup &&
                  !job.isCustomerPickedUp &&
                  !job.isDeliveredToCustomer,
            ),
          );

        intJobsDoneDefault = originalJobsDone.length;
        intJobsDoneClothesHere = sortedJobsDoneClothesHere.length;
        intJobsDoneClothesGoneCash = sortedJobsDoneClothesGoneCash.length;
        intJobsDoneClothesGoneGCash = sortedJobsDoneClothesGoneGCash.length;

        sortedJobsDoneAdminRequest
          ..clear()
          ..addAll(
            originalJobsDone.where((job) => job.requestForAdmin),
          );
        intJobsDoneAdminRequest = sortedJobsDoneAdminRequest.length;
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconBadgeButton(
                    icon: '📶',
                    tooltip: "All Done clothes",
                    badgeCount: intJobsDoneDefault,
                    onPressed: () => sortOriginal(context),
                  ),
                  IconBadgeButton(
                    icon: '👕',
                    tooltip:
                        "Clothes still here (double-tap for to-be-delivered)",
                    badgeCount: intJobsDoneClothesHere,
                    onPressed: () => sortClothesStillInHere(context),
                    onDoubleTap: () => sortClothesToBeDelivered(context),
                  ),
                  IconBadgeButton(
                    icon: '💳',
                    tooltip: "Delivered Pending GCash (double-tap for w/ SS)",
                    badgeCount: intJobsDoneClothesGoneGCash,
                    onPressed: () => sortNoticeGCash(context),
                    onDoubleTap: () => sortNoticeGCashWithSS(context),
                  ),
                  IconBadgeButton(
                    icon: '⚠️',
                    tooltip: "Clothes gone Unpaid",
                    badgeCount: intJobsDoneClothesGoneCash,
                    onPressed: () => sortNoticeCash(context),
                  ),
                  IconBadgeButton(
                    icon: '🙋',
                    tooltip: "Admin request",
                    badgeCount: intJobsDoneAdminRequest,
                    onPressed: () => sortAdminRequest(context),
                  ),
                  IconBadgeButton(
                    icon: '🗓️',
                    tooltip: "Done Clothes Today",
                    onPressed: () => sortByCalendar(context),
                  ),
                  IconBadgeButton(
                    icon: '🔍',
                    tooltip: "Find customer",
                    onPressed: () => showSearchDialog(context),
                  ),
                ],
              ),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(18),
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {});
                },
                children: List.generate(sortedJobsDone.length, (index) {
                  final job = sortedJobsDone[index];
                  JobModelRepository jobRepo = JobModelRepository();
                  jobRepo.setJobModel(job);
                  jobRepo.syncRepoToSelectedAll(jobRepo);

                  final isSelected = selectedIndexDone == index;
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(job.docId),
                    index: index,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onDoubleTap: () {
                          if (isAdmin) {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AdminJobRepoViewer(jobRepo: jobRepo),
                            );
                          }
                        },
                        onTap: () {
                          setState(() {
                            selectedIndexDone = index;
                          });
                          showReceipt(context, jobRepo);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? isDark
                                      ? [
                                          const Color(0xFF4A3F6B),
                                          const Color(0xFF3D3357),
                                        ]
                                      : [
                                          Colors.deepPurple.shade200,
                                          Colors.deepPurple.shade100,
                                        ]
                                  : isDark
                                      ? [
                                          const Color(0xFF2A2535),
                                          const Color(0xFF2A2535),
                                        ]
                                      : [
                                          Colors.deepPurple.shade50,
                                          Colors.deepPurple.shade50,
                                        ],
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.deepPurple
                                      .withValues(alpha: isDark ? 0.6 : 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : isDark
                                      ? Colors.deepPurple.withValues(alpha: 0.3)
                                      : Colors.deepPurple
                                          .withValues(alpha: 0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              visIconArea(
                                context,
                                jobRepo,
                                job,
                                isSelected,
                                false,
                                () async {
                                  showDeliverOrCustomerPickup(context, jobRepo);
                                },
                              ),
                              const SizedBox(width: 7),
                              visNameArea(jobRepo.getJobsModel()!, isSelected),
                              visPaidUnpaidArea(
                                context,
                                jobRepo,
                                isSelected,
                                true,
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      );
    },
  );
}

class IconBadgeButton extends StatelessWidget {
  final String icon;
  final String tooltip;
  final int? badgeCount;
  final VoidCallback onPressed;
  final VoidCallback? onDoubleTap;

  const IconBadgeButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScale.of(context);
    final btnSize = s.isTablet ? 54.0 : 40.0;
    final iconSize = s.isTablet ? 28.0 : 22.0;
    final badgeSize = s.isTablet ? 11.0 : 9.0;

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 22, 198, 84),
        padding: EdgeInsets.zero,
        minimumSize: Size(btnSize, btnSize),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(
              color: Colors.white,
              fontSize: iconSize,
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -4,
              right: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: badgeSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // If onDoubleTap is provided, wrap with GestureDetector for double-tap detection
    // but don't interfere with the button's single-tap handling
    if (onDoubleTap != null) {
      return Tooltip(
        message: tooltip,
        child: GestureDetector(
          onDoubleTap: onDoubleTap,
          child: button,
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: button,
    );
  }
}
