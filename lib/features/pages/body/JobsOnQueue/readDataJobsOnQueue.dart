import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/showJobOnQueueEdit.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/showMoveToOnGoing.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminJob.dart';

import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visIconArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visNameArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnpaidArea.dart';

final DatabaseJobsQueue _databaseJobsQueue = DatabaseJobsQueue();

int? _selectedIndex;

Widget readDataJobsOnQueue(bool visible, Color color) {
  return StreamBuilder<List<JobModel>>(
    stream: _databaseJobsQueue.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading jobs'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final jobs = snapshot.data!;
      FsUsageTracker.instance.track('readDataJobsOnQueue', jobs.length);

      return animatedPanel(
        visible: visible,
        width: AppScale.of(context).isTablet ? 400 : 320,
        color: color,
        child: _buildQueueList(context, jobs),
      );
    },
  );
}

Widget _buildQueueList(BuildContext context, List<JobModel> jobs) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("⏳ QUEUE")],
          ),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;

                final item = jobs.removeAt(oldIndex);
                jobs.insert(newIndex, item);

                if (_selectedIndex == oldIndex) {
                  _selectedIndex = newIndex;
                }
              });

              for (int i = 0; i < jobs.length; i++) {
                _databaseJobsQueue.updateJobId(jobs[i].docId, i);
              }
            },
            children: List.generate(jobs.length, (index) {
              final job = jobs[index];

              final jobRepo = JobModelRepository()
                ..setJobModel(job)
                ..syncRepoToSelectedAll(
                  JobModelRepository()..setJobModel(job),
                );

              final isSelected = _selectedIndex == index;

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
                          builder: (_) => AdminJobRepoViewer(jobRepo: jobRepo),
                        );
                      }
                    },
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });

                      showJobOnQueueEdit(context, jobRepo);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
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
                          visNameArea(
                            jobRepo.getJobsModel()!,
                            isSelected,
                          ),
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
}
