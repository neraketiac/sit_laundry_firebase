import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

/// A job record with its computed new promo error code
class _JobReview {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> data;
  final int currentCode;
  final int newCode;
  final bool changed;

  _JobReview({
    required this.doc,
    required this.data,
    required this.currentCode,
    required this.newCode,
    required this.changed,
  });

  String get collection => doc.reference.parent.id;
  int get jobId => data['A00_JobId'] ?? 0;
  DateTime? get dateD => (data['A05_DateD'] as Timestamp?)?.toDate();
  bool get unpaid => data['P00_Unpaid'] ?? false;
  num get finalPrice => data['Q06_FinalPrice'] ?? 0;
}

/// A customer group with jobs that need review
class _CustomerReview {
  final String customerId;
  final String customerName;
  final String customerAddress;
  final List<_JobReview> jobs;
  bool applying = false;
  bool applied = false;

  _CustomerReview({
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.jobs,
  });

  bool get hasChanges => jobs.any((j) => j.changed);
}

class BatchPromoReviewPage extends StatefulWidget {
  const BatchPromoReviewPage({super.key});

  @override
  State<BatchPromoReviewPage> createState() => _BatchPromoReviewPageState();
}

class _BatchPromoReviewPageState extends State<BatchPromoReviewPage> {
  bool _loading = false;
  String? _error;
  List<_CustomerReview> _customers = [];
  int _totalScanned = 0;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
      _customers = [];
    });

    try {
      final jobsDoneDb = FirebaseService.jobsDoneFirestore;
      final primaryDb = FirebaseFirestore.instance;
      const collections = ['Jobs_done', 'Jobs_completed'];
      final Map<String, List<QueryDocumentSnapshot>> byCustomer = {};
      final Map<String, String> customerNames = {};
      final Map<String, String> customerAddresses = {};

      int scanned = 0;

      // Read Jobs_done from jobsDoneDb, Jobs_completed from primaryDb
      for (final col in collections) {
        final firestore = col == 'Jobs_done' ? jobsDoneDb : primaryDb;
        final snap = await firestore
            .collection(col)
            .orderBy('A05_DateD', descending: true)
            .get();

        for (final doc in snap.docs) {
          scanned++;
          final data = doc.data() as Map<String, dynamic>;
          final cid = data['C00_CustomerId']?.toString();
          if (cid == null) continue;
          byCustomer.putIfAbsent(cid, () => []).add(doc);
          if (!customerNames.containsKey(cid)) {
            customerNames[cid] =
                data['C01_CustomerName']?.toString() ?? 'Customer $cid';
            customerAddresses[cid] = data['C02_Address']?.toString() ?? '';
          }
        }
      }

      _totalScanned = scanned;

      final List<_CustomerReview> results = [];

      for (final entry in byCustomer.entries) {
        final cid = entry.key;
        final docs = entry.value;

        // Sort newest first
        docs.sort((a, b) {
          final aTs = (a.data() as Map<String, dynamic>)['A05_DateD'];
          final bTs = (b.data() as Map<String, dynamic>)['A05_DateD'];
          final aTsTyped = aTs is Timestamp ? aTs : null;
          final bTsTyped = bTs is Timestamp ? bTs : null;
          if (aTsTyped == null || bTsTyped == null) return 0;
          return bTsTyped.compareTo(aTsTyped);
        });

        final List<_JobReview> jobReviews = [];
        DateTime? prevRefDate;
        int? prevCode;
        bool shouldBreak = false;

        for (int i = 0; i < docs.length; i++) {
          final doc = docs[i];
          final data = doc.data() as Map<String, dynamic>;
          final bool unpaid = data['P00_Unpaid'] ?? false;
          final Timestamp? tsDateD = data['A05_DateD'] as Timestamp?;
          final Timestamp? tsPaidD = data['A03_PaidD'] as Timestamp?;
          final int currentCode = data['Z01_PromoErrorCode'] ?? 0;

          if (tsDateD == null) continue;

          final DateTime dateD = tsDateD.toDate();
          final DateTime? paidD = tsPaidD?.toDate();

          int newCode;

          if (shouldBreak) {
            newCode = 5;
          } else if (i == 0) {
            final gap = DateTime.now().difference(dateD);
            newCode = gap.inDays > 14 ? (unpaid ? 2 : 3) : (unpaid ? 1 : 0);
          } else {
            if (prevCode == 0) {
              final gap = prevRefDate!.difference(dateD);
              newCode = gap.inDays > 14 ? (unpaid ? 2 : 3) : (unpaid ? 1 : 0);
            } else if (prevCode == 1) {
              final gap = DateTime.now().difference(dateD);
              newCode = gap.inDays > 14 ? (unpaid ? 2 : 3) : (unpaid ? 1 : 0);
            } else {
              newCode = 5;
              shouldBreak = true;
            }
          }

          jobReviews.add(_JobReview(
            doc: doc,
            data: data,
            currentCode: currentCode,
            newCode: newCode,
            changed: currentCode != newCode,
          ));

          if (!shouldBreak) {
            if (newCode == 0 && paidD != null) {
              prevRefDate = dateD.isAfter(paidD) ? dateD : paidD;
            } else {
              prevRefDate = dateD;
            }
            prevCode = newCode;
          }
        }

        // Only include customers that have at least one change
        if (jobReviews.any((j) => j.changed)) {
          results.add(_CustomerReview(
            customerId: cid,
            customerName: customerNames[cid] ?? 'Customer $cid',
            customerAddress: customerAddresses[cid] ?? '',
            jobs: jobReviews,
          ));
        }
      }

      // Sort by customer name
      results.sort((a, b) => a.customerName.compareTo(b.customerName));

      setState(() {
        _customers = results;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('BatchPromoReview error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _applyCustomer(_CustomerReview customer) async {
    setState(() => customer.applying = true);

    try {
      final firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();
      int count = 0;

      for (final job in customer.jobs) {
        if (!job.changed) continue;
        batch.update(job.doc.reference, {'Z01_PromoErrorCode': job.newCode});
        count++;
        if (count >= 450) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();

      setState(() {
        customer.applying = false;
        customer.applied = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied changes for ${customer.customerName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => customer.applying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _codeColor(int code) {
    switch (code) {
      case 0:
        return Colors.green.shade700;
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.red.shade400;
      case 3:
        return Colors.red.shade700;
      case 5:
        return Colors.grey.shade600;
      default:
        return Colors.black;
    }
  }

  String _codeLabel(int code) {
    switch (code) {
      case 0:
        return 'Eligible';
      case 1:
        return 'Unpaid';
      case 2:
        return 'Unpaid+Gap';
      case 3:
        return 'Gap';
      case 5:
        return 'Excluded';
      default:
        return 'Code $code';
    }
  }

  Widget _buildJobRow(_JobReview job) {
    final date = job.dateD;
    final dateStr = date != null
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : '—';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: job.changed ? Colors.yellow.shade50 : Colors.white,
        border: Border.all(
          color: job.changed ? Colors.orange.shade300 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Job ID + date
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job #${job.jobId}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(dateStr,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  job.collection,
                  style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          // Price + unpaid
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₱${job.finalPrice}',
                    style: const TextStyle(fontSize: 11)),
                if (job.unpaid)
                  const Text('UNPAID',
                      style: TextStyle(fontSize: 9, color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Current → New code
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (job.changed) ...[
                Text(
                  '${job.currentCode}→${job.newCode}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _codeColor(job.newCode),
                  ),
                ),
                Text(
                  _codeLabel(job.newCode),
                  style: TextStyle(fontSize: 9, color: _codeColor(job.newCode)),
                ),
              ] else ...[
                Text(
                  '${job.currentCode}',
                  style: TextStyle(
                      fontSize: 11, color: _codeColor(job.currentCode)),
                ),
                Text(
                  _codeLabel(job.currentCode),
                  style: TextStyle(
                      fontSize: 9, color: _codeColor(job.currentCode)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(_CustomerReview customer) {
    final changedCount = customer.jobs.where((j) => j.changed).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: customer.applied ? Colors.green.shade50 : Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          customer.customerName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.customerAddress.isNotEmpty)
              Text(
                customer.customerAddress,
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            Text(
              '$changedCount job(s) will change  •  ${customer.jobs.length} total',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: customer.applied
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        children: [
          // Job list
          ...customer.jobs.map(_buildJobRow),
          const SizedBox(height: 10),
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (customer.applying || customer.applied)
                  ? null
                  : () => _applyCustomer(customer),
              icon: customer.applying
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save, size: 16),
              label: Text(
                customer.applied
                    ? 'Applied'
                    : customer.applying
                        ? 'Applying...'
                        : 'Apply Changes ($changedCount jobs)',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    customer.applied ? Colors.green : Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Promo Review', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-analyze',
            onPressed: _loading ? null : _runAnalysis,
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
                  Text('Analyzing jobs...', style: TextStyle(fontSize: 13)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $_error',
                        style: const TextStyle(color: Colors.red)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary banner
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.deepOrange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jobs scanned: $_totalScanned',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Customers needing update: ${_customers.length}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Yellow rows = will change. Tap a customer to expand and review, then apply.',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_customers.isEmpty)
                        const Card(
                          color: Colors.green,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '✅ All promo error codes are already correct.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ..._customers.map(_buildCustomerCard),
                    ],
                  ),
                ),
    );
  }
}
