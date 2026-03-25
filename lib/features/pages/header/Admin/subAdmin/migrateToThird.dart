import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/firebase_options.dart';

// Known collections in main firestore — add more as needed
const List<String> _knownCollections = [
  'EmployeeCurr',
  'EmployeeHist',
  'EmployeeSetup',
  'GCash_done',
  'GCash_pending',
  'ItemsHist',
  'Jobs_completed',
  'Jobs_done',
  'SuppliesCurr',
  'SuppliesHist',
  'counters',
  'coverage_records',
  'det_items',
  'det_items_hist',
  'fab_items',
  'fab_items_hist',
  'loyalty',
  'other_items',
  'other_items_hist',
  'users',
];

class MigrateToThird extends StatefulWidget {
  const MigrateToThird({super.key});

  @override
  State<MigrateToThird> createState() => _MigrateToThirdState();
}

class _MigrateToThirdState extends State<MigrateToThird> {
  final Map<String, bool> _selected = {
    for (final c in _knownCollections) c: false,
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
          "Migrate to Third DB",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select collections from main firestore to migrate to thirdWeb.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: () => _toggleAll(true),
              child: const Text("Select All"),
            ),
            TextButton(
              onPressed: () => _toggleAll(false),
              child: const Text("Deselect All"),
            ),
          ],
        ),
        ..._knownCollections.map((col) => CheckboxListTile(
              title: Text(col),
              value: _selected[col],
              onChanged: (val) => setState(() => _selected[col] = val ?? false),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            )),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Delete destination before migrating"),
          subtitle: const Text(
            "Clears selected collections in thirdWeb before writing",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          value: _deleteBeforeMigrate,
          onChanged: (val) => setState(() => _deleteBeforeMigrate = val),
          activeColor: Colors.red,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _anySelected ? () => _confirmAndMigrate(context) : null,
          icon: const Icon(Icons.sync_alt),
          label: const Text("Migrate Selected"),
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
          "${deleteFirst ? '⚠️ DELETE then migrate' : 'Migrate'} the following collections to thirdWeb?\n\n${selected.join('\n')}"
          "${deleteFirst ? '\n\nDestination docs will be permanently deleted first.' : ''}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: deleteFirst
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(deleteFirst ? "Delete & Migrate" : "Migrate"),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final progressKey = GlobalKey<_ProgressDialogState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(key: progressKey),
    );

    final main = FirebaseFirestore.instance;

    FirebaseApp thirdApp;
    try {
      thirdApp = Firebase.app('thirdWeb');
    } catch (_) {
      thirdApp = await Firebase.initializeApp(
        name: 'thirdWeb',
        options: DefaultFirebaseOptions.reportsDb,
      );
    }
    final third = FirebaseFirestore.instanceFor(app: thirdApp);

    bool success = true;
    String resultMessage = "";

    try {
      // Step 1: delete destination collections if requested
      if (deleteFirst) {
        progressKey.currentState?.setStatus("Deleting destination...");
        for (final col in selected) {
          final snap = await third.collection(col).get();
          WriteBatch batch = third.batch();
          int ops = 0;
          for (final doc in snap.docs) {
            batch.delete(doc.reference);
            ops++;
            if (ops == 500) {
              await batch.commit();
              batch = third.batch();
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
        final snap = await main.collection(col).get();
        totalDocs += snap.docs.length;
      }

      int processed = 0;

      // Step 3: migrate
      progressKey.currentState?.setStatus("Migrating...");
      for (final col in selected) {
        final snap = await main.collection(col).get();
        WriteBatch batch = third.batch();
        int ops = 0;
        int colCount = 0;

        for (final doc in snap.docs) {
          batch.set(
            third.collection(col).doc(doc.id),
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
            batch = third.batch();
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
}

class _ProgressDialog extends StatefulWidget {
  const _ProgressDialog({super.key});

  @override
  State<_ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<_ProgressDialog> {
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
      title: const Text("Migrating to ThirdWeb..."),
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
