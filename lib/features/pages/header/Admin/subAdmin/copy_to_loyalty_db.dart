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
  final Map<String, bool> _selected = {
    for (final c in _forthCollections) c: false,
  };
  bool _deleteBeforeMigrate = false;

  bool get _anySelected => _selected.values.any((v) => v);

  void _toggleAll(bool value) {
    setState(() {
      for (final key in _selected.keys) {
        _selected[key] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "Migrate to Update Customer Loyalty",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select collections from main to customer Loyalty DB.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
                onPressed: () => _toggleAll(true),
                child: const Text("Select All")),
            TextButton(
                onPressed: () => _toggleAll(false),
                child: const Text("Deselect All")),
          ],
        ),
        ..._forthCollections.map((col) => CheckboxListTile(
              title: Text(col),
              value: _selected[col],
              onChanged: (val) => setState(() => _selected[col] = val ?? false),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            )),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Delete destination before migrating"),
          subtitle: Text(
            _deleteBeforeMigrate
                ? "Will DELETE then overwrite — full replace"
                : "Will merge — only updates changed fields, keeps existing data",
            style: TextStyle(
              color: _deleteBeforeMigrate ? Colors.red : Colors.green.shade700,
              fontSize: 12,
            ),
          ),
          value: _deleteBeforeMigrate,
          onChanged: (val) => setState(() => _deleteBeforeMigrate = val),
          activeThumbColor: Colors.red,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _anySelected ? () => _confirmAndMigrate(context) : null,
          icon: const Icon(Icons.sync_alt),
          label: const Text("Run Migration"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _confirmAndMigrate(BuildContext context) async {
    final selected =
        _selected.entries.where((e) => e.value).map((e) => e.key).toList();
    final deleteFirst = _deleteBeforeMigrate;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Migration"),
        content: Text(
          "${deleteFirst ? '⚠️ DELETE then migrate' : 'Merge-migrate'} the following collections to forth database?\n\n${selected.join('\n')}"
          "${deleteFirst ? '\n\nDestination docs will be permanently deleted first.' : '\n\nOnly changed fields will be updated (merge mode).'}",
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
            child: Text(deleteFirst ? "Delete & Migrate" : "Yes, Merge"),
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
    final jobsDone = FirebaseService.jobsDoneFirestore;
    final forth = FirebaseService.loyaltyFirestore;

    bool success = true;
    String resultMessage = "";

    try {
      // Step 1: delete destination if requested
      if (deleteFirst) {
        progressKey.currentState?.setStatus("Deleting destination...");
        for (final col in selected) {
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
      for (final col in selected) {
        final firestore = col == JOBS_DONE_REF ? jobsDone : main;
        final snap = await firestore.collection(col).get();
        totalDocs += snap.docs.length;
      }

      int processed = 0;

      // Step 3: migrate
      progressKey.currentState?.setStatus(
        deleteFirst ? "Migrating to Forth DB..." : "Merging to Forth DB...",
      );
      for (final col in selected) {
        final firestore = col == JOBS_DONE_REF ? jobsDone : main;
        final snap = await firestore.collection(col).get();
        WriteBatch batch = forth.batch();
        int ops = 0;
        int colCount = 0;

        for (final doc in snap.docs) {
          // PRIVACY: zero out finalPrice on destination db to hide actual pricing.
          // To restore real prices, remove the _sanitize call below.
          final data = _sanitizeForDestination(col, doc.data());
          batch.set(
            forth.collection(col).doc(doc.id),
            data,
            // merge: true = only update changed fields, keep existing destination data
            // merge: false = full overwrite (used after delete)
            SetOptions(merge: !deleteFirst),
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
              ? "SUCCESS: YES\n\nMode: ${deleteFirst ? 'Full replace' : 'Merge'}\n\n$resultMessage"
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

/// Strips sensitive fields before writing to the destination (forth) database.
/// finalPrice is zeroed out for Jobs_done and Jobs_complete so the destination
/// db never contains real pricing data.
///
/// TO RESTORE real prices: remove the finalPrice override lines below,
/// or delete this function and replace _sanitizeForDestination(col, doc.data())
/// back to doc.data() in the migration loop.
Map<String, dynamic> _sanitizeForDestination(
    String collection, Map<String, dynamic> data) {
  final result = Map<String, dynamic>.from(data);
  if (collection == JOBS_DONE_REF || collection == JOBS_COMPLETED_REF) {
    result['Q06_FinalPrice'] = 0; // ← remove this line to restore real prices
  }
  return result;
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
