import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/showDeliverOrCustomerPickup.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/showJobOnQueueNoEdit.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

Widget readDataJobsDone(Function setState) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();

  Future<void> showSearchDialog(
    BuildContext context,
    Function setState,
    List<JobModel> sortedJobs,
    List<JobModel> originalJobs,
  ) async {
    JobModelRepository jobRepox = JobModelRepository();
    jobRepox.reset();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Find by Customer ID"),
          content: AutoCompleteCustomer(jobRepo: jobRepox),
          // TextField(
          //   controller: controller,
          //   decoration: const InputDecoration(
          //     hintText: "Enter Customer ID",
          //   ),
          // ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                //debugPrint('jobRepox.customerId=${jobRepox.customerId}');
                setState(() {
                  sortedJobs
                    ..clear()
                    ..addAll(
                      originalJobs.where(
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

  void sortJobs(List<JobModel> jobs) {
    switch (intSelectedSortDone) {
      case intSortByDateC:
        jobs.sort((a, b) => b.dateC.compareTo(a.dateC));
        break;

      case intSortByCustomerName:
        jobs.sort((a, b) => a.customerName
            .toLowerCase()
            .compareTo(b.customerName.toLowerCase()));
        break;

      case intSortByDateD:
        jobs.sort((a, b) => b.dateD.compareTo(a.dateD));
        break;

      case intFindCustomerNameId:
        break;
    }
  }

  Future<void> cycleSort(BuildContext context) async {
    //default sort by Date Complete or Find name
    final sortOptions = [
      //intSortByDateC,
      //intSortByCustomerName,
      intSortByDateD,
      intFindCustomerNameId,
    ];

    final currentIndex = sortOptions.indexOf(intSelectedSortDone);
    final nextIndex = (currentIndex + 1) % sortOptions.length;

    intSelectedSortDone = sortOptions[nextIndex];

    /// 🔥 If search mode → show dialog
    if (intSelectedSortDone == intFindCustomerNameId) {
      await showSearchDialog(
          context, setState, sortedJobsDone, originalJobsDone);
    } else {
      setState(() {
        sortedJobsDone
          ..clear()
          ..addAll(originalJobsDone);
        sortJobs(sortedJobsDone);
      });
    }
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

        sortJobs(sortedJobsDone);
      }

      // return StatefulBuilder(
      //   builder: (context, setState) {
      return Column(
        children: [
          /// 🔥 STRETCHED BUTTON ON TOP
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 198, 84),
              ),
              onPressed: () async {
                await cycleSort(context);
              },
              child: Text(
                intSortByDateD == intSelectedSortDone
                    ? 'Find?'
                    : 'Sort Date Done',
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
                    onTap: () {
                      setState(() {
                        selectedIndexDone = index;
                      });
                      showJobOnQueueNoEdit(context, jobRepo);
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
      //   },
      // );
    },
  );
}
