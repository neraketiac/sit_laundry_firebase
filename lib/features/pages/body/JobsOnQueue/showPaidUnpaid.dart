import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visCustomerNameNoAutoComplete.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnPaid.dart';

void showPaidUnpaid(BuildContext context, JobModelRepository jobRepo) {
  // Per-job skip toggle — local only, resets every time dialog opens
  bool skipSuppliesThisJob = false;

  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;

    // Capture old paidCashAmount BEFORE sync overwrites it
    final previousPaidCash = jobRepo.paidCashAmount;

    jobRepo.syncSelectedToRepoMin(jobRepo);

    if (jobRepo.paidCash || (jobRepo.paidGCash && jobRepo.paidGCashVerified)) {
      if (!useAdminTimestampDateD) {
        adminTimestampDateD = Timestamp.now();
      }
      jobRepo.paidD = adminTimestampDateD;
    }

    jobRepo.paymentReceivedBy = empIdGlobal;

    // Clear request flag when admin saves and it was previously requested
    if (isAdmin && jobRepo.requestForAdmin) {
      jobRepo.requestForAdmin = false;
    }

    // Auto-record cash payment DELTA to Supplies
    // Skipped when global skipSuppliesOnPaid OR per-job skipSuppliesThisJob is enabled
    // For non-admin: always record supplies (skipSuppliesOnPaid only affects admin)
    final shouldSkipSupplies =
        (isAdmin && skipSuppliesOnPaid) || skipSuppliesThisJob;
    if (jobRepo.paidCash && !shouldSkipSupplies) {
      final delta = jobRepo.paidCashAmount - previousPaidCash;
      if (delta > 0) {
        // Step 1: Mark job as inserting to supplies (cross-database operation)
        const insertingMarker = '[Inserting to Supplies]';
        jobRepo.selectedRemarksVar.text =
            '${jobRepo.selectedRemarksVar.text} $insertingMarker'.trim();
        jobRepo.remarks = jobRepo.selectedRemarksVar.text;

        try {
          // Update job in DB-A with insertion marker
          await callDatabaseUpdateJob(context, jobRepo.jobModelData);

          // Step 2: Insert to supplies in DB-B (pass clean remarks without marker)
          final cleanRemarks = jobRepo.selectedRemarksVar.text
              .replaceAll(insertingMarker, '')
              .trim();
          await recordCashPaymentAtomicTransaction(
            context,
            jobRepo,
            delta,
            cleanRemarks,
          );

          // Step 3: Remove insertion marker after successful supplies insert
          jobRepo.selectedRemarksVar.text = jobRepo.selectedRemarksVar.text
              .replaceAll(insertingMarker, '')
              .trim();
          jobRepo.remarks = jobRepo.selectedRemarksVar.text;

          // Final update to job without marker
          await callDatabaseUpdateJob(context, jobRepo.jobModelData);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment and supplies recorded successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // If supplies insert fails, job retains the insertion marker for manual retry
          debugPrint('Error in cross-database payment operation: $e');

          // Try to update job with marker if not already done
          try {
            await callDatabaseUpdateJob(context, jobRepo.jobModelData);
          } catch (updateError) {
            debugPrint(
                'Failed to mark job with insertion marker: $updateError');
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to record supplies: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } else {
      // No supplies to record, just update job
      try {
        await callDatabaseUpdateJob(context, jobRepo.jobModelData);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update job payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }
    }
  }

  jobRepo.syncRepoToSelectedMin(jobRepo);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          contentPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.only(
            top: 0,
            left: 5,
            right: 5,
            bottom: 0,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          title: const Text(
            "Payment",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    visCustomerNameNoAutoComplete(context, jobRepo, false),
                    visPaidUnPaid(context, () => setState(() {}), jobRepo),
                    conRemarks(context, () => setState(() {}),
                        jobRepo.selectedRemarksVar),
                    // Admin-only: per-job skip supplies toggle
                    if (isAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Skip Funds Recording',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),
                            Switch(
                              value: skipSuppliesThisJob,
                              activeThumbColor: Colors.orange,
                              onChanged: (v) =>
                                  setState(() => skipSuppliesThisJob = v),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            boxButtonElevated(
                context: context,
                label: 'Save',
                onPressed: () async {
                  if (jobRepo.selectedCustomerId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select customer name.')),
                    );
                    return false;
                  }

                  // Validate cash amount if selected
                  if (jobRepo.selectedPaidCash) {
                    final currentAmount = int.tryParse(jobRepo
                            .repoVarCashAmountVar.text
                            .replaceAll(',', '')) ??
                        0;
                    final finalPrice = jobRepo.selectedFinalPrice;

                    // If already fully paid, cannot edit anymore
                    if (jobRepo.paidCashAmount >= finalPrice &&
                        currentAmount != jobRepo.paidCashAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This job is already fully paid. Cannot edit.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return false;
                    }

                    // Check if amount is below current payment
                    if (jobRepo.paidCashAmount > 0 &&
                        currentAmount < jobRepo.paidCashAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Amount cannot be less than current payment (₱${jobRepo.paidCashAmount})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return false;
                    }
                  }

                  await saveButtonSetRepository();
                  return true;
                }),
          ],
        );
      });
    },
  );
}
