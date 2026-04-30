import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class SitVsLoyaltyJobs extends StatefulWidget {
  const SitVsLoyaltyJobs({super.key});

  @override
  State<SitVsLoyaltyJobs> createState() => _SitVsLoyaltyJobsState();
}

class _SitVsLoyaltyJobsState extends State<SitVsLoyaltyJobs> {
  List<JobsDifference> differences = [];
  bool isLoading = false;
  Map<String, bool> selectedRecords = {};
  int jobsDoneCount = 0;
  int jobsCompletedCount = 0;
  int loyaltyCount = 0;
  String lastRefreshTime = '';

  @override
  void initState() {
    super.initState();
    _compareJobsWithLoyalty();
  }

  Future<void> _compareJobsWithLoyalty() async {
    setState(() => isLoading = true);

    try {
      // Fetch all customer names from Jobs_done
      final jobsDoneSnapshot =
          await FirebaseService.jobsDoneFirestore.collection('Jobs_done').get();
      final jobsDoneCustomerNames = <String>{};
      final jobsDoneData = <String, Map<String, dynamic>>{};

      for (var doc in jobsDoneSnapshot.docs) {
        final customerName = doc.data()['C01_CustomerName']?.toString() ?? '';
        if (customerName.isNotEmpty) {
          jobsDoneCustomerNames.add(customerName);
          jobsDoneData[customerName] = doc.data();
        }
      }

      // Fetch all customer names from Jobs_completed (Primary DB)
      final jobsCompletedSnapshot =
          await FirebaseFirestore.instance.collection('Jobs_completed').get();
      final jobsCompletedCustomerNames = <String>{};
      final jobsCompletedData = <String, Map<String, dynamic>>{};

      for (var doc in jobsCompletedSnapshot.docs) {
        final customerName = doc.data()['C01_CustomerName']?.toString() ?? '';
        if (customerName.isNotEmpty) {
          jobsCompletedCustomerNames.add(customerName);
          jobsCompletedData[customerName] = doc.data();
        }
      }

      // Fetch all customer names from loyalty
      final loyaltySnapshot =
          await FirebaseService.loyaltyFirestore.collection('loyalty').get();
      final loyaltyCustomerNames = <String>{};

      for (var doc in loyaltySnapshot.docs) {
        final name = doc.data()['Name']?.toString() ?? '';
        if (name.isNotEmpty) {
          loyaltyCustomerNames.add(name);
        }
      }

      jobsDoneCount = jobsDoneCustomerNames.length;
      jobsCompletedCount = jobsCompletedCustomerNames.length;
      loyaltyCount = loyaltyCustomerNames.length;

      // Find customer names in Jobs_done but NOT in loyalty
      final diffs = <JobsDifference>[];

      for (var customerName in jobsDoneCustomerNames) {
        if (!loyaltyCustomerNames.contains(customerName)) {
          diffs.add(JobsDifference(
            customerName: customerName,
            source: 'Jobs_done',
            jobsData: jobsDoneData[customerName],
            status: 'Missing in Loyalty DB',
          ));
        }
      }

      // Find customer names in Jobs_completed but NOT in loyalty
      for (var customerName in jobsCompletedCustomerNames) {
        if (!loyaltyCustomerNames.contains(customerName)) {
          diffs.add(JobsDifference(
            customerName: customerName,
            source: 'Jobs_completed',
            jobsData: jobsCompletedData[customerName],
            status: 'Missing in Loyalty DB',
          ));
        }
      }

      if (mounted) {
        setState(() {
          differences = diffs;
          selectedRecords = {
            for (var d in diffs) '${d.source}:${d.customerName}': false
          };
          lastRefreshTime = DateTime.now().toString().split('.')[0];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _createLoyaltyRecords() async {
    final toCreate = selectedRecords.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (toCreate.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records selected')),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Create'),
        content: Text(
          'Create ${toCreate.length} loyalty record(s) from Jobs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final loyaltyDb = FirebaseService.loyaltyFirestore;

      for (var key in toCreate) {
        final diff = differences
            .firstWhere((d) => '${d.source}:${d.customerName}' == key);

        if (diff.jobsData != null) {
          // Create loyalty record from jobs data
          final loyaltyRecord = {
            'Name': diff.customerName,
            'cardNumber': diff.customerName,
            'Contact': diff.jobsData!['C02_CustomerNumber'] ?? '',
            'Count': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'source': diff.source,
          };

          await loyaltyDb.collection('loyalty').add(loyaltyRecord);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Created ${toCreate.length} loyalty record(s)')),
        );
      }

      // Refresh comparison
      await _compareJobsWithLoyalty();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "Jobs vs Loyalty: Missing Customers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "Find customers in Jobs_done and Jobs_completed that don't exist in Loyalty DB",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : _compareJobsWithLoyalty,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: isLoading || selectedRecords.values.every((v) => !v)
                  ? null
                  : _createLoyaltyRecords,
              icon: const Icon(Icons.add_circle),
              label: Text(
                'Create (${selectedRecords.values.where((v) => v).length})',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jobs_done',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$jobsDoneCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jobs_completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$jobsCompletedCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loyalty',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$loyaltyCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Missing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${differences.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: differences.isEmpty
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Last: $lastRefreshTime',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: differences.isEmpty ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      differences.isEmpty ? '✓ Complete' : '⚠ Missing',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (differences.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('✓ All Jobs customers exist in Loyalty DB!'),
            ),
          )
        else
          _buildTable(isMobile),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTable(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: isMobile ? 8 : 16,
        columns: [
          DataColumn(
            label: SizedBox(
              width: isMobile ? 30 : 40,
              child: const Text('', style: TextStyle(fontSize: 12)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: isMobile ? 100 : 150,
              child:
                  const Text('Customer Name', style: TextStyle(fontSize: 12)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: isMobile ? 80 : 120,
              child: const Text('Phone', style: TextStyle(fontSize: 12)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: isMobile ? 70 : 100,
              child: const Text('Status', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
        rows: differences.map((diff) {
          final customerName = diff.customerName;
          final phone = diff.jobsData?['C02_CustomerNumber']?.toString() ?? '-';

          return DataRow(
            cells: [
              DataCell(
                Checkbox(
                  value: selectedRecords[diff.customerName] ?? false,
                  onChanged: (val) {
                    setState(() {
                      selectedRecords[diff.customerName] = val ?? false;
                    });
                  },
                ),
              ),
              DataCell(
                Text(
                  customerName,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  phone,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Missing',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class JobsDifference {
  final String customerName;
  final String source;
  final Map<String, dynamic>? jobsData;
  final String status;

  JobsDifference({
    required this.customerName,
    required this.source,
    required this.jobsData,
    required this.status,
  });
}
