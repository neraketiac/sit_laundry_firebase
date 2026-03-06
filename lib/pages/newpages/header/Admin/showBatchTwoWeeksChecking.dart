import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> showBatchTwoWeeksChecking(BuildContext context) async {
  /// Ask confirmation first
  final bool? proceed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirm Batch Process"),
        content: const Text(
          "This process will scan job records in DONE and COMPLETED collections.\n\n"
          "For each customer, the system will evaluate job gaps.\n"
          "If the gap between jobs exceeds 2 weeks, the job will be marked "
          "as the promo boundary (isPromoCounter = false).\n\n"
          "Do you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );

  if (proceed != true) return;

  try {
    final firestore = FirebaseFirestore.instance;

    const String JOBS_DONE_REF = "Jobs_done";
    const String JOBS_COMPLETED_REF = "Jobs_completed";

    const collectionsToCheck = [JOBS_DONE_REF, JOBS_COMPLETED_REF];

    final Map<String, List<QueryDocumentSnapshot>> jobsByCustomer = {};

    int totalJobsScanned = 0;
    int totalCustomersProcessed = 0;
    int totalUpdates = 0;

    /// --------------------------------
    /// STEP 1: Load jobs and group by customer
    /// --------------------------------
    for (final col in collectionsToCheck) {
      final snapshot = await firestore
          .collection(col)
          //.where('C00_CustomerId', isEqualTo: 7151)
          .orderBy('A05_DateD', descending: true)
          .get();

      for (final doc in snapshot.docs) {
        totalJobsScanned++;

        final data = doc.data();
        final customerId = data['C00_CustomerId']?.toString();

        if (customerId == null) continue;

        jobsByCustomer.putIfAbsent(customerId, () => []).add(doc);
      }
    }

    WriteBatch batch = firestore.batch();
    int batchCount = 0;

    /// --------------------------------
    /// STEP 2: Process each customer
    /// --------------------------------
    for (final entry in jobsByCustomer.entries) {
      final customerId = entry.key;
      final jobs = entry.value;

      /// ensure newest job first
      jobs.sort((a, b) {
        final aDate =
            (a.data() as Map<String, dynamic>)['A05_DateD'] as Timestamp?;
        final bDate =
            (b.data() as Map<String, dynamic>)['A05_DateD'] as Timestamp?;

        if (aDate == null || bDate == null) return 0;

        return bDate.compareTo(aDate); // DESCENDING
      });

      DateTime previousDate = DateTime.now(); // JobX
      bool boundaryFound = false;

      //print("Processing order for $customerId");

      for (final doc in jobs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        final bool unpaid = data['P00_Unpaid'] ?? false;
        final Timestamp? ts = data['A05_DateD'] as Timestamp?;
        //print(ts?.toDate());

        if (ts == null) continue;

        final DateTime jobDate = ts.toDate();

        final gap = previousDate.difference(jobDate);

        /// within 2 weeks
        //print('gap=${gap.inDays}');
        if (gap.inDays <= 14) {
          if (data['Z01_IsPromoCounter'] != true) {
            batch.update(doc.reference, {'Z01_IsPromoCounter': true});
            totalUpdates++;
            batchCount++;
          }
          //only change previousDate if paid if not, dont change previous date
          if (!unpaid && data['Q06_PromoCounter'] > 0) {
            previousDate = jobDate;
          }

          continue;
        }

        /// gap > 14 days → boundary
        if (data['Z01_IsPromoCounter'] != false || unpaid) {
          batch.update(doc.reference, {'Z01_IsPromoCounter': false});
          totalUpdates++;
          batchCount++;
        }

        // /// Skip unpaid jobs
        // if (unpaid) continue;

        //stop checking next jobs, commented only on first run to false all non-eligible
        boundaryFound = true;
        break; // stop checking older jobs
      }

      if (boundaryFound || jobs.isNotEmpty) {
        totalCustomersProcessed++;
      }

      /// Firestore batch limit protection
      if (batchCount >= 450) {
        await batch.commit();
        batch = firestore.batch();
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    showProcessSummary(
      context,
      totalJobsScanned,
      totalCustomersProcessed,
      totalUpdates,
    );

    debugPrint("========== PROMO PROCESS COMPLETE ==========");
    debugPrint("Jobs scanned: $totalJobsScanned");
    debugPrint("Customers processed: $totalCustomersProcessed");
    debugPrint("Records updated: $totalUpdates");
    debugPrint("============================================");
  } catch (e, stack) {
    debugPrint("Batch process error: $e");
    debugPrintStack(stackTrace: stack);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Process Failed"),
        content: Text(
          "An error occurred while processing the promo counter.\n\n$e",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

void showProcessSummary(
  BuildContext context,
  int jobsScanned,
  int customersProcessed,
  int updates,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Process Completed"),
        content: Text(
          "Promo counter processing finished.\n\n"
          "Jobs scanned: $jobsScanned\n"
          "Customers processed: $customersProcessed\n"
          "Records updated: $updates",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
