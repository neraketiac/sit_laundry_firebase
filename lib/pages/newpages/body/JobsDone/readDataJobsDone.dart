import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/showDeliverOrCustomerPickup.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/showReceipt.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/subAdmin/showAdminJob.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

Widget readDataJobsDone(Function setState) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();

  Future<void> sortOriginal(BuildContext context) async {
    setState(() {
      sortedJobsDone
        ..clear()
        ..addAll(originalJobsDone);
      sortedJobsCompleted
        ..clear()
        ..addAll(originalJobsCompleted);
    });
  }

  Future<void> sortByCalendar(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? selected;

    void sortJobsByDay(DateTime selectedDay) {
      setState(() {
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

        sortedJobsCompleted
          ..clear()
          ..addAll(
            originalJobsCompleted.where((job) {
              final d = job.dateD.toDate();

              return d.year == selectedDay.year &&
                  d.month == selectedDay.month &&
                  d.day == selectedDay.day;
            }),
          );
      });
    }

    selected = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        return SafeArea(
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
        );
      },
    );

    if (selected != null) {
      sortJobsByDay(selected);
    }
  }

  Future<void> sortClothesStillInHere(BuildContext context) async {
    setState(() {
      sortedJobsDone
        ..clear()
        ..addAll(sortedJobsDoneClothesHere);
    });
  }

  Future<void> sortNoticeCash(BuildContext context) async {
    setState(() {
      sortedJobsDone
        ..clear()
        ..addAll(sortedJobsDoneClothesGoneCash);
    });
  }

  Future<void> sortNoticeGCash(BuildContext context) async {
    setState(() {
      sortedJobsDone
        ..clear()
        ..addAll(sortedJobsDoneClothesGoneGCash);
    });
  }

  Future<void> showSearchDialog(
    BuildContext context,
  ) async {
    JobModelRepository jobRepox = JobModelRepository();
    jobRepox.reset();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Find by Customer ID"),
          content: AutoCompleteCustomer(jobRepo: jobRepox),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  sortedJobsDone
                    ..clear()
                    ..addAll(
                      originalJobsDone.where(
                        (job) => job.customerId == jobRepox.selectedCustomerId,
                      ),
                    );
                  //for jobs completed
                  sortedJobsCompleted
                    ..clear()
                    ..addAll(
                      originalJobsCompleted.where(
                        (job) => job.customerId == jobRepox.selectedCustomerId,
                      ),
                    );
                });

                Navigator.pop(context);
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

        intJobsDoneDefault = originalJobsDone.length;
        intJobsDoneClothesHere = sortedJobsDoneClothesHere.length;
        intJobsDoneClothesGoneCash = sortedJobsDoneClothesGoneCash.length;
        intJobsDoneClothesGoneGCash = sortedJobsDoneClothesGoneGCash.length;
      }

      //sortJobs(sortedJobsDone);

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
                    tooltip: "Clothes still here",
                    badgeCount: intJobsDoneClothesHere,
                    onPressed: () => sortClothesStillInHere(context),
                  ),
                  IconBadgeButton(
                    icon: '💳',
                    tooltip: "Delivered Pending GCash",
                    badgeCount: intJobsDoneClothesGoneGCash,
                    onPressed: () => sortNoticeGCash(context),
                  ),
                  IconBadgeButton(
                    icon: '⚠️',
                    tooltip: "Clothes gone Unpaid",
                    badgeCount: intJobsDoneClothesGoneCash,
                    onPressed: () => sortNoticeCash(context),
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
                          // showUpdateDates(context, jobRepo);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          /// 🔹 KEEP SIZE SAME
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),

                            /// 🎨 Softer gradient instead of flat purple
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? [
                                      Colors.deepPurple.shade200,
                                      Colors.deepPurple.shade100,
                                    ]
                                  : [
                                      Colors.deepPurple.shade50,
                                      Colors.deepPurple.shade50,
                                    ],
                            ),

                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                            ],

                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),

                          child: Row(
                            children: [
                              const SizedBox(width: 10),

                              /// ICON
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

                              /// NAME
                              visNameArea(jobRepo.getJobsModel()!, isSelected),

                              /// PRICE
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

  const IconBadgeButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 22, 198, 84),
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
