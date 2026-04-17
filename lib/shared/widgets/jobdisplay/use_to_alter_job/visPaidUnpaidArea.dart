import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/showPaidUnpaid.dart';

InkWell visPaidUnpaidArea(
  BuildContext context,
  JobModelRepository jobRepo,
  bool isSelected,
  bool alterPaidUnpaid,
) {
  final bool isPaid = !jobRepo.selectedUnpaid;

  final Color paidColor = isSelected ? Colors.deepPurple : Colors.black87;

  final Color unpaidColor = Colors.redAccent;

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

  return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        if (!alterPaidUnpaid) return;

        // If already paid — only admin can change it back
        if (!jobRepo.selectedUnpaid) {
          if (!isAdmin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Payment is already recorded. Only admin can change it.'),
                backgroundColor: Colors.redAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
          // Admin — confirm before allowing change
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Admin Override'),
              content: const Text(
                  'This job is already paid. Are you sure you want to change the payment?'),
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
              // > 14 days — admin override only
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Over Two Weeks Unpaid'),
                  content: Text(isAdmin
                      ? 'This item is more than two weeks unpaid. Admin override — are you sure?'
                      : 'This item is more than two weeks unpaid. Cannot change payment status.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    if (isAdmin)
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
          // Reset selected payment state from the actual job model
          // before opening the dialog — prevents bleed from previous job
          jobRepo.selectedUnpaid = jobRepo.unpaid;
          jobRepo.selectedPaidCash = jobRepo.paidCash;
          jobRepo.selectedPaidGCash = jobRepo.paidGCash;
          jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;
          jobRepo.selectedPaidCashAmount = jobRepo.paidCashAmount;
          jobRepo.selectedPaidGCashAmount = jobRepo.paidGCashAmount;
          showPaidUnpaid(context, jobRepo);
        }
      },
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 100, // fixed width keeps star position stable
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: [
                  if (jobRepo.thisJobHasPromo)
                    Positioned(
                      left: 60,
                      top: -16,
                      child: Icon(
                        Icons.star,
                        size: 50,
                        color: Colors.amber.withOpacity(0.5),
                      ),
                    ),
                  Text(
                    "₱ ${jobRepo.selectedFinalPrice}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isPaid
                    ? Colors.greenAccent.withOpacity(0.15)
                    : Colors.redAccent.withOpacity(0.15),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ]));
}
