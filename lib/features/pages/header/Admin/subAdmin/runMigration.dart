import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';

const List<String> _forthCollections = [
  'loyalty',
  JOBS_DONE_REF,
  JOBS_COMPLETED_REF,
];

class RunMigration extends StatefulWidget {
  const RunMigration({super.key});

  @override
  State<RunMigration> createState() => _RunMigrationState();
}

class _RunMigrationState extends State<RunMigration> {
  bool _deleteBeforeMigrate = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "Migrate to Forth DB",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Move data from main firestore to forth database.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const Text("Collections to migrate:"),
        const SizedBox(height: 6),
        ..._forthCollections.map(
          (col) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.grey),
                const SizedBox(width: 8),
                Text(col),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Delete destination before migrating"),
          subtitle: const Text(
            "Clears collections in forth database before writing",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          value: _deleteBeforeMigrate,
          onChanged: (val) => setState(() => _deleteBeforeMigrate = val),
          activeThumbColor: Colors.red,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _confirmAndMigrate(context),
          icon: const Icon(Icons.sync_alt),
          label: const Text("Run Migration"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _confirmAndMigrate(BuildContext context) async {
    final deleteFirst = _deleteBeforeMigrate;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Migration"),
        content: Text(
          "${deleteFirst ? '⚠️ DELETE then migrate' : 'Migrate'} the following collections to forth database?\n\n${_forthCollections.join('\n')}"
          "${deleteFirst ? '\n\nDestination docs will be permanently deleted first.' : ''}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: deleteFirst
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(deleteFirst ? "Delete & Migrate" : "Yes"),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final progressKey = GlobalKey<_MigrationProgressDialogState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MigrationProgressDialog(key: progressKey),
    );

    final main = FirebaseService.primaryFirestore;
    final forth = FirebaseService.forthFirestore;

    bool success = true;
    String resultMessage = "";

    try {
      // Step 1: delete destination if requested
      if (deleteFirst) {
        progressKey.currentState?.setStatus("Deleting destination...");
        for (final col in _forthCollections) {
          final snap = await forth.collection(col).get();
          WriteBatch batch = forth.batch();
          int ops = 0;
          for (final doc in snap.docs) {
            batch.delete(doc.reference);
            ops++;
            if (ops == 500) {
              await batch.commit();
              batch = forth.batch();
              ops = 0;
            }
          }
          if (ops > 0) await batch.commit();
        }
      }

      // Step 2: count source docs
      progressKey.currentState?.setStatus("Counting documents...");
      int totalDocs = 0;
      for (final col in _forthCollections) {
        final snap = await main.collection(col).get();
        totalDocs += snap.docs.length;
      }

      int processed = 0;

      // Step 3: migrate
      progressKey.currentState?.setStatus("Migrating to Forth DB...");
      for (final col in _forthCollections) {
        final snap = await main.collection(col).get();
        WriteBatch batch = forth.batch();
        int ops = 0;
        int colCount = 0;

        for (final doc in snap.docs) {
          batch.set(
            forth.collection(col).doc(doc.id),
            doc.data(),
            SetOptions(merge: false),
          );
          ops++;
          colCount++;
          processed++;

          progressKey.currentState?.update(
            totalDocs > 0 ? processed / totalDocs : 0,
            processed,
            totalDocs,
          );

          if (ops == 500) {
            await batch.commit();
            batch = forth.batch();
            ops = 0;
          }
        }

        if (ops > 0) await batch.commit();
        resultMessage += "$col: $colCount docs\n";
      }
    } catch (e) {
      success = false;
      resultMessage = "Error: $e";
    }

    if (!context.mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? "Migration Complete" : "Migration Failed"),
        content: Text(
          success
              ? "SUCCESS: YES\n\nMigrated to forth database:\n$resultMessage"
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
}

class _MigrationProgressDialog extends StatefulWidget {
  const _MigrationProgressDialog({super.key});

  @override
  State<_MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<_MigrationProgressDialog> {
  double progress = 0;
  int processed = 0;
  int total = 0;
  String status = "Preparing...";

  void update(double value, int p, int t) {
    setState(() {
      progress = value;
      processed = p;
      total = t;
    });
  }

  void setStatus(String s) {
    setState(() => status = s);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Migrating to Forth DB..."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress > 0 ? progress : null),
          const SizedBox(height: 12),
          Text("${(progress * 100).toStringAsFixed(0)}%"),
          const SizedBox(height: 4),
          Text("$processed / $total docs"),
        ],
      ),
    );
  }
}
