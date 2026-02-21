import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showJobOnQueueComplete.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showMoveToOnGoing.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/showPaidUnpaid.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

Widget readDataJobsOnQueue() {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();
  int? selectedIndex;

  IconData statusIcon(JobModel jM) {
    if (jM.forSorting) {
      return Icons.sort_by_alpha_outlined;
    }
    if (jM.riderPickup) {
      return Icons.delivery_dining;
    }
    return Icons.pause;
  }

  Color backGroundStatusColor(JobModel jM) {
    if (jM.forSorting) {
      return Colors.green.shade300;
      ;
    }
    if (jM.riderPickup) {
      return Colors.redAccent;
    }
    return Colors.grey;
  }

  String processStatusJobsOnQueue(JobModel jM) {
    if (jM.forSorting) {
      return 'For Sorting';
    }
    if (jM.riderPickup) {
      return 'Rider Pickup';
    }
    return 'no status';
  }

  const Map<int, String> itemNameAliases = {
    menuOthXD: 'xD',
    menuOthXW: 'xW',
    menuOthXS: 'xS',
  };

  String afterNameStatuses(JobModel jM) {
    final List<String> parts = [];

    if (jM.basket > 0) parts.add('${jM.basket}B');
    if (jM.ebag > 0) parts.add('${jM.ebag}E');
    if (jM.sako > 0) parts.add('${jM.sako}S');

    return parts.join(' ');
  }

  String belowNameStatuses(JobModel jM) {
    final List<String> parts = [];

    /// 🔁 Group item names and count
    if (jM.items != null && jM.items!.isNotEmpty) {
      final Map<String, int> itemCounts = {};

      for (final item in jM.items!) {
        late String? name;
        if (item.itemGroup == groupOth) {
          name = itemNameAliases[item.itemUniqueId];
        } else {
          name = item.itemGroup.trim();
        }

        if (name == null || name.isEmpty) continue;

        itemCounts[name] = (itemCounts[name] ?? 0) + 1;
      }

      /// 🧾 Build display string
      itemCounts.forEach((name, count) {
        if (count > 1) {
          parts.add('$count-$name');
        } else {
          parts.add(name);
        }
      });
    }

    return parts.join(' ');
  }

  String displayCustomerName(String? name) {
    if (name == null || name.isEmpty) return '';
    return name.length > 7 ? name.substring(0, 7) : name;
  }

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
                        showJobOnQueueComplete(context, jobRepo);
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

                            /// 🔄 Progress badge
                            InkWell(
                              onTap: () {
                                // Handle progress tap if needed
                                showMoveToOnGoing(context, jobRepo);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 6,
                                      backgroundColor:
                                          backGroundStatusColor(job),
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.deepPurple.shade300,
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: isRunning ? 1 : 0,
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.linear,
                                    child: Icon(
                                      statusIcon(job),
                                      color: Colors.deepPurple,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),

                            /// 📄 Job info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${displayCustomerName(job.customerName)} (${job.finalLoad})',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.deepPurple
                                              : Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        afterNameStatuses(job),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.deepPurple
                                                : Colors.black,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    belowNameStatuses(job),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                        fontSize: 10),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    processStatusJobsOnQueue(job),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: (job.forSorting
                                          ? Colors.deepPurple.shade400
                                          : Colors.redAccent),
                                    ),
                                  ),
                                  Text(
                                    '${job.pricingSetup} ${job.remarks}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.deepPurple.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// 💰 Price
                            InkWell(
                              onTap: (() {
                                showPaidUnpaid(context, jobRepo);
                              }),
                              child: Column(
                                children: [
                                  Text(
                                    '₱ ${job.finalPrice}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (job.paidCash
                                              ? Colors.deepPurple
                                              : Colors.redAccent)
                                          : (job.paidCash
                                              ? Colors.black
                                              : Colors.redAccent),
                                    ),
                                  ),
                                  Text(
                                    (job.unpaid
                                        ? 'Unpaid'
                                        : job.paidCash
                                            ? 'Paid\nCash'
                                            : job.paidGCash
                                                ? 'Paid\nGCash'
                                                : 'Unpaid'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? (job.paidCash
                                              ? Colors.deepPurple
                                              : Colors.redAccent)
                                          : (job.paidCash
                                              ? Colors.black
                                              : Colors.redAccent),
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
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
