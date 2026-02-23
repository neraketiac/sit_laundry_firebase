import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnGoing/showOnGoingStatus.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'dart:math';

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
          Future<void> moveJob(int oldIndex, int newIndex) async {
            //if (newIndex > oldIndex) newIndex -= 1;

            final movingJob = jobs[oldIndex];

            bool isLocked(String step) =>
                {'washing', 'drying', 'folding'}.contains(step);

            if (isLocked(movingJob.processStep)) return;

            final isMovingDown = newIndex > oldIndex;

            int newJobId;

            if (isMovingDown) {
              // 🔽 Moving Down
              newJobId = movingJob.jobId == 25
                  ? 1 // wrap to 1
                  : movingJob.jobId + 1;
            } else {
              // 🔼 Moving Up
              newJobId = movingJob.jobId == 1
                  ? 25 // wrap to 25
                  : movingJob.jobId - 1;
            }

            // 🔍 Check if target exists in UI
            JobModel? targetJob =
                jobs.where((j) => j.jobId == newJobId).isNotEmpty
                    ? jobs.firstWhere((j) => j.jobId == newJobId)
                    : null;

            // 🚫 If target exists and is locked → block
            if (targetJob != null && isLocked(targetJob.processStep)) {
              setState(() => blockedIndex = newIndex);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return;
            }

            // 🔔 Optional confirmation
            // on #1 and #25 will be asked
            //if (newJobId == 1 || newJobId == 25) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirm Reorder'),
                content: Text(
                  'Move Job #${movingJob.jobId} ${movingJob.customerName} '
                  'to #$newJobId?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );

            if (confirm != true) return;
            //}

            final oldJobId = movingJob.jobId;

            // 🔥 UI UPDATE
            setState(() {
              movingJob.jobId = newJobId;

              if (targetJob != null) {
                targetJob.jobId = oldJobId; // swap
              }

              jobs.sort((a, b) => a.jobId.compareTo(b.jobId));
            });

            // 🔥 FIRESTORE UPDATE
            await databaseJobsGoing.swapOrInsert(
              movingDocId: movingJob.docId,
              oldJobId: oldJobId,
              newJobId: newJobId,
            );
          }

          return ReorderableListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false, // disable default drag handles

            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;

              final movingJob = jobs[oldIndex];
              final targetJob = jobs[newIndex];

              bool isLocked(String step) =>
                  {'washing', 'drying', 'folding'}.contains(step);

              // 🚫 Locked moving job
              if (isLocked(movingJob.processStep)) {
                setState(() => blockedIndex = oldIndex);
                await Future.delayed(const Duration(milliseconds: 400));
                setState(() => blockedIndex = null);
                return;
              }

              // 🚫 Locked target job
              if (isLocked(targetJob.processStep)) {
                setState(() => blockedIndex = newIndex);
                await Future.delayed(const Duration(milliseconds: 400));
                setState(() => blockedIndex = null);
                return;
              }

              // ================================
              // 🔔 CONFIRMATION DIALOG
              // ================================
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm Swap'),
                    content: Text(
                      'Swap Job #${movingJob.jobId} ${movingJob.customerName} '
                      'to Job #${targetJob.jobId} ${targetJob.customerName}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );

              // ❌ If user pressed No or dismissed dialog
              if (confirm != true) return;

              final oldJobId = movingJob.jobId;
              final targetJobId = targetJob.jobId;

              // 🔥 Update UI first
              setState(() {
                movingJob.jobId = targetJobId;
                targetJob.jobId = oldJobId;
                jobs.sort((a, b) => a.jobId.compareTo(b.jobId));
              });

              // 🔥 Update Firestore
              await Future.wait([
                databaseJobsGoing.updateJobId(movingJob.docId, movingJob.jobId),
                databaseJobsGoing.updateJobId(targetJob.docId, targetJob.jobId),
              ]);
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
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        padding: const EdgeInsets.all(5),
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
                                ? const SizedBox(width: 24)
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 🔼 UP
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            splashRadius: 18,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_up),
                                            onPressed: () async {
                                              await moveJob(index, index - 1);
                                            }),
                                      ),

                                      // ☰ DRAG HANDLE
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.grab,
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1),
                                            child: Icon(
                                              Icons.drag_handle,
                                              size: 5,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 🔽 DOWN
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            splashRadius: 18,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            onPressed: () async {
                                              await moveJob(index, index + 1);
                                            }),
                                      ),
                                    ],
                                  ),

                            const SizedBox(width: 10),

                            //                    ICON AREA                    //
                            visIconArea(
                                context, jobRepo, job, isSelected, isRunning,
                                () {
                              showOnGoingStatus(context, jobRepo);
                            }),

                            const SizedBox(width: 7),
                            //                    NAME AREA                    //
                            visNameArea(jobRepo.getJobsModel()!, isSelected),
                            //                    PRICE AREA                    //
                            visPaidUnpaidArea(context, jobRepo, isSelected,
                                jobRepo.getJobsModel()!),
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
