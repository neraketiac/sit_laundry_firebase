import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/loyalty/pages/loyalty_single_full.dart';

void showReceipt(BuildContext context, JobModelRepository jobRepo,
    {bool isTemporary = false}) {
  jobRepo.syncRepoToSelectedAll(jobRepo);

  String formatDate(Timestamp ts) {
    final d = ts.toDate();
    return "${d.month.toString().padLeft(2, '0')}/"
        "${d.day.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  /// ITEM SUBTOTAL
  int itemSubtotal = 0;
  for (var item in jobRepo.items) {
    itemSubtotal += item.itemPrice;
  }

  /// PAYMENT
  int paidTotal = jobRepo.paidCashAmount + jobRepo.paidGCashAmount;
  int remaining = jobRepo.finalPrice - paidTotal;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black87;

      Widget receiptRowDark(String left, String right,
          {bool bold = false, Color? color}) {
        return Row(
          children: [
            Expanded(
              child: Text(
                left,
                style: TextStyle(
                  fontFamily: "Courier",
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? textColor,
                ),
              ),
            ),
            Text(
              right,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: "Courier",
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? textColor,
              ),
            ),
          ],
        );
      }

      Widget receiptCenterDark(String text, {bool bold = false}) {
        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Courier",
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        );
      }

      Widget receiptDividerDark() {
        return Text(
          "--------------------------------",
          style: TextStyle(
              fontFamily: "Courier",
              color: isDark ? Colors.grey.shade600 : Colors.black87),
        );
      }

      return Dialog(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          color: bgColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                receiptCenterDark("W A S H * K O * L A N G", bold: true),
                receiptCenterDark("Laundry Hub"),
                const SizedBox(height: 6),
                if (isTemporary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        "⚠️ TEMPORARY RECEIPT ⚠️",
                        style: TextStyle(
                          fontFamily: "Courier",
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                if (isTemporary)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        "This is not the final receipt.",
                        style: TextStyle(
                          fontFamily: "Courier",
                          fontSize: 10,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                  ),
                receiptDividerDark(),
                receiptRowDark("Queue No.", "#${jobRepo.jobId}"),
                receiptRowDark(
                    "Date",
                    isTemporary
                        ? formatDate(Timestamp.now())
                        : formatDate(jobRepo.dateD)),
                receiptRowDark("Customer", jobRepo.customerName),
                receiptRowDark("Address", jobRepo.address),
                receiptRowDark("Customer ID", jobRepo.customerId.toString()),
                receiptDividerDark(),
                if (jobRepo.regular || jobRepo.sayosabon) ...[
                  receiptCenterDark("DETAILS"),
                  receiptDividerDark(),
                  if (jobRepo.regular) receiptRowDark('Full Service 155', ''),
                  if (jobRepo.sayosabon) receiptRowDark('Sayo Sabon 125', ''),
                  receiptRowDark(
                      jobRepo.pricingSetup, "₱${jobRepo.finalPrice}"),
                ],
                receiptDividerDark(),
                if (jobRepo.items.isNotEmpty) ...[
                  receiptCenterDark("ITEMS"),
                  receiptDividerDark(),
                  for (var item in jobRepo.items)
                    receiptRowDark(item.itemName, "₱${item.itemPrice}"),
                  receiptDividerDark(),
                  receiptRowDark("Item Subtotal", "₱$itemSubtotal", bold: true),
                ],
                if (jobRepo.basket > 0 ||
                    jobRepo.ebag > 0 ||
                    jobRepo.sako > 0) ...[
                  receiptDividerDark(),
                  receiptCenterDark("CONTAINERS"),
                  if (jobRepo.basket > 0)
                    receiptRowDark("Basket", "${jobRepo.basket}"),
                  if (jobRepo.ebag > 0)
                    receiptRowDark("Eco Bag", "${jobRepo.ebag}"),
                  if (jobRepo.sako > 0)
                    receiptRowDark("Sako", "${jobRepo.sako}"),
                ],
                receiptDividerDark(),
                receiptRowDark("TOTAL", "₱${jobRepo.finalPrice}", bold: true),
                if (paidTotal > 0 && jobRepo.paidCash)
                  receiptRowDark("PAID", "₱$paidTotal"),
                if (paidTotal > 0 &&
                    jobRepo.paidGCash &&
                    !jobRepo.paidGCashVerified)
                  receiptRowDark("GCash Pending", "₱$paidTotal"),
                if (jobRepo.unpaid)
                  if (remaining > 0)
                    receiptRowDark(
                      jobRepo.unpaid ? "UNPAID" : "BALANCE",
                      "₱$remaining",
                      bold: true,
                      color: Colors.red.shade400,
                    ),
                receiptDividerDark(),
                if (jobRepo.remarks.isNotEmpty)
                  Text(
                    "Remarks: ${jobRepo.remarks}",
                    style: TextStyle(fontFamily: "Courier", color: textColor),
                  ),
                // GCash Receipt Screenshot - if available
                if (jobRepo.gcashReceiptUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "GCash Receipt Screenshot",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      maxWidth: 280,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        jobRepo.gcashReceiptUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.red.shade400),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                receiptCenterDark("Thank you for choosing"),
                receiptCenterDark("WASH KO LANG"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE"),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyLoyaltyCardFull(
                                  jobRepo.customerId.toString()),
                            ),
                          );
                        },
                        child: const Text('View Card'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
