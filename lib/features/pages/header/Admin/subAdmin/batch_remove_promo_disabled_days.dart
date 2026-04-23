import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Finds all Jobs_done and Jobs_completed where DateD falls on a
/// promo-disabled day (from promo_days collection), then sets
/// Q06_PromoCounter = 0 for those jobs.
class BatchRemovePromoDisabledDays extends StatefulWidget {
  const BatchRemovePromoDisabledDays({super.key});

  @override
  State<BatchRemovePromoDisabledDays> createState() =>
      _BatchRemovePromoDisabledDaysState();
}

class _BatchRemovePromoDisabledDaysState
    extends State<BatchRemovePromoDisabledDays> {
  final _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  bool _previewed = false;
  String? _error;

  /// disabled date strings (yyyy-MM-dd) → Timestamp
  Map<String, Timestamp> _disabledDays = {};

  /// jobs that will be updated
  List<_JobEntry> _affectedJobs = [];

  int _totalScanned = 0;
  bool _applying = false;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    _runPreview();
  }

  Future<void> _runPreview() async {
    setState(() {
      _loading = true;
      _error = null;
      _previewed = false;
      _affectedJobs = [];
      _applied = false;
    });

    try {
      // 1. Load all disabled promo days
      final promoSnap = await _firestore
          .collection('promo_days')
          .where('disabled', isEqualTo: true)
          .get();

      _disabledDays = {
        for (final doc in promoSnap.docs)
          doc.id: (doc.data()['date'] as Timestamp)
      };

      if (_disabledDays.isEmpty) {
        setState(() {
          _loading = false;
          _previewed = true;
        });
        return;
      }

      // 2. Scan Jobs_done and Jobs_completed
      final List<_JobEntry> affected = [];
      int scanned = 0;

      for (final col in ['Jobs_done', 'Jobs_completed']) {
        final snap = await _firestore.collection(col).get();
        for (final doc in snap.docs) {
          scanned++;
          final data = doc.data();
          final ts = data['A05_DateD'] as Timestamp?;
          if (ts == null) continue;

          final dateId = DateFormat('yyyy-MM-dd').format(ts.toDate());
          if (!_disabledDays.containsKey(dateId)) continue;

          final current = (data['Q06_PromoCounter'] as num?)?.toInt() ?? 0;
          if (current == 0) continue; // already 0, skip

          affected.add(_JobEntry(
            doc: doc,
            collection: col,
            jobId: (data['A00_JobId'] as num?)?.toInt() ?? 0,
            customerName: data['C01_CustomerName']?.toString() ?? '—',
            dateD: ts.toDate(),
            currentPromoCounter: current,
          ));
        }
      }

      setState(() {
        _totalScanned = scanned;
        _affectedJobs = affected;
        _loading = false;
        _previewed = true;
      });
    } catch (e, st) {
      debugPrint('BatchRemovePromoDisabledDays error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _applyAll() async {
    if (_affectedJobs.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(
            'Set promoCounter = 0 for ${_affectedJobs.length} job(s) on disabled promo days?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _applying = true);

    try {
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (final job in _affectedJobs) {
        batch.update(job.doc.reference, {'Q06_PromoCounter': 0});
        count++;
        if (count >= 450) {
          await batch.commit();
          batch = _firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();

      setState(() {
        _applying = false;
        _applied = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Done — ${_affectedJobs.length} job(s) updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _applying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Promo on Disabled Days',
            style: TextStyle(fontSize: 15)),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-scan',
            onPressed: _loading ? null : _runPreview,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Scanning jobs...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Disabled promo days: ${_disabledDays.length}',
                                style: const TextStyle(fontSize: 12)),
                            Text('Jobs scanned: $_totalScanned',
                                style: const TextStyle(fontSize: 12)),
                            Text(
                              'Jobs to update (promoCounter → 0): ${_affectedJobs.length}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_disabledDays.isNotEmpty) ...[
                        const Text('Disabled days:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _disabledDays.keys
                              .map((d) => Chip(
                                    label: Text(d,
                                        style: const TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.red.shade100,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (_affectedJobs.isEmpty && _previewed)
                        Card(
                          color: Colors.green,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '✅ No jobs need updating.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
                        // Job list
                        ..._affectedJobs.map((job) => Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  '${job.customerName}  •  Job #${job.jobId}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  '${job.collection}  •  ${DateFormat('MMM dd yyyy').format(job.dateD)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Text(
                                  'promo: ${job.currentPromoCounter} → 0',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: (_applying || _applied) ? null : _applyAll,
                          icon: _applying
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check),
                          label: Text(_applied
                              ? 'Applied ✅'
                              : _applying
                                  ? 'Applying...'
                                  : 'Apply to ${_affectedJobs.length} job(s)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _applied ? Colors.green : Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _JobEntry {
  final QueryDocumentSnapshot doc;
  final String collection;
  final int jobId;
  final String customerName;
  final DateTime dateD;
  final int currentPromoCounter;

  _JobEntry({
    required this.doc,
    required this.collection,
    required this.jobId,
    required this.customerName,
    required this.dateD,
    required this.currentPromoCounter,
  });
}
