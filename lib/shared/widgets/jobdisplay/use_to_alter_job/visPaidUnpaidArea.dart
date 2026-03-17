import 'package:flutter/material.dart';
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
      onTap: () {
        if (alterPaidUnpaid) showPaidUnpaid(context, jobRepo);
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
