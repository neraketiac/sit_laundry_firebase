import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';

void showReceipt(BuildContext context, JobModelRepository jobRepo) {
  syncRepoToSelectedALL(jobRepo);

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

  /// RECEIPT ROW
  Widget receiptRow(String left, String right,
      {bool bold = false, Color? color}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontFamily: "Courier",
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ),
        Text(
          right,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: "Courier",
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  /// CENTER TEXT
  Widget receiptCenter(String text, {bool bold = false}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Courier",
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// DIVIDER
  Widget receiptDivider() {
    return const Text(
      "--------------------------------",
      style: TextStyle(fontFamily: "Courier"),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                receiptCenter("W A S H * K O * L A N G", bold: true),
                receiptCenter("Laundry Service"),

                const SizedBox(height: 6),

                receiptDivider(),

                /// JOB ID
                receiptRow("Queue No.", "#${jobRepo.jobId}"),

                /// DATE
                receiptRow("Date", formatDate(jobRepo.dateD)),

                /// CUSTOMER
                receiptRow("Customer", jobRepo.customerName),

                /// CUSTOMER Address
                receiptRow("Address", jobRepo.address),

                /// ID
                receiptRow("Customer ID", jobRepo.customerId.toString()),

                receiptDivider(),

                /// PRICING SETUP for REGULAR and SS only
                if (jobRepo.regular || jobRepo.sayosabon) ...[
                  receiptCenter("DETAILS"),
                  receiptDivider(),
                  if (jobRepo.regular) receiptRow('Full Service 155', ''),
                  if (jobRepo.sayosabon) receiptRow('Sayo Sabon 125', ''),
                  receiptRow(jobRepo.pricingSetup, "₱${jobRepo.finalPrice}"),
                ],

                receiptDivider(),

                /// ITEMS
                if (jobRepo.items.isNotEmpty) ...[
                  receiptCenter("ITEMS"),
                  receiptDivider(),
                  for (var item in jobRepo.items)
                    receiptRow(item.itemName, "₱${item.itemPrice}"),
                  receiptDivider(),
                  receiptRow(
                    "Item Subtotal",
                    "₱$itemSubtotal",
                    bold: true,
                  ),
                ],

                /// CONTAINERS
                if (jobRepo.basket > 0 ||
                    jobRepo.ebag > 0 ||
                    jobRepo.sako > 0) ...[
                  receiptDivider(),
                  receiptCenter("CONTAINERS"),
                  if (jobRepo.basket > 0)
                    receiptRow("Basket", "${jobRepo.basket}"),
                  if (jobRepo.ebag > 0)
                    receiptRow("Eco Bag", "${jobRepo.ebag}"),
                  if (jobRepo.sako > 0) receiptRow("Sako", "${jobRepo.sako}"),
                ],

                receiptDivider(),

                /// TOTAL
                receiptRow(
                  "TOTAL",
                  "₱${jobRepo.finalPrice}",
                  bold: true,
                ),

                /// PAID
                if (paidTotal > 0 && jobRepo.paidCash)
                  receiptRow(
                    "PAID",
                    "₱$paidTotal",
                  ),

                if (paidTotal > 0 &&
                    jobRepo.paidGCash &&
                    !jobRepo.paidGCashVerified)
                  receiptRow(
                    "GCash Pending",
                    "₱$paidTotal",
                  ),

                /// BALANCE / UNPAID
                if (jobRepo.unpaid)
                  if (remaining > 0)
                    receiptRow(
                      jobRepo.unpaid ? "UNPAID" : "BALANCE",
                      "₱$remaining",
                      bold: true,
                      color: jobRepo.unpaid ? Colors.red : null,
                    ),

                receiptDivider(),

                /// REMARKS
                if (jobRepo.remarks.isNotEmpty)
                  Text(
                    "Remarks: ${jobRepo.remarks}",
                    style: const TextStyle(fontFamily: "Courier"),
                  ),

                const SizedBox(height: 8),

                receiptCenter("Thank you for choosing"),
                receiptCenter("WASH KO LANG"),

                const SizedBox(height: 12),

                /// CLOSE BUTTON
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("CLOSE"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
