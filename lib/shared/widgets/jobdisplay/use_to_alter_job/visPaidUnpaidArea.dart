import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/showPaidUnpaid.dart';

InkWell visPaidUnpaidArea(
  BuildContext context,
  JobModelRepository jobRepo,
  bool isSelected,
  bool alterPaidUnpaid,
) {
  final bool isPaid = !jobRepo.selectedUnpaid;
  final bool hasRecordedPayment = jobRepo.paidCash ||
      jobRepo.paidGCash ||
      jobRepo.paidCashAmount > 0 ||
      jobRepo.paidGCashAmount > 0;

  final Color paidColor = isSelected ? Colors.deepPurple : Colors.black87;

  // KULANG = unpaid but has partial CASH payment (not enough cash)
  // GCash unverified is "GCash Pending", not KULANG
  final bool isKulang = jobRepo.selectedUnpaid && jobRepo.selectedPaidCash;

  final Color unpaidColor = isKulang ? Colors.purpleAccent : Colors.redAccent;

  final Color statusColor = isPaid ? paidColor : unpaidColor;

  final String statusText = jobRepo.selectedUnpaid
      ? (jobRepo.selectedPaidGCash ? "GCash Pending" : "Unpaid")
      : jobRepo.selectedPaidCash
          ? "Paid • Cash"
          : jobRepo.selectedPaidGCash
              ? "Paid • GCash"
              : "Paid";

  //prioritize order check
  // unpaid = cash not enough
  // unpaid = gcash not enough
  // unpaid = cash + gcash not enough
  // unpaid = gcash not verified
  // unpaid = cash + gcash + not verified

  Future<bool> requestAdminApproval({
    required String title,
    required String description,
  }) async {
    final remarksCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksCtrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks (required)',
                hintText: 'Reason for admin request...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              if (remarksCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter remarks.')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    final appendedRemarks = jobRepo.remarks.isEmpty
        ? '[Rt] ${remarksCtrl.text.trim()}'
        : '${jobRepo.remarks} | [R] ${remarksCtrl.text.trim()}';

    final collection = jobRepo.processStep == 'completed'
        ? JOBS_COMPLETED_REF
        : jobRepo.processStep == 'done'
            ? JOBS_DONE_REF
            : (jobRepo.processStep == 'waiting' ||
                    jobRepo.processStep == 'washing' ||
                    jobRepo.processStep == 'drying' ||
                    jobRepo.processStep == 'folding')
                ? JOBS_ONGOING_REF
                : JOBS_QUEUE_REF;

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(jobRepo.docId)
        .update({
      'Z02_RequestForAdmin': true,
      'R00_Remarks': appendedRemarks,
      if (collection == JOBS_DONE_REF || collection == JOBS_COMPLETED_REF)
        SYNC_TO_DB2_FIELD: false,
    });

    jobRepo.requestForAdmin = true;
    jobRepo.remarks = appendedRemarks;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent. Admin will review.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    return true;
  }

  return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        if (!alterPaidUnpaid) return;

        // Once any payment is recorded, only admin can change it.
        if (hasRecordedPayment) {
          if (!isAdmin) {
            await requestAdminApproval(
              title: 'Request Payment Change',
              description:
                  'Payment details are already recorded for this job. Only admin can change them now.',
            );
            return;
          }

          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Admin Override'),
              content: const Text(
                  'Payment details are already recorded. Are you sure you want to change them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Override',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
          if (confirm != true) return;
        }

        // Only check when currently unpaid and trying to change to paid
        if (jobRepo.selectedUnpaid) {
          final doneDate = jobRepo.dateD;
          // Skip check if dateD is the default epoch (not yet set)
          final epoch = DateTime(1900);
          final doneDt = doneDate.toDate();
          if (doneDt.isAfter(epoch)) {
            final now = DateTime.now();
            final daysDiff = now.difference(doneDt).inDays;

            if (daysDiff > 14) {
              if (!isAdmin) {
                await requestAdminApproval(
                  title: 'Request to Paid',
                  description:
                      'This job is over 2 weeks unpaid. You can request admin approval to mark it as paid.',
                );
                return;
              }

              // Admin > 14 days: override confirm
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Over Two Weeks Unpaid'),
                  content: const Text(
                      'This item is more than two weeks unpaid. Admin override — are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Override',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
            } else if (daysDiff > 7) {
              // 8–14 days — warn and confirm
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text(
                      'This item is already two weeks unpaid. Are you sure you want to change the payment status?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
            }
            // <= 7 days — no message, proceed directly
          }
        }

        if (context.mounted) {
          // For admin override on already-paid job: keep current selected state
          // so admin can freely change it. Only reset for unpaid→paid flow.
          if (jobRepo.selectedUnpaid) {
            jobRepo.selectedUnpaid = jobRepo.unpaid;
            jobRepo.selectedPaidCash = jobRepo.paidCash;
            jobRepo.selectedPaidGCash = jobRepo.paidGCash;
            jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;
            jobRepo.selectedPaidCashAmount = jobRepo.paidCashAmount;
            jobRepo.selectedPaidGCashAmount = jobRepo.paidGCashAmount;
          }
          showPaidUnpaid(context, jobRepo);
        }
      },
      child: Builder(builder: (ctx) {
        final s = AppScale.of(ctx);
        return IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerRight,
                    children: [
                      if (jobRepo.thisJobHasPromo)
                        Positioned(
                          right: 0,
                          top: -16,
                          child: Icon(
                            Icons.star,
                            size: s.iconLarge,
                            color: Colors.amber.withOpacity(0.5),
                          ),
                        ),
                      Text(
                        "₱ ${jobRepo.selectedFinalPrice}",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: s.bodyLarge,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s.gapSmall / 2),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: s.gap,
                      vertical: s.gapSmall / 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(s.cardRadius - 2),
                      color: isPaid
                          ? Colors.greenAccent.withOpacity(0.15)
                          : Colors.redAccent.withOpacity(0.15),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: s.tiny,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ]),
          ),
        );
      }));
}
