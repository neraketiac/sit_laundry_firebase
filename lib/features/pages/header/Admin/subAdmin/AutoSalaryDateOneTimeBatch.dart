/// ONE-TIME BATCH: Copy LogDate → AutoSalaryDate for all EmployeeHist records.
/// Run this once, then remove the button/call.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class AutoSalaryDateOneTimeBatch extends StatefulWidget {
  const AutoSalaryDateOneTimeBatch({super.key});

  @override
  State<AutoSalaryDateOneTimeBatch> createState() =>
      _AutoSalaryDateOneTimeBatchState();
}

class _AutoSalaryDateOneTimeBatchState
    extends State<AutoSalaryDateOneTimeBatch> {
  bool _running = false;
  String _status = 'Ready. Press Run to start.';
  int _processed = 0;
  int _total = 0;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _status = 'Fetching records...';
      _processed = 0;
      _total = 0;
    });

    try {
      final firestore = FirebaseService.employeeFirestore;
      final collection = firestore.collection('EmployeeHist');

      // Fetch all docs (paginate in chunks of 400 to stay under batch limit)
      const chunkSize = 400;
      DocumentSnapshot? lastDoc;
      int totalUpdated = 0;

      while (true) {
        Query query = collection.orderBy(FieldPath.documentId).limit(chunkSize);
        if (lastDoc != null) query = query.startAfterDocument(lastDoc);

        final snap = await query.get();
        if (snap.docs.isEmpty) break;

        setState(() {
          _total += snap.docs.length;
          _status = 'Processing $_total records...';
        });

        final batch = firestore.batch();
        int batchCount = 0;

        for (final doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Skip if AutoSalaryDate already set
          if (data['AutoSalaryDate'] != null) continue;

          final logDate = data['LogDate'];
          if (logDate == null) continue;

          batch.update(doc.reference, {'AutoSalaryDate': logDate});
          batchCount++;
        }

        if (batchCount > 0) {
          await batch.commit();
          totalUpdated += batchCount;
        }

        setState(() {
          _processed = totalUpdated;
          _status = 'Updated $_processed so far...';
        });

        if (snap.docs.length < chunkSize) break;
        lastDoc = snap.docs.last;
      }

      setState(() {
        _running = false;
        _status = '✅ Done. Updated $_processed record(s).';
      });
    } catch (e) {
      setState(() {
        _running = false;
        _status = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoSalaryDate One-Time Batch')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This batch copies LogDate → AutoSalaryDate\nfor all existing EmployeeHist records.\n\nRun once only.',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _status.startsWith('✅')
                    ? Colors.green
                    : _status.startsWith('❌')
                        ? Colors.red
                        : Colors.black87,
              ),
            ),
            if (_running) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _total > 0 ? _processed / _total : null,
              ),
              const SizedBox(height: 8),
              Text('$_processed / $_total updated'),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _running ? null : _run,
              icon: _running
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_running ? 'Running...' : 'Run Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
