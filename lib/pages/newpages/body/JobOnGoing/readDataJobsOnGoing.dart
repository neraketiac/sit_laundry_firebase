import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnGoing/showOnGoingStatus.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
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
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                child: child,
              );
            },
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false, // disable default drag handles
            onReorderStart: (index) {},

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

                // ================================
                // 🔔 CONFIRMATION DIALOG
                // ================================
                await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                        'Cannot swap to Job #${targetJob.jobId} ${targetJob.customerName}\n'
                        'that is already started.',
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Okay'),
                        ),
                      ],
                    );
                  },
                );

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

              return ReorderableDelayedDragStartListener(
                key: ValueKey(job.docId), // 👈 KEY MUST BE HERE
                index: index,
                enabled: !dontMove, // 🚫 disable drag if locked
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return MouseRegion(
                      cursor: dontMove
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.grab,
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
                                ? Colors.red.shade200
                                : isSelected
                                    ? Colors.deepPurple.shade100
                                    : Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(14),
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
                              /// 🔼 UP / DOWN COLUMN
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      splashRadius: 18,
                                      icon: const Icon(Icons.keyboard_arrow_up),
                                      onPressed: dontMove
                                          ? null
                                          : () async {
                                              await moveJob(index, index - 1);
                                            },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      splashRadius: 18,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      onPressed: dontMove
                                          ? null
                                          : () async {
                                              await moveJob(index, index + 1);
                                            },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 10),

                              visIconArea(
                                context,
                                jobRepo,
                                job,
                                isSelected,
                                isRunning,
                                () {
                                  showOnGoingStatus(context, jobRepo);
                                },
                              ),

                              const SizedBox(width: 7),

                              visNameArea(jobRepo.getJobsModel()!, isSelected),

                              visPaidUnpaidArea(context, jobRepo, isSelected,
                                  jobRepo.getJobsModel()!),

                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          );
        },
      );
    },
  );
}
