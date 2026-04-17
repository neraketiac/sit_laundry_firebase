import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';

Expanded visNameArea(JobModel job, bool isSelected) {
  return Expanded(
    child: Builder(builder: (context) {
      final s = AppScale.of(context);
      final primaryColor = isSelected ? Colors.deepPurple : Colors.black87;
      final secondaryColor =
          isSelected ? Colors.deepPurple.shade300 : Colors.grey.shade700;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${displayCustomerName(job.customerName)} '
                  '(${job.finalLoad})',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: s.body,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(width: s.gapSmall),
              Text(
                textBagDetails(job),
                style: TextStyle(
                  fontSize: s.small,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: s.gapSmall / 2),
          if (job.items.isNotEmpty)
            Text(
              textDetFabBleExtras(job.items),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: s.small,
                fontWeight: FontWeight.w500,
                color: secondaryColor,
              ),
            ),
          SizedBox(height: s.gapSmall / 2),
          Text(
            textJobStatus(job),
            style: TextStyle(
              fontSize: s.small,
              fontWeight: FontWeight.w600,
              color: job.forSorting
                  ? Colors.deepPurple.shade400
                  : Colors.redAccent.shade200,
            ),
          ),
          if (job.pricingSetup.isNotEmpty ||
              job.remarks.isNotEmpty ||
              (job.unpaid && job.paidCash || job.unpaid && job.paidGCash))
            Padding(
              padding: EdgeInsets.only(top: s.gapSmall / 2),
              child: Text(
                textPricingSetupRemarksUnpaidRemakrs(job),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: s.small,
                  fontWeight: FontWeight.w500,
                  color: (job.unpaid && job.paidCash)
                      ? Colors.deepOrange
                      : Colors.deepPurple.shade300,
                ),
              ),
            ),
        ],
      );
    }),
  );
}
