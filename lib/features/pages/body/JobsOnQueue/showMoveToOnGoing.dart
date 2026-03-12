import 'package:flutter/material.dart';
import 'package:laundry_firebase/shared/widgets/actions/showCoolConfirmDialog.dart';

import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

import 'dart:ui';

import 'package:laundry_firebase/shared/widgets/jobdisplay/visCustomerNameNoAutoComplete.dart';

void showMoveToOnGoing(BuildContext context, JobModelRepository jobRepo) {
  //syncRepoToSelectedSmall(jobRepo);
  jobRepo.syncRepoToSelectedMin(jobRepo);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "MoveToOnGoing",
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      final width = MediaQuery.of(context).size.width;

      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: width > 600 ? 480 : width * 0.95,
                  ),
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Title with accent bar
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              jobRepo.selectedJobId == 0
                                  ? "Jobs On-Going Full"
                                  : "Move to #${jobRepo.selectedJobId}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Form Area
                      visCustomerNameNoAutoComplete(context, jobRepo, false),

                      const SizedBox(height: 32),

                      // 🔥 Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purple,
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () async {
                                if (jobRepo.selectedCustomerId == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please select customer."),
                                    ),
                                  );
                                  return;
                                }

                                final confirm = await showCoolConfirmDialog(
                                  context: context,
                                  title: "Confirm Move",
                                  message:
                                      "Move ${jobRepo.selectedCustomerNameVar.text} "
                                      "to #${jobRepo.selectedJobId}?",
                                  confirmText: "Move",
                                );

                                if (!confirm) return;

                                await moveQueueToOngoing(jobRepo.docId);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${jobRepo.selectedCustomerNameVar.text} added to #${jobRepo.selectedJobId}.",
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Move to On-Going",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
          child: child,
        ),
      );
    },
  );
}
