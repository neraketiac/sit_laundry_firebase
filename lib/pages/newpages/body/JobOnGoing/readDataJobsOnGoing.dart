import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnGoing/showOnGoingStatus.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showPaidUnpaid.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

Widget readDataJobsOnGoing() {
  DatabaseJobsOngoing databaseJobsGoing = DatabaseJobsOngoing();
  int? selectedIndex;
  int? blockedIndex;

  return StreamBuilder<List<JobModel>>(
    stream: databaseJobsGoing.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading jobs'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final jobs = snapshot.data!;

      return StatefulBuilder(
        builder: (context, setState) {
          return ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false, // disable default drag handles

            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;

              final draggedJob = jobs[oldIndex];

              // 🚫 1. Cannot drag washing
              if ({'washing', 'drying', 'folding'}
                  .contains(draggedJob.processStep)) {
                return;
              }

              // 🔒 Collect washing indexes
              final dontMoveIndexes = <int>[];
              for (int i = 0; i < jobs.length; i++) {
                if ({'washing', 'drying', 'folding'}
                    .contains(jobs[i].processStep)) {
                  dontMoveIndexes.add(i);
                }
              }

              // 🔍 Simulate reorder
              final tempList = List.of(jobs);
              final item = tempList.removeAt(oldIndex);
              tempList.insert(newIndex, item);

              // 🚫 If washing index changes → BLOCK
              for (int index in dontMoveIndexes) {
                if (!{'washing', 'drying', 'folding'}
                    .contains(tempList[index].processStep)) {
                  // 🔥 Show red flash
                  setState(() {
                    blockedIndex = index;
                  });

                  await Future.delayed(const Duration(milliseconds: 400));

                  setState(() {
                    blockedIndex = null;
                  });

                  return;
                }
              }

              // ✅ Safe reorder
              setState(() {
                jobs.removeAt(oldIndex);
                jobs.insert(newIndex, draggedJob);

                if (selectedIndex == oldIndex) {
                  selectedIndex = newIndex;
                }
              });

              for (int i = 0; i < jobs.length; i++) {
                databaseJobsGoing.updateJobId(jobs[i].docId, i);
              }
            },

            children: List.generate(jobs.length, (index) {
              final job = jobs[index];
              final dontMove =
                  {'washing', 'drying', 'folding'}.contains(job.processStep);

              JobModelRepository jobRepo = JobModelRepository();
              jobRepo.setJobModel(job);

              final progress = 0;
              final isRunning = progress > 0 && progress < 1;
              final isSelected = selectedIndex == index;

              return TweenAnimationBuilder<double>(
                key: ValueKey(job.docId),
                tween: Tween(begin: 0, end: 0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        showJobOnQueueEdit(context, jobRepo);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: blockedIndex == index
                              ? Colors.red.shade200 // 🔥 flash red
                              : isSelected
                                  ? Colors.deepPurple.shade100
                                  : Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            if (isSelected)
                              const BoxShadow(
                                color: Colors.deepPurple,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// 🔘 Drag handle (hidden if washing)
                            dontMove
                                ? const SizedBox(width: 34)
                                : ReorderableDragStartListener(
                                    index: index,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.grab,
                                      child: const Icon(Icons.drag_handle),
                                    ),
                                  ),

                            const SizedBox(width: 10),

                            /// 🔄 Progress badge
                            InkWell(
                              onTap: () {
                                showOnGoingStatus(context, jobRepo);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 6,
                                      backgroundColor:
                                          backGroundStatusColor(job),
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
                                      statusIcon(job),
                                      color: Colors.deepPurple,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 7),

                            /// 📄 Job info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      //CustomerName
                                      Text(
                                        '${displayCustomerName(job.customerName)} (${job.finalLoad})',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.deepPurple
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      //Bags
                                      Text(
                                        textBagDetails(job),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.deepPurple
                                              : Colors.black,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  //EXTRAS
                                  Text(
                                    textDetFabBleExtras(job),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                  //Status
                                  Text(
                                    textJobStatus(job),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: job.forSorting
                                          ? Colors.deepPurple.shade400
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  Text(
                                    '${job.pricingSetup} ${job.remarks}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.deepPurple.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// 💰 Price
                            InkWell(
                              onTap: () {
                                showPaidUnpaid(context, jobRepo);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '# ${jobRepo.jobsId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₱ ${job.finalPrice}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (job.paidCash
                                              ? Colors.deepPurple
                                              : Colors.redAccent)
                                          : (job.paidCash
                                              ? Colors.black
                                              : Colors.redAccent),
                                    ),
                                  ),
                                  Text(
                                    job.unpaid
                                        ? 'Unpaid'
                                        : job.paidCash
                                            ? 'Paid\nCash'
                                            : job.paidGCash
                                                ? 'Paid\nGCash'
                                                : 'Unpaid',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                      color: isSelected
                                          ? (job.paidCash
                                              ? Colors.deepPurple
                                              : Colors.redAccent)
                                          : (job.paidCash
                                              ? Colors.black
                                              : Colors.redAccent),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );
        },
      );
    },
  );
}
