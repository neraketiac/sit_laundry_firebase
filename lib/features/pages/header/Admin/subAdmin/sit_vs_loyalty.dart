import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/sit_vs_loyalty_jobs.dart';

class SitVsLoyalty extends StatefulWidget {
  const SitVsLoyalty({super.key});

  @override
  State<SitVsLoyalty> createState() => _SitVsLoyaltyState();
}

class _SitVsLoyaltyState extends State<SitVsLoyalty> {
  List<LoyaltyDifference> differences = [];
  bool isLoading = false;
  Map<String, bool> selectedRecords = {};
  int primaryCount = 0;
  int loyaltyCount = 0;
  String lastRefreshTime = '';

  @override
  void initState() {
    super.initState();
    _compareLoyaltyData();
  }

  Future<void> _compareLoyaltyData() async {
    setState(() => isLoading = true);

    try {
      // Fetch from primary DB
      final primarySnapshot =
          await FirebaseFirestore.instance.collection('loyalty').get();
      final primaryData = {
        for (var doc in primarySnapshot.docs) doc.id: doc.data()
      };

      // Fetch from loyaltyCardDb
      final loyaltySnapshot =
          await FirebaseService.loyaltyFirestore.collection('loyalty').get();
      final loyaltyData = {
        for (var doc in loyaltySnapshot.docs) doc.id: doc.data()
      };

      primaryCount = primaryData.length;
      loyaltyCount = loyaltyData.length;

      // Find differences
      final diffs = <LoyaltyDifference>[];

      // Check records in primary but not in loyalty
      for (var id in primaryData.keys) {
        if (!loyaltyData.containsKey(id)) {
          diffs.add(LoyaltyDifference(
            id: id,
            primaryData: primaryData[id],
            loyaltyData: null,
            status: 'Only in Primary DB',
          ));
        } else {
          // Compare only cardNumber, name, address
          final pData = primaryData[id]!;
          final lData = loyaltyData[id]!;

          final pCardNum = pData['cardNumber']?.toString() ?? '';
          final pName = pData['Name']?.toString() ?? '';
          final pAddress = pData['Address']?.toString() ?? '';

          final lCardNum = lData['cardNumber']?.toString() ?? '';
          final lName = lData['Name']?.toString() ?? '';
          final lAddress = lData['Address']?.toString() ?? '';

          if (pCardNum != lCardNum || pName != lName || pAddress != lAddress) {
            diffs.add(LoyaltyDifference(
              id: id,
              primaryData: pData,
              loyaltyData: lData,
              status: 'Data Mismatch',
            ));
          }
        }
      }

      // Check records in loyalty but not in primary
      for (var id in loyaltyData.keys) {
        if (!primaryData.containsKey(id)) {
          diffs.add(LoyaltyDifference(
            id: id,
            primaryData: null,
            loyaltyData: loyaltyData[id],
            status: 'Only in Loyalty DB',
          ));
        }
      }

      if (mounted) {
        setState(() {
          differences = diffs;
          selectedRecords = {for (var d in diffs) d.id: false};
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

  Future<void> _moveSelectedRecords() async {
    final toMove = selectedRecords.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (toMove.isEmpty) {
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
        title: const Text('Confirm Move'),
        content: Text(
          'Move ${toMove.length} record(s) from primaryDB to loyaltyDB?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final loyaltyDb = FirebaseService.loyaltyFirestore;

      for (var id in toMove) {
        final diff = differences.firstWhere((d) => d.id == id);

        if (diff.primaryData != null) {
          // Copy from primary to loyalty
          await loyaltyDb.collection('loyalty').doc(id).set(diff.primaryData!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved ${toMove.length} record(s)')),
        );
      }

      // Refresh comparison
      await _compareLoyaltyData();
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                "Loyalty Data Sync: Primary DB vs Loyalty DB",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Compare and sync loyalty records between databases",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _compareLoyaltyData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed:
                        isLoading || selectedRecords.values.every((v) => !v)
                            ? null
                            : _moveSelectedRecords,
                    icon: const Icon(Icons.sync_alt),
                    label: Text(
                      'Move (${selectedRecords.values.where((v) => v).length})',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                              'Primary DB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$primaryCount',
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
                              'Loyalty DB',
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
                              'Issues',
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
                            color: differences.isEmpty
                                ? Colors.green
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            differences.isEmpty ? '✓ Synced' : '⚠ Issues',
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
                    child: Text('✓ All records are in sync!'),
                  ),
                )
              else
                _buildTable(isMobile),
              const SizedBox(height: 20),
            ],
          ),
          // Jobs vs Loyalty comparison
          const SitVsLoyaltyJobs(),
        ],
      ),
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
              width: isMobile ? 60 : 80,
              child: const Text('Card #', style: TextStyle(fontSize: 12)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: isMobile ? 80 : 120,
              child: const Text('Name', style: TextStyle(fontSize: 12)),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: isMobile ? 80 : 120,
              child: const Text('Address', style: TextStyle(fontSize: 12)),
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
          final cardNum = diff.primaryData?['cardNumber']?.toString() ??
              diff.loyaltyData?['cardNumber']?.toString() ??
              diff.id;
          final name = diff.primaryData?['Name']?.toString() ??
              diff.loyaltyData?['Name']?.toString() ??
              '-';
          final address = diff.primaryData?['Address']?.toString() ??
              diff.loyaltyData?['Address']?.toString() ??
              '-';

          Color statusColor = Colors.orange;
          String statusText = diff.status;

          if (diff.status == 'Only in Primary DB') {
            statusColor = Colors.blue;
            statusText = 'Primary';
          } else if (diff.status == 'Only in Loyalty DB') {
            statusColor = Colors.purple;
            statusText = 'Loyalty';
          } else if (diff.status == 'Data Mismatch') {
            statusColor = Colors.red;
            statusText = 'Mismatch';
          }

          return DataRow(
            cells: [
              DataCell(
                Checkbox(
                  value: selectedRecords[diff.id] ?? false,
                  onChanged: (val) {
                    setState(() {
                      selectedRecords[diff.id] = val ?? false;
                    });
                  },
                ),
              ),
              DataCell(
                Text(
                  cardNum,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  name,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  address,
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
                    color: statusColor.withValues(alpha: 0.2),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
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

class LoyaltyDifference {
  final String id;
  final Map<String, dynamic>? primaryData;
  final Map<String, dynamic>? loyaltyData;
  final String status;

  LoyaltyDifference({
    required this.id,
    required this.primaryData,
    required this.loyaltyData,
    required this.status,
  });
}
