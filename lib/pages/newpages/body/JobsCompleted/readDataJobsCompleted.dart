import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

Widget readDataJobsCompleted(Function setState) {
  DatabaseJobsCompleted databaseJobsCompleted = DatabaseJobsCompleted();
  int? selectedIndex;

  void cycleSort() {
    final sortOptions = [
      intSortByDateC,
      intSortByCustomerName,
      intSortByDateD,
    ];

    final currentIndex = sortOptions.indexOf(intSelectedSort);
    final nextIndex = (currentIndex + 1) % sortOptions.length;

    setState(() {
      intSelectedSort = sortOptions[nextIndex];
    });
  }

  return StreamBuilder<List<JobModel>>(
    stream: databaseJobsCompleted.streamAll(intSelectedSort),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading jobs'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final jobs = snapshot.data!;

      // return StatefulBuilder(
      //   builder: (context, setState) {
      return Column(
        children: [
          /// 🔥 STRETCHED BUTTON ON TOP
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                cycleSort();
                // your action here
              },
              child: Text(
                "Sorting by",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                              //showDeliverOrCustomerPickup(context, jobRepo);
                            },
                          ),

                          const SizedBox(width: 7),

                          /// NAME
                          visNameArea(jobRepo.getJobsModel()!, isSelected),

                          /// PRICE
                          visPaidUnpaidArea(
                              context, jobRepo, isSelected, false),

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
      //   },
      // );
    },
  );
}
