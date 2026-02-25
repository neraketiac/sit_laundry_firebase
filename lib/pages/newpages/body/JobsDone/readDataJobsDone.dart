import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/showDeliverOrCustomerPickup.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

Widget readDataJobsDone() {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
  int? selectedIndex;

  return StreamBuilder<List<JobModel>>(
    stream: databaseJobsDone.streamAll(),
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
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                child: child,
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false, // disable default drag handles
            onReorderStart: (index) {},
            onReorder: (oldIndex, newIndex) {
              setState(() {});
            },
            children: List.generate(jobs.length, (index) {
              final job = jobs[index];
              JobModelRepository jobRepo = JobModelRepository();

              jobRepo.setJobModel(job);

              final progress = 0;
              final isRunning = progress > 0 && progress < 1;
              final isSelected = selectedIndex == index;

              return ReorderableDelayedDragStartListener(
                key: ValueKey(job.docId), // 👈 KEY MUST BE HERE
                index: index,
                child: TweenAnimationBuilder<double>(
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
                          //showJobOnQueueEdit(context, jobRepo);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          padding: const EdgeInsets.all(4),
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
                              //                    ICON AREA                    //
                              visIconArea(
                                  context, jobRepo, job, isSelected, isRunning,
                                  () async {
                                showDeliverOrCustomerPickup(context, jobRepo);
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
                ),
              );
            }),
          );
        },
      );
    },
  );
}
