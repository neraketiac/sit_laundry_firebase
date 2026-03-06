import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/main.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';

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

  /// SHOW LOADING
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final main = FirebaseFirestore.instance;
  final secondary = secondaryFirestore;

  const collectionsToMigrate = [
    'loyalty',
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  bool success = true;
  String resultMessage = "";

  try {
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

  /// CLOSE LOADING
  Navigator.pop(context);

  /// SHOW RESULT
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
