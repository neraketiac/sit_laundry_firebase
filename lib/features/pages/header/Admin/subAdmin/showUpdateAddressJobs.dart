import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class ShowUpdateAddressJobs extends StatelessWidget {
  const ShowUpdateAddressJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "Address Sync",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Sync job address from loyalty records"),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => runAddressSync(context),
          child: const Text("Run Address Sync"),
        ),
      ],
    );
  }
}

class AddressSyncProgressDialog extends StatefulWidget {
  const AddressSyncProgressDialog({super.key});

  @override
  State<AddressSyncProgressDialog> createState() =>
      AddressSyncProgressDialogState();
}

class AddressSyncProgressDialogState extends State<AddressSyncProgressDialog> {
  double progress = 0;
  int processed = 0;
  int total = 0;

  void update(double value, int p, int t) {
    setState(() {
      progress = value;
      processed = p;
      total = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Running Address Sync"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 15),
          Text("${(progress * 100).toStringAsFixed(0)}%"),
          const SizedBox(height: 5),
          Text("$processed / $total docs"),
        ],
      ),
    );
  }
}

Future<void> runAddressSync(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Sync"),
      content: const Text(
          "This will update job addresses from loyalty records.\n\nContinue?"),
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
    ),
  );

  if (confirm != true) return;

  final progressKey = GlobalKey<AddressSyncProgressDialogState>();

  /// SHOW PROGRESS
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddressSyncProgressDialog(key: progressKey),
  );

  final firestore =
      FirebaseFirestore.instance; // used for primary DB operations

  const collections = [
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  bool success = true;
  String resultMessage = "";

  try {
    /// COUNT TOTAL JOB DOCS
    int totalDocsAll = 0;

    for (final col in collections) {
      final firestore = col == JOBS_DONE_REF
          ? FirebaseService.jobsDoneFirestore
          : FirebaseFirestore.instance;
      final snapshot = await firestore.collection(col).get();
      totalDocsAll += snapshot.docs.length;
    }

    int processedDocs = 0;
    int updatedDocs = 0;

    /// PROCESS JOBS
    for (final col in collections) {
      final firestore = col == JOBS_DONE_REF
          ? FirebaseService.jobsDoneFirestore
          : FirebaseFirestore.instance;
      final snapshot = await firestore.collection(col).get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        int customerId = data['C00_CustomerId'];

        /// FIND LOYALTY - use loyaltyCardDb (forthFirestore)
        final loyaltySnapshot = await FirebaseService.loyaltyFirestore
            .collection("loyalty")
            .where('cardNumber', isEqualTo: customerId)
            .limit(1)
            .get();

        if (loyaltySnapshot.docs.isNotEmpty) {
          final loyaltyData = loyaltySnapshot.docs.first.data();
          String address = loyaltyData['Address'] ?? "";

          await doc.reference.update({
            'C02_Address': address,
          });

          updatedDocs++;
        }

        processedDocs++;

        /// UPDATE PROGRESS
        double progress = processedDocs / totalDocsAll;

        progressKey.currentState?.update(
          progress,
          processedDocs,
          totalDocsAll,
        );
      }
    }

    resultMessage = "Updated documents: $updatedDocs";
  } catch (e) {
    success = false;
    resultMessage = "Error: $e";
  }

  /// CLOSE PROGRESS
  Navigator.pop(context);

  /// RESULT
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(success ? "Sync Complete" : "Sync Failed"),
      content: Text(
        success
            ? "SUCCESS: YES\n\n$resultMessage"
            : "SUCCESS: NO\n\n$resultMessage",
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
