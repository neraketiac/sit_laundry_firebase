import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnGoing/showOnGoingStatus.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

enum ReorderAction {
  swap,
  move,
  cancel,
}

Widget readDataJobsOnGoing() {
  DatabaseJobsOngoing databaseJobsGoing = DatabaseJobsOngoing();
  int? selectedIndex;
  int? blockedIndex, clickedUpButtonIndex, clickedDownButtonIndex;
  bool isLocked(String step) => {'washing', 'drying', 'folding'}.contains(step);
  final Color cDontMove = Colors.deepPurple.shade100;

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

            // bool useSwap = false;
            if (isMovingDown) {
              // 🔽 Moving Down for #25 only
              newJobId = movingJob.jobId == 25
                  ? 1 // wrap to 1
                  : movingJob.jobId + 1;
              //detect next exists
              // useSwap = jobs[oldIndex].jobId + 1 == jobs[newIndex].jobId;
            } else {
              // debugPrint('debugPrint 6 moving up newJobId=${movingJob.jobId}');
              // debugPrint(
              //     'debugPrint 6 moving up oldIndex=$oldIndex newIndex=$newIndex');
              // debugPrint(
              //     'debugPrint 6 moving up oldjobid=${jobs[oldIndex].jobId} newjobid=${jobs[newIndex].jobId} ');
              // 🔼 Moving Up for # 1 only
              newJobId = movingJob.jobId == 1
                  ? 25 // wrap to 25
                  : movingJob.jobId - 1;
              //detect next exists

              // useSwap = jobs[oldIndex].jobId - 1 == jobs[newIndex].jobId;
            }
            // 🔍 Check if target exists in UI
            JobModel? targetJob =
                jobs.where((j) => j.jobId == newJobId).isNotEmpty
                    ? jobs.firstWhere((j) => j.jobId == newJobId)
                    : null;
            // 🚫 If target exists and is locked → block
            if (targetJob != null && isLocked(targetJob.processStep)) {
              if (!isMovingDown) {
                setState(() => clickedUpButtonIndex = oldIndex);
              } else {
                setState(() => clickedDownButtonIndex = oldIndex);
              }
              setState(() => blockedIndex = newIndex);
              await Future.delayed(const Duration(milliseconds: 400));
              if (!isMovingDown) setState(() => clickedUpButtonIndex = null);
              if (isMovingDown) setState(() => clickedDownButtonIndex = null);
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

          Future<void> moveUpCascade(int index) async {
            if (index == 0) return;

            jobs.sort((a, b) => a.jobId.compareTo(b.jobId));

            //if last job is long pressed even only 1 item, just dont use long press if want to go down
            // if (0 == index - 1) {
            //   setState(() => clickedUpButtonIndex = index);
            //   setState(() => blockedIndex = 0);
            //   await Future.delayed(const Duration(milliseconds: 400));
            //   setState(() => clickedUpButtonIndex = null);
            //   setState(() => blockedIndex = null);

            //   return;
            // }

            //if next job is locked
            if (isLocked(jobs[index - 1].processStep)) {
              setState(() => blockedIndex = index - 1);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return;
            }

            final selectedJob = jobs[index];
            int currentId = selectedJob.jobId;
            int lockedItemReached = 0;
            bool zeroIndexReached = false;

            // 1️⃣ Collect continuous sequence
            List<JobModel> affectedJobs = [];
            List<int> affectedIds = [];
            List<int> destinationIds = [];

            // for (int i = index; i < jobs.length; i++) {
            for (int i = index; i >= 0; i--) {
              if (jobs[i].jobId == currentId) {
                //block jobid = 0
                if ((jobs[i].jobId - 1) <= 0) {
                  zeroIndexReached = true;
                  break;
                }
                affectedJobs.add(jobs[i]);

                if (isLocked(jobs[i].processStep)) {
                  lockedItemReached = i;
                  break;
                }

                // collect jobId
                affectedIds.add(jobs[i].jobId);
                destinationIds.add(jobs[i].jobId - 1);

                currentId--;
              } else {
                //next number is blank, not sequence
                break;
              }
            }
            //Already reached the locked item
            if (lockedItemReached > 0) {
              setState(() => clickedUpButtonIndex = index);
              setState(() => blockedIndex = lockedItemReached);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedUpButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint(
                  "❌ Cannot move. Locked item reached$lockedItemReached ${affectedJobs.last.jobId}");
              return;
            }

            // 2️⃣ 1 PROTECTION, MAKE SURE NO jobId = 0
            if (zeroIndexReached) {
              setState(() => clickedUpButtonIndex = index);
              setState(() => blockedIndex = 0);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedUpButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint("❌ Cannot move up");
              return;
            }

            final messageAffected = affectedIds.map((id) => '#$id').join(', ');
            final messageDestination =
                destinationIds.map((id) => '#$id').join(', ');

            // ALERT affected
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirm Reorder'),
                content: Text(
                  'Move up all\n $messageAffected\n'
                  'to $messageDestination?',
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

            // 3️⃣ Firestore batch update (atomic)
            databaseJobsGoing.cascadeUp(affectedJobs);

            // 4️⃣ Update UI AFTER successful commit
            setState(() {
              for (final job in affectedJobs) {
                job.jobId -= 1;
              }
            });
          }

          Future<void> moveDownCascade(int index) async {
            jobs.sort((a, b) => a.jobId.compareTo(b.jobId));

            //if last job is long pressed even only 1 item, just dont use long press if want to go down
            if (jobs.length == index + 1) {
              setState(() => blockedIndex = index);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return;
            }

            //if next job is locked
            if (isLocked(jobs[index + 1].processStep)) {
              setState(() => blockedIndex = index + 1);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return;
            }

            final selectedJob = jobs[index];
            int currentId = selectedJob.jobId;
            int lockedItemReached = 0;

            // 1️⃣ Collect continuous sequence
            List<JobModel> affectedJobs = [];
            List<int> affectedIds = [];
            List<int> destinationIds = [];

            for (int i = index; i < jobs.length; i++) {
              if (jobs[i].jobId == currentId) {
                affectedJobs.add(jobs[i]);

                if (isLocked(jobs[i].processStep)) {
                  lockedItemReached = i;
                  break;
                }

                // collect jobId
                affectedIds.add(jobs[i].jobId);
                destinationIds.add(jobs[i].jobId + 1);

                currentId++;
              } else {
                //next number is blank, not sequence
                break;
              }
            }
            //Already reached the locked item
            if (lockedItemReached > 0) {
              setState(() => clickedDownButtonIndex = index);
              setState(() => blockedIndex = lockedItemReached);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedDownButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint(
                  "❌ Cannot move. Locked item reached$lockedItemReached ${affectedJobs.last.jobId}");
              return;
            }

            // 2️⃣ MAX 25 PROTECTION
            final highestIdAfterShift = affectedJobs.last.jobId + 1;

            if (highestIdAfterShift > 25) {
              setState(() => clickedDownButtonIndex = index);
              setState(() => blockedIndex = jobs.length - 1);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedDownButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint(
                  "❌ Cannot move. Max jobId 25 reached.$index ${affectedJobs.last.jobId}");
              return;
            }

            final messageAffected = affectedIds.map((id) => '#$id').join(', ');
            final messageDestination =
                destinationIds.map((id) => '#$id').join(', ');

            // ALERT affected
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Confirm Reorder'),
                content: Text(
                  'Move down all\n $messageAffected\n'
                  'to $messageDestination?',
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

            // 3️⃣ Firestore batch update (atomic)
            databaseJobsGoing.cascade(affectedJobs);

            // 4️⃣ Update UI AFTER successful commit
            setState(() {
              for (final job in affectedJobs) {
                job.jobId += 1;
              }
            });
          }

          Future<bool> moveDownCascadeBool(
              JobModel movingJob, int index) async {
            jobs.sort((a, b) => a.jobId.compareTo(b.jobId));
            int newIndexJobId = jobs[index].jobId;

            //if last job is long pressed even only 1 item, just dont use long press if want to go down
            if (jobs.length == index + 1) {
              setState(() => blockedIndex = index);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return false;
            }

            //if next job is locked
            if (isLocked(jobs[index + 1].processStep)) {
              setState(() => blockedIndex = index + 1);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => blockedIndex = null);

              return false;
            }

            final selectedJob = jobs[index];
            int currentId = selectedJob.jobId;
            int lockedItemReached = 0;

            // 1️⃣ Collect continuous sequence
            List<JobModel> affectedJobs = [];
            List<int> affectedIds = [];
            List<int> destinationIds = [];

            for (int i = index; i < jobs.length; i++) {
              if (jobs[i].jobId == currentId) {
                //do not include moving the middle part
                //ex 1,2,3,4,5 move 3 to 1, then 4, 5 no need to move forward
                //ex 1,2,3,4,5 move 7 to 1, then all nums need to move forward cause moving 7 always > jobsid
                if (movingJob.jobId < jobs[i].jobId) {
                  break;
                }

                affectedJobs.add(jobs[i]);

                if (isLocked(jobs[i].processStep)) {
                  lockedItemReached = i;
                  break;
                }

                // collect jobId
                affectedIds.add(jobs[i].jobId);
                destinationIds.add(jobs[i].jobId + 1);

                currentId++;
              } else {
                //next number is blank, not sequence
                break;
              }
            }
            //Already reached the locked item
            if (lockedItemReached > 0) {
              setState(() => clickedDownButtonIndex = index);
              setState(() => blockedIndex = lockedItemReached);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedDownButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint(
                  "❌ Cannot move. Locked item reached$lockedItemReached ${affectedJobs.last.jobId}");
              return false;
            }

            // 2️⃣ MAX 25 PROTECTION
            final highestIdAfterShift = affectedJobs.last.jobId + 1;

            if (highestIdAfterShift > 25) {
              setState(() => clickedDownButtonIndex = index);
              setState(() => blockedIndex = jobs.length - 1);
              await Future.delayed(const Duration(milliseconds: 400));
              setState(() => clickedDownButtonIndex = null);
              setState(() => blockedIndex = null);

              debugPrint(
                  "❌ Cannot move. Max jobId 25 reached.$index ${affectedJobs.last.jobId}");
              return false;
            }

            final messageAffected = affectedIds.map((id) => '#$id').join(', ');
            final messageDestination =
                destinationIds.map((id) => '#$id').join(', ');

            // 3️⃣ Firestore batch update (atomic)
            databaseJobsGoing.cascade(affectedJobs);

            //this will only update the vacant slot made above after moving down
            databaseJobsGoing.updateJobId(movingJob.docId, newIndexJobId);

            // 4️⃣ Update UI AFTER successful commit
            setState(() {
              for (final job in affectedJobs) {
                job.jobId += 1;
              }
            });

            return true;
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

              final canPrioritize = newIndex < oldIndex;

              final movingJob = jobs[oldIndex];
              final targetJob = jobs[newIndex];
              bool useSwap = false;
              bool lowtohigh = oldIndex < newIndex;

              //use swap only from 1 to 25, because if you !swap for 25, you could insert jobid 26

              //immediately  useswap if targetJob.jobId is 25,
              //if you allow not to swap, you could insert jobId 26 because its always available
              if (targetJob.jobId == 25 || targetJob.jobId == 1) {
                useSwap = true;
              } else {
                if (newIndex + 1 < jobs.length) {
                  //from 3 to 5
                  if (lowtohigh) {
                    final nextTargetJob = jobs[newIndex + 1];
                    useSwap = targetJob.jobId + 1 == nextTargetJob.jobId;
                  }
                  //from 5 to 3
                  else {
                    //prevent negative index
                    if (newIndex - 1 < 0) {
                      useSwap = false;
                    } else {
                      final nextTargetJob = jobs[newIndex - 1];
                      useSwap = targetJob.jobId - 1 == nextTargetJob.jobId;
                    }
                  }
                }
              }

              // // 🚫 Locked moving job
              // if (isLocked(movingJob.processStep)) {
              //   setState(() => blockedIndex = oldIndex);
              //   await Future.delayed(const Duration(milliseconds: 400));
              //   setState(() => blockedIndex = null);
              //   return;
              // }

              // 🚫 Locked target job
              if (isLocked(targetJob.processStep) && useSwap) {
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
              final action = await showDialog<ReorderAction>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm Action'),
                    content: Text(
                      (canPrioritize
                              ? 'Prioritize #${movingJob.jobId} ${movingJob.customerName}?\n'
                              : '') +
                          (canPrioritize ? 'or\n' : '') +
                          (canPrioritize
                              ? 'Swap to Job #${targetJob.jobId} ${targetJob.customerName}?'
                              : 'Swap #${movingJob.jobId} ${movingJob.customerName} to #${targetJob.jobId} ${targetJob.customerName}?'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, ReorderAction.cancel),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, ReorderAction.swap),
                        child: const Text('Swap'),
                      ),
                      if (canPrioritize)
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, ReorderAction.move),
                          child: const Text('Prioritize'),
                        ),
                    ],
                  );
                },
              );

              // do swap logic
              //oldJob babagsakan
              final oldJobId = movingJob.jobId;
              //targetJobId lift
              final targetJobId = targetJob.jobId;

              // ❌ If dismissed or cancel
              if (action == null || action == ReorderAction.cancel) return;

              // ✅ Handle selection
              if (action == ReorderAction.swap) {
                // 🔥 Update UI first
                if (useSwap) {
                  setState(() {
                    movingJob.jobId = targetJobId;
                    targetJob.jobId = oldJobId;
                    jobs.sort((a, b) => a.jobId.compareTo(b.jobId));
                  });
                } else {
                  setState(() {
                    if (lowtohigh) {
                      movingJob.jobId = targetJobId + 1;
                    } else {
                      movingJob.jobId = targetJobId - 1;
                    }
                    jobs.sort((a, b) => a.jobId.compareTo(b.jobId));
                  });
                }
                // 🔥 Update Firestore
                await Future.wait([
                  databaseJobsGoing.updateJobId(
                      movingJob.docId, movingJob.jobId), // lift
                  if (useSwap)
                    databaseJobsGoing.updateJobId(
                        targetJob.docId, targetJob.jobId), // nabagsakan
                ]);
              } else if (action == ReorderAction.move) {
                // do move logic

                if (await moveDownCascadeBool(movingJob, newIndex)) {
                } else {
                  return;
                }

                // final binagsakangInt = await moveDownCascadeInt(
                //     newIndex); //this will move all the down
                // if (binagsakangInt != 0) {
                //   //this will only update the vacant slot made above after moving down
                //   databaseJobsGoing.updateJobId(
                //       movingJob.docId, binagsakangInt);
                // } else {
                //   return;
                // }
              }

              // final confirm = await showDialog<bool>(
              //   context: context,
              //   builder: (context) {
              //     return AlertDialog(
              //       title: const Text('Confirm Swap'),
              //       content: Text(
              //         useSwap
              //             ? 'Swap Job #${movingJob.jobId} ${movingJob.customerName} '
              //                 'to Job #${targetJob.jobId} ${targetJob.customerName}?'
              //             : //to
              //             'Move Job #${movingJob.jobId} ${movingJob.customerName} ${lowtohigh ? 'to Job #${targetJob.jobId + 1}?' : 'to Job #${targetJob.jobId - 1}?'}',
              //       ),
              //       actions: [
              //         TextButton(
              //           onPressed: () => Navigator.pop(context, false),
              //           child: const Text('No'),
              //         ),
              //         ElevatedButton(
              //           onPressed: () => Navigator.pop(context, true),
              //           child: const Text('Yes'),
              //         ),
              //       ],
              //     );
              //   },
              // );

              // // ❌ If user pressed No or dismissed dialog
              // if (confirm != true) return;
            },
            children: List.generate(jobs.length, (index) {
              final job = jobs[index];
              final dontMove =
                  {'washing', 'drying', 'folding'}.contains(job.processStep);

              JobModelRepository jobRepo = JobModelRepository();
              jobRepo.setJobModel(job);
              jobRepo.syncRepoToSelectedAll(jobRepo);

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
                                : (isLocked(jobRepo.selectedProcessStep))
                                    ? cDontMove
                                    : isSelected
                                        ? Colors.deepPurple.shade50
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
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: clickedUpButtonIndex == index
                                            ? Colors.red
                                            : dontMove
                                                ? cDontMove
                                                : Colors.grey
                                                    .shade300, // circle background
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        splashRadius: 20,
                                        color: dontMove
                                            ? cDontMove
                                            : Colors.grey.shade800, //
                                        icon:
                                            const Icon(Icons.keyboard_arrow_up),
                                        //UP
                                        onPressed: dontMove
                                            ? null
                                            : () async {
                                                if (index - 1 < 0) {
                                                  await moveJob(index, index);
                                                } else {
                                                  await moveJob(
                                                      index, index - 1);
                                                }
                                              },
                                        onLongPress: dontMove
                                            ? null
                                            : () async {
                                                await moveUpCascade(index);
                                              },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: clickedDownButtonIndex == index
                                            ? Colors.red
                                            : dontMove
                                                ? cDontMove
                                                : Colors.grey
                                                    .shade300, // circle background
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        splashRadius: 20,
                                        color: dontMove
                                            ? cDontMove
                                            : Colors
                                                .grey.shade800, // icon color
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        //DOWN
                                        onPressed: dontMove
                                            ? null
                                            : () async {
                                                await moveJob(index, index + 1);
                                              },
                                        onLongPress: dontMove
                                            ? null
                                            : () async {
                                                await moveDownCascade(index);
                                              },
                                      ),
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
