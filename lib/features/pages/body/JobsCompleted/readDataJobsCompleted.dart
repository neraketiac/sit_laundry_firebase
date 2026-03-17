import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/showDeliverOrCustomerPickup.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/showReceipt.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminJob.dart';

import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visIconArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visNameArea.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnpaidArea.dart';

/// STATE
List<JobModel> sortedJobsCompleted = [];
DocumentSnapshot? lastCompletedDoc;

bool loadingCompleted = false;
bool hasMoreCompleted = true;

int? selectedCustomerIdCompleted;
DateTime? selectedPickDate;

final DatabaseJobsCompleted databaseJobsCompleted = DatabaseJobsCompleted();

/// LOAD PAGE
Future<void> loadMoreCompletedJobs(VoidCallback refresh) async {
  if (loadingCompleted || !hasMoreCompleted) return;

  loadingCompleted = true;

  // final snapshot = await databaseJobsCompleted.fetchCompletedJobs(
  //   lastDoc: lastCompletedDoc,
  // );

  final snapshot = await databaseJobsCompleted.fetchCompletedJobs(
    lastDoc: lastCompletedDoc,
    customerId: selectedCustomerIdCompleted,
    parameterDate: selectedPickDate,
  );

  if (snapshot.docs.isEmpty) {
    hasMoreCompleted = false;
  } else {
    final jobs = snapshot.docs.map((doc) {
      return JobModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    sortedJobsCompleted.addAll(jobs);
    lastCompletedDoc = snapshot.docs.last;
  }

  loadingCompleted = false;

  /// 🔥 rebuild UI
  refresh();
}

Widget readDataJobsCompleted(
    BuildContext context, VoidCallback dialogSetState) {
  /// load first page
  if (sortedJobsCompleted.isEmpty && !loadingCompleted) {
    loadMoreCompletedJobs(dialogSetState);
  }

  if (sortedJobsCompleted.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }

  return Column(
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("🏁💯 COMPLETED"),
        ],
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ReorderableListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: sortedJobsCompleted.length,
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(18),
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            dialogSetState();
          },
          itemBuilder: (context, index) {
            /// pagination trigger
            if (index == sortedJobsCompleted.length - 1) {
              loadMoreCompletedJobs(dialogSetState);
            }

            final job = sortedJobsCompleted[index];

            final jobRepo = JobModelRepository()..setJobModel(job);

            jobRepo.syncRepoToSelectedAll(jobRepo);

            final isSelected = selectedIndexCompleted == index;

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
                    selectedIndexCompleted = index;
                    dialogSetState();
                    showReceipt(context, jobRepo);
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
                        visIconArea(
                          context,
                          jobRepo,
                          job,
                          isSelected,
                          false,
                          () async {
                            if (isAdmin) {
                              showDeliverOrCustomerPickup(
                                context,
                                jobRepo,
                              );
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
                          false,
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      if (loadingCompleted)
        const Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(),
        ),
    ],
  );
}
