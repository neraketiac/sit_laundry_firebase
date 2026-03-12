import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';

class RunMigration extends StatelessWidget {
  const RunMigration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "Migration",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Move data to secondary"),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => runMigration(context),
          child: const Text("Run Migration"),
        ),
      ],
    );
  }
}

class MigrationProgressDialog extends StatefulWidget {
  const MigrationProgressDialog({super.key});

  @override
  State<MigrationProgressDialog> createState() =>
      MigrationProgressDialogState();
}

class MigrationProgressDialogState extends State<MigrationProgressDialog> {
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
      title: const Text("Running Migration"),
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

Future<void> runMigration(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Migration"),
      content: const Text(
          "This will migrate data to the secondary database.\n\nContinue?"),
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

  final progressKey = GlobalKey<MigrationProgressDialogState>();

  /// SHOW PROGRESS DIALOG
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => MigrationProgressDialog(key: progressKey),
  );

  final main = FirebaseService.primaryFirestore;
  final secondary = FirebaseService.secondaryFirestore;

  const collectionsToMigrate = [
    'loyalty',
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  bool success = true;
  String resultMessage = "";

  try {
    /// STEP 1: Count total docs
    int totalDocsAll = 0;

    for (final collectionName in collectionsToMigrate) {
      final snapshot = await main.collection(collectionName).get();
      totalDocsAll += snapshot.docs.length;
    }

    int processedDocs = 0;

    /// STEP 2: Migration
    for (final collectionName in collectionsToMigrate) {
      debugPrint("🔄 Migrating collection: $collectionName");

      final snapshot = await main.collection(collectionName).get();

      WriteBatch batch = secondary.batch();
      int operationCount = 0;
      int totalDocs = 0;

      for (final doc in snapshot.docs) {
        final secondaryRef = secondary.collection(collectionName).doc(doc.id);

        batch.set(
          secondaryRef,
          doc.data(),
          SetOptions(merge: false),
        );

        operationCount++;
        totalDocs++;
        processedDocs++;

        /// UPDATE PROGRESS
        double progress = processedDocs / totalDocsAll;

        progressKey.currentState?.update(
          progress,
          processedDocs,
          totalDocsAll,
        );

        if (operationCount == 500) {
          await batch.commit();
          batch = secondary.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      resultMessage += "$collectionName : $totalDocs docs\n";

      debugPrint("✅ Finished $collectionName | Documents: $totalDocs");
    }
  } catch (e) {
    success = false;
    resultMessage = "Error: $e";
  }

  /// CLOSE PROGRESS DIALOG
  Navigator.pop(context);

  /// RESULT
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(success ? "Migration Complete" : "Migration Failed"),
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
