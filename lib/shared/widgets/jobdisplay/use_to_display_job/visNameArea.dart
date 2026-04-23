import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';

Expanded visNameArea(JobModel job, bool isSelected) {
  return Expanded(
    child: Builder(builder: (context) {
      final s = AppScale.of(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final primaryColor = isSelected
          ? Colors.deepPurple.shade200
          : isDark
              ? Colors.white
              : Colors.black87;
      final secondaryColor = isSelected
          ? Colors.deepPurple.shade200
          : isDark
              ? Colors.white70
              : Colors.grey.shade700;
      final statusColor = job.forSorting
          ? (isDark ? Colors.deepPurple.shade200 : Colors.black)
          : (job.isDeliveredToCustomer || job.isCustomerPickedUp)
              ? Colors.green.shade400
              : job.riderPickup
                  ? Colors.green.shade400
                  : Colors.redAccent.shade200;

      final dateStr = textDateDone(job);
      final daysDiff = _daysSince(job);
      final dateBg = _dateBgColor(daysDiff, isDark);
      final dateTextColor = _dateTextColor(daysDiff);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Name + load + bag details
          Row(
            children: [
              Flexible(
                child: Text(
                  '${displayCustomerName(job.customerName)} (${job.finalLoad})',
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

          // Items
          if (textDetFabBleExtras(job.items).isNotEmpty ||
              job.address.isNotEmpty)
            Text(
              '${job.address} ${textDetFabBleExtras(job.items)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: s.small,
                fontWeight: FontWeight.w500,
                color: secondaryColor,
              ),
            ),
          SizedBox(height: s.gapSmall / 2),

          // Status label
          Text(
            textJobStatus(job),
            style: TextStyle(
              fontSize: s.small,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),

          // Date badge (separate line)
          if (dateStr != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: dateBg != null
                    ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                    : EdgeInsets.zero,
                decoration: dateBg != null
                    ? BoxDecoration(
                        color: dateBg,
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: s.small,
                    fontWeight: FontWeight.w600,
                    color: dateTextColor ?? statusColor,
                  ),
                ),
              ),
            ),

          // Pricing / remarks / unpaid details
          if (job.remarks.trim().isNotEmpty)
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
                      : isDark
                          ? Colors.deepPurple.shade200
                          : Colors.deepPurple.shade300,
                ),
              ),
            ),
        ],
      );
    }),
  );
}

int _daysSince(JobModel job) {
  final d = job.dateD.toDate();
  if (d.year <= 1900) return 0;
  return DateTime.now().difference(d).inDays;
}

Color? _dateBgColor(int days, bool isDark) {
  if (days > 30) return isDark ? Colors.grey.shade700 : Colors.black;
  if (days > 14) return Colors.red.shade600;
  if (days > 7) return Colors.amber.shade700;
  return null;
}

Color? _dateTextColor(int days) {
  if (days > 7) return Colors.white;
  return null; // use statusColor fallback
}
