import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visCustomerNameNoAutoComplete.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnPaid.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_current.dart';

// ============ HELPER FUNCTION: Create Salary Correction ============
Future<void> recordSalaryCorrection({
  required BuildContext context,
  required String empName,
  required String empId,
  required int amount, // Negative for deduction
  required String remarks,
  required int jobId,
}) async {
  try {
    final employeeModel = EmployeeModel(
      empId: empId,
      empName: empName,
      docId: '',
      countId: 0,
      currentCounter: amount, // Negative for deduction
      currentStocks: 0,
      itemId: 1, // Salary code
      itemUniqueId: 1, // Salary payment/deduction
      itemName: 'Salary Correction',
      logDate: Timestamp.now(),
      logBy: empIdGlobal,
      remarks: '$remarks | JobId: $jobId',
      autoSalaryDate: null,
    );

    // Write to BOTH employee_curr and employee_hist (tandem)
    final databaseEmployeeCurrent = DatabaseEmployeeCurrent();
    await databaseEmployeeCurrent.addEmployeeCurr(employeeModel);
  } catch (e) {
    debugPrint('Error recording salary correction: $e');
    rethrow;
  }
}

void showPaidUnpaid(BuildContext context, JobModelRepository jobRepo) {
  // Per-job skip toggle — local only, resets every time dialog opens
  bool skipSuppliesThisJob = false;
  bool useStaffSalaryDeduction = false;

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

    const insertingMarker = '[Inserting to Supplies]';

    if (jobRepo.paidCash) {
      // ============ STAFF SALARY DEDUCTION LOGIC ============
      if (useStaffSalaryDeduction &&
          isAdmin &&
          jobRepo.customerName.isNotEmpty &&
          empNameToId.containsKey(jobRepo.customerName)) {
        // Check if customer is actually a staff/employee
        final staffEmpId = empNameToId[jobRepo.customerName];
        if (staffEmpId != null) {
          // Calculate remaining unpaid amount
          final currentPaidCash = int.tryParse(
                  jobRepo.repoVarCashAmountVar.text.replaceAll(',', '')) ??
              0;
          final unpaidAmount = jobRepo.selectedFinalPrice - currentPaidCash;

          if (unpaidAmount > 0) {
            // Add remarks to job
            final salaryDeductionRemark =
                'Paid=${currentPaidCash}, SalaryDeduct=${unpaidAmount}';
            if (!jobRepo.remarks.contains(salaryDeductionRemark)) {
              jobRepo.selectedRemarksVar.text =
                  '${jobRepo.selectedRemarksVar.text} $salaryDeductionRemark'
                      .trim();
              jobRepo.remarks = jobRepo.selectedRemarksVar.text;
            }

            // Create salary correction with negative value (deduction)
            try {
              await recordSalaryCorrection(
                context: context,
                empName: jobRepo.customerName,
                empId: staffEmpId,
                amount: -unpaidAmount, // Negative for deduction
                remarks: 'Job deduction: $salaryDeductionRemark',
                jobId: jobRepo.jobId,
              );
              debugPrint(
                  'Salary correction created: -$unpaidAmount for ${jobRepo.customerName}');
            } catch (e) {
              debugPrint('Error creating salary correction: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create salary deduction: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
              return;
            }

            // Mark job as fully paid
            jobRepo.paidCashAmount = jobRepo.selectedFinalPrice;
            jobRepo.unpaid = false; // Mark as paid

            // AUTO-SKIP funds recording for staff salary deduction
            skipSuppliesThisJob = true;
          }
        }
      }
      // ============ END STAFF SALARY DEDUCTION LOGIC ============

      // Step 1: Add marker to remarks
      if (!jobRepo.remarks.contains(insertingMarker)) {
        jobRepo.selectedRemarksVar.text =
            '${jobRepo.selectedRemarksVar.text} $insertingMarker'.trim();
        jobRepo.remarks = jobRepo.selectedRemarksVar.text;
      }

      // Step 2: Save job with marker to Firestore
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

      // Step 3: Record to SuppliesHist/Curr (unless skip is enabled)
      if (!skipSuppliesThisJob) {
        final delta = jobRepo.paidCashAmount - previousPaidCash;
        if (delta > 0) {
          try {
            final cleanRemarks = jobRepo.selectedRemarksVar.text
                .replaceAll(insertingMarker, '')
                .trim();
            await recordCashPaymentAtomicTransaction(
              context,
              jobRepo,
              delta,
              cleanRemarks,
            );
          } catch (e) {
            debugPrint('Error recording supplies: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to record supplies: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            return;
          }
        }
      } else {
        // Step 3b: Add skip recording remark if skip is enabled
        const skipRecordingRemark = 'Skip funds recording';
        if (!jobRepo.remarks.contains(skipRecordingRemark)) {
          jobRepo.selectedRemarksVar.text =
              '${jobRepo.selectedRemarksVar.text} $skipRecordingRemark'.trim();
          jobRepo.remarks = jobRepo.selectedRemarksVar.text;
        }
      }

      // Step 4: Remove marker from remarks
      jobRepo.selectedRemarksVar.text = jobRepo.selectedRemarksVar.text
          .replaceAll(insertingMarker, '')
          .trim();
      jobRepo.remarks = jobRepo.selectedRemarksVar.text;

      // Step 5: Save job without marker to Firestore
      try {
        await callDatabaseUpdateJob(context, jobRepo.jobModelData);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment recorded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to update job after supplies recording: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to finalize payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // No paidCash, but might have paidGCash verified - just save the job
      try {
        await callDatabaseUpdateJob(context, jobRepo.jobModelData);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to update job: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
                    // Admin-only: staff salary deduction toggle (only if CUSTOMER is a staff)
                    if (isAdmin &&
                        jobRepo.selectedCustomerId > 0 &&
                        empNameToId.containsKey(jobRepo.customerName))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.red.withValues(alpha: 0.1),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Staff Salary Deduction',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                    Text(
                                      'Deduct ₱${jobRepo.selectedFinalPrice - (int.tryParse(jobRepo.repoVarCashAmountVar.text.replaceAll(',', '')) ?? 0)} from ${jobRepo.customerName}\'s salary',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: useStaffSalaryDeduction,
                                activeThumbColor: Colors.red,
                                activeTrackColor:
                                    Colors.red.withValues(alpha: 0.5),
                                onChanged: (v) =>
                                    setState(() => useStaffSalaryDeduction = v),
                              ),
                            ],
                          ),
                        ),
                      ),
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
