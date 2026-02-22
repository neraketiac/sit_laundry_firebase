import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showMoveToOnGoing.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showPaidUnpaid.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

Widget readDataJobsOnQueue() {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();
  int? selectedIndex;

  return StreamBuilder<List<JobModel>>(
    stream: databaseJobsQueue.streamAll(),
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
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = jobs.removeAt(oldIndex);
                jobs.insert(newIndex, item);

                if (selectedIndex == oldIndex) {
                  selectedIndex = newIndex;
                }
              });
              //save changes of order
              for (int i = 0; i < jobs.length; i++) {
                final job = jobs[i];

                databaseJobsQueue.updateJobId(job.docId, i);
              }
              //save changes of order
            },
            children: List.generate(jobs.length, (index) {
              final job = jobs[index];
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
                            /// 🔘 Drag handle
                            ReorderableDragStartListener(
                              index: index,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: const Icon(Icons.drag_handle),
                              ),
                            ),
                            const SizedBox(width: 10),

                            //                    ICON AREA                    //
                            visIconArea(
                                context, jobRepo, job, isSelected, isRunning,
                                () {
                              showMoveToOnGoing(context, jobRepo);
                            }),

                            const SizedBox(width: 7),
                            //                    NAME AREA                    //
                            visNameArea(jobRepo.getJobsModel()!, isSelected),
                            //                    PRICE AREA                    //
                            visPaidUnpaidArea(context, jobRepo, isSelected,
                                jobRepo.getJobsModel()!),
                            SizedBox(
                              width: 20,
                            ),
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
