import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';

Expanded visNameArea(JobModel job, bool isSelected) {
  final primaryColor = isSelected ? Colors.deepPurple : Colors.black87;

  final secondaryColor =
      isSelected ? Colors.deepPurple.shade300 : Colors.grey.shade700;

  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// 🔹 CUSTOMER NAME + LOAD
        Row(
          children: [
            Flexible(
              child: Text(
                '${displayCustomerName(job.customerName)} '
                '(${job.finalLoad})',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              textBagDetails(job),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        /// 🔹 SHORTCUT EXTRAS
        if (job.items.isNotEmpty)
          Text(
            textDetFabBleExtras(job.items),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),

        const SizedBox(height: 2),

        /// 🔹 STATUS
        Text(
          textJobStatus(job),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: job.forSorting
                ? Colors.deepPurple.shade400
                : Colors.redAccent.shade200,
          ),
        ),

        /// 🔹 PRICING / REMARKS
        if (job.pricingSetup.isNotEmpty ||
            job.remarks.isNotEmpty ||
            (job.unpaid && job.paidCash || job.unpaid && job.paidGCash))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              textPricingSetupRemarksUnpaidRemakrs(job),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple.shade300,
              ),
            ),
          ),
      ],
    ),
  );
}
