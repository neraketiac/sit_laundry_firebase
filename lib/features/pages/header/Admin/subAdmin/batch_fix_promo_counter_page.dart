import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/batch_fix_promo_counter.dart';

class BatchFixPromoCounterPage extends StatefulWidget {
  const BatchFixPromoCounterPage({super.key});

  @override
  State<BatchFixPromoCounterPage> createState() => _BatchFixPromoCounterPageState();
}

class _BatchFixPromoCounterPageState extends State<BatchFixPromoCounterPage> {
  final BatchFixPromoCounter _batchFix = BatchFixPromoCounter();
  bool _isLoading = false;
  Map<String, dynamic>? _previewResults;
  Map<String, dynamic>? _fixResults;

  Future<void> _previewChanges() async {
    setState(() {
      _isLoading = true;
      _fixResults = null;
    });

    try {
      final results = await _batchFix.previewChanges();
      setState(() {
        _previewResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error previewing changes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fixAllJobs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Batch Fix'),
        content: Text(
          'This will update ${_previewResults?['totalChanges'] ?? 0} jobs with incorrect promoCounter values.\n\n'
          'This action cannot be undone. Are you sure you want to proceed?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Fix All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _batchFix.fixAllJobs();
      setState(() {
        _fixResults = results;
        _previewResults = null; // Clear preview after fix
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batch fix completed: ${results['totalUpdated']}/${results['totalProcessed']} jobs updated'
          ),
          backgroundColor: results['success'] ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fixing jobs: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPreviewCard(String collection, List<dynamic> changes) {
    if (changes.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$collection: No changes needed'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$collection (${changes.length} changes)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...changes.take(5).map((change) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${change['customerName']} (#${change['jobId']}): '
                '${change['currentPromoCounter']} → ${change['correctPromoCounter']} '
                '(${change['packageType']} ${change['pricingType']})',
                style: const TextStyle(fontSize: 12),
              ),
            )),
            if (changes.length > 5)
              Text(
                '... and ${changes.length - 5} more',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(Map<String, dynamic> results) {
    final success = results['success'] as bool;
    final totalProcessed = results['totalProcessed'] as int;
    final totalUpdated = results['totalUpdated'] as int;
    final errors = results['errors'] as List<String>;

    return Card(
      color: success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  success ? 'Batch Fix Completed' : 'Batch Fix Failed',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total Processed: $totalProcessed'),
            Text('Total Updated: $totalUpdated'),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...errors.take(3).map((error) => Text('• $error', style: const TextStyle(fontSize: 12))),
              if (errors.length > 3)
                Text('... and ${errors.length - 3} more errors', style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Fix PromoCounter'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PromoCounter Batch Fix Utility',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This utility will recalculate and fix incorrect promoCounter values in Jobs_done and Jobs_completed collections.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Step 1: Preview changes to see what will be updated\n'
                      'Step 2: Apply fixes if the preview looks correct',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _previewChanges,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_isLoading || _previewResults == null) ? null : _fixAllJobs,
                    icon: const Icon(Icons.build_circle),
                    label: const Text('Fix All Jobs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Processing...'),
                  ],
                ),
              ),
            if (_previewResults != null) ...[
              Text(
                'Preview Results (${_previewResults!['totalChanges']} total changes)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPreviewCard('Jobs_done', _previewResults!['Jobs_done']),
                      _buildPreviewCard('Jobs_completed', _previewResults!['Jobs_completed']),
                    ],
                  ),
                ),
              ),
            ],
            if (_fixResults != null) ...[
              const Text(
                'Fix Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildResultsCard(_fixResults!),
            ],
          ],
        ),
      ),
    );
  }
}