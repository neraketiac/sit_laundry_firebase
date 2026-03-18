import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/loyalty_count_validator.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';

class LoyaltyValidationPage extends StatefulWidget {
  const LoyaltyValidationPage({super.key});

  @override
  State<LoyaltyValidationPage> createState() => _LoyaltyValidationPageState();
}

class _LoyaltyValidationPageState extends State<LoyaltyValidationPage> {
  final LoyaltyCountValidator _validator = LoyaltyCountValidator();
  final DatabaseLoyalty _databaseLoyalty = DatabaseLoyalty();
  bool _isLoading = false;
  Map<String, dynamic>? _mismatchResults;
  Map<String, dynamic>? _summaryStats;
  Set<int> _updatingCustomers = {};

  Future<void> _updateCustomerLoyalty(int customerId, String customerName, int currentCount, int expectedCount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Loyalty Count', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $customerName (#$customerId)', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text('Current Loyalty: $currentCount', style: TextStyle(fontSize: 12)),
            Text('Expected Loyalty: $expectedCount', style: TextStyle(fontSize: 12)),
            SizedBox(height: 8),
            Text(
              'This will set the loyalty count to $expectedCount.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
            child: Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _updatingCustomers.add(customerId);
    });

    try {
      await _databaseLoyalty.setCountByCardNumber(customerId, expectedCount);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated $customerName loyalty count to $expectedCount'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the validation results
      await _validateLoyaltyCounts();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating loyalty count: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _updatingCustomers.remove(customerId);
      });
    }
  }

  Future<void> _validateLoyaltyCounts() async {
    setState(() {
      _isLoading = true;
      _mismatchResults = null;
      _summaryStats = null;
    });

    try {
      final results = await _validator.getLoyaltyMismatches();
      final stats = await _validator.getSummaryStats();
      
      setState(() {
        _mismatchResults = results;
        _summaryStats = stats;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error validating loyalty counts: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard() {
    if (_summaryStats == null) return const SizedBox.shrink();

    final stats = _summaryStats!;
    final totalCustomers = stats['totalCustomers'] as int;
    final totalJobs = stats['totalJobs'] as int;
    final totalPromoCounterSum = stats['totalPromoCounterSum'] as int;
    final totalApplicablePromoCounter = stats['totalApplicablePromoCounter'] as int;
    final totalPromoFreeRedemptions = stats['totalPromoFreeRedemptions'] as int;
    final totalPromoFreeDeduction = stats['totalPromoFreeDeduction'] as int;
    final totalLoyaltyPoints = stats['totalLoyaltyPoints'] as int;
    final errorCodeBreakdown = stats['errorCodeBreakdown'] as Map<int, int>;

    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Mobile-friendly layout - single column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Total Customers', totalCustomers.toString()),
                _buildStatRow('Total Jobs', totalJobs.toString()),
                _buildStatRow('Total PromoCounter Sum', totalPromoCounterSum.toString()),
                _buildStatRow('Total PromoFree Redemptions', totalPromoFreeRedemptions.toString()),
                _buildStatRow('Total PromoFree Deduction', '-$totalPromoFreeDeduction'),
                _buildStatRow('Total Applicable PromoCounter', totalApplicablePromoCounter.toString()),
                _buildStatRow('Total Loyalty Points', totalLoyaltyPoints.toString()),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: totalApplicablePromoCounter == totalLoyaltyPoints 
                        ? Colors.green.shade100 
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Difference: ${totalApplicablePromoCounter - totalLoyaltyPoints}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: totalApplicablePromoCounter == totalLoyaltyPoints 
                          ? Colors.green.shade800 
                          : Colors.red.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PromoErrorCode Breakdown:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...errorCodeBreakdown.entries.map((entry) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      'Code ${entry.key}: ${entry.value} jobs',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMismatchCard(Map<String, dynamic> mismatch) {
    final customerId = mismatch['customerId'] as int;
    final customerName = mismatch['customerName'] as String;
    final currentLoyalty = mismatch['currentLoyaltyCount'] as int;
    final expectedLoyalty = mismatch['expectedLoyaltyCount'] as int;
    final difference = mismatch['difference'] as int;
    final totalJobs = mismatch['totalJobs'] as int;
    final applicableJobs = mismatch['applicableJobs'] as int;
    final promoFreeRedemptions = mismatch['promoFreeRedemptions'] as int;
    final totalPromoFreeDeduction = mismatch['totalPromoFreeDeduction'] as int;
    final errorCodeBreakdown = mismatch['errorCodeBreakdown'] as Map<int, int>;
    final jobDetails = mismatch['jobDetails'] as List<dynamic>;

    return Card(
      color: difference > 0 ? Colors.orange.shade50 : Colors.red.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.all(12),
        title: Text(
          '$customerName (#$customerId)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: $currentLoyalty | Expected: $expectedLoyalty',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Difference: ${difference > 0 ? '+' : ''}$difference',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: difference > 0 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary section
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Total Jobs', totalJobs.toString()),
                    _buildDetailRow('Applicable Jobs (ErrorCode=0)', applicableJobs.toString()),
                    _buildDetailRow('PromoFree Redemptions', promoFreeRedemptions.toString()),
                    _buildDetailRow('PromoFree Deduction', '-$totalPromoFreeDeduction'),
                    _buildDetailRow('Current Loyalty', currentLoyalty.toString()),
                    _buildDetailRow('Expected Loyalty', expectedLoyalty.toString()),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: difference > 0 ? Colors.orange.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _buildDetailRow(
                        'Difference',
                        '${difference > 0 ? '+' : ''}$difference',
                        valueStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: difference > 0 ? Colors.orange.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updatingCustomers.contains(customerId) 
                      ? null 
                      : () => _updateCustomerLoyalty(customerId, customerName, currentLoyalty, expectedLoyalty),
                  icon: _updatingCustomers.contains(customerId)
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.update, size: 16),
                  label: Text(
                    _updatingCustomers.contains(customerId) 
                        ? 'Updating...' 
                        : 'Update Loyalty to $expectedLoyalty',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Error code breakdown
              const Text(
                'Error Code Breakdown:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: errorCodeBreakdown.entries.map((entry) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Code ${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ).toList(),
              ),
              
              if (jobDetails.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Applicable Jobs Details:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: jobDetails.map((job) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: job['hasPromoFree'] ? Colors.red.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: job['hasPromoFree'] ? Border.all(color: Colors.red.shade200) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Job #${job['jobId']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: job['hasPromoFree'] ? Colors.red.shade800 : null,
                                  ),
                                ),
                                if (job['hasPromoFree'])
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'FREE',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PromoCounter: ${job['promoCounter']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  '₱${job['finalPrice']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              '${job['packageType']}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
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
        title: const Text('Loyalty Validation', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loyalty Count Validation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Validates loyalty counts against applicable promoCounter values.',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Logic: Only jobs with promoErrorCode = 0 are included. When promoErrorCode ≠ 0, all succeeding jobs are excluded from promo. PromoFree redemptions deduct 10 points each.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _validateLoyaltyCounts,
                icon: const Icon(Icons.analytics, size: 18),
                label: const Text('Validate Loyalty Counts', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Analyzing loyalty counts...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            if (_summaryStats != null) ...[
              _buildSummaryCard(),
              const SizedBox(height: 12),
            ],
            if (_mismatchResults != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mismatches: ${_mismatchResults!['totalMismatches']} / ${_mismatchResults!['totalCustomersChecked']} customers',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              if (_mismatchResults!['totalMismatches'] == 0)
                const Card(
                  color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      '✅ All loyalty counts match expected values!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Column(
                  children: (_mismatchResults!['mismatches'] as List)
                      .map((mismatch) => _buildMismatchCard(mismatch))
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}