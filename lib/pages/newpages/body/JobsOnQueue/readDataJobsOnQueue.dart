import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsOnQueue/showMoveToOnGoing.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

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
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("⏳ QUEUE")],
              ),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,

                /// 🔥 Drag appearance
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(20),
                    child: child,
                  );
                },

                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = jobs.removeAt(oldIndex);
                    jobs.insert(newIndex, item);

                    if (selectedIndex == oldIndex) {
                      selectedIndex = newIndex;
                    }
                  });

                  /// Save order
                  for (int i = 0; i < jobs.length; i++) {
                    databaseJobsQueue.updateJobId(jobs[i].docId, i);
                  }
                },

                children: List.generate(jobs.length, (index) {
                  final job = jobs[index];
                  JobModelRepository jobRepo = JobModelRepository();
                  jobRepo.setJobModel(job);
                  jobRepo.syncRepoToSelectedAll(jobRepo);

                  final isSelected = selectedIndex == index;

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(job.docId),
                    index: index,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          showJobOnQueueEdit(context, jobRepo);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          /// 🔹 KEEP SIZE SAME
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),

                            /// 🎨 Subtle gradient instead of flat color
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

                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.withOpacity(0.1),
                              width: isSelected ? 1.5 : 1,
                            ),

                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),

                          child: Row(
                            children: [
                              const SizedBox(width: 10),

                              /// 🔥 ICON AREA
                              visIconArea(
                                context,
                                jobRepo,
                                job,
                                isSelected,
                                false,
                                () async {
                                  if (isProcessing) return;

                                  setState(() => isProcessing = true);

                                  try {
                                    final nextJobId = await getNextJobId();
                                    jobRepo.jobId = nextJobId;

                                    showMoveToOnGoing(context, jobRepo);
                                  } finally {
                                    setState(() => isProcessing = false);
                                  }
                                },
                              ),

                              const SizedBox(width: 7),

                              /// 🧾 NAME
                              visNameArea(jobRepo.getJobsModel()!, isSelected),

                              /// 💰 PRICE
                              visPaidUnpaidArea(
                                  context, jobRepo, isSelected, true),

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
