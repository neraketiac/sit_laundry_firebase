import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

class EditAutoSalaryDatePage extends StatefulWidget {
  const EditAutoSalaryDatePage({super.key});

  @override
  State<EditAutoSalaryDatePage> createState() => _EditAutoSalaryDatePageState();
}

class _EditAutoSalaryDatePageState extends State<EditAutoSalaryDatePage> {
  final _firestore = FirebaseService.employeeFirestore;
  final _searchController = TextEditingController();

  String _searchQuery = '';
  bool _loading = false;
  List<_EmpHistRecord> _records = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      setState(() {
        _records.clear();
        _lastDoc = null;
        _hasMore = true;
      });
    }
    if (!_hasMore) return;

    setState(() => _loading = true);

    try {
      Query query = _firestore
          .collection('EmployeeHist')
          .orderBy('LogDate', descending: true)
          .limit(50);

      if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);

      final snap = await query.get();

      final newRecords = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _EmpHistRecord(
          docId: doc.id,
          empName: data['EmpName']?.toString() ?? '',
          empId: data['EmpId']?.toString() ?? '',
          itemName: data['ItemName']?.toString() ?? '',
          currentCounter: (data['CurrentCounter'] as num?)?.toInt() ?? 0,
          logDate: data['LogDate'] as Timestamp?,
          autoSalaryDate: data['AutoSalaryDate'] as Timestamp?,
          remarks: data['Remarks']?.toString() ?? '',
        );
      }).toList();

      setState(() {
        _records.addAll(newRecords);
        _lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
        _hasMore = snap.docs.length == 50;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickDate(_EmpHistRecord record) async {
    final initial = record.autoSalaryDate?.toDate() ??
        record.logDate?.toDate() ??
        DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select AutoSalaryDate',
    );

    if (picked == null || !mounted) return;

    final newTs =
        Timestamp.fromDate(DateTime(picked.year, picked.month, picked.day));

    try {
      await _firestore
          .collection('EmployeeHist')
          .doc(record.docId)
          .update({'AutoSalaryDate': newTs});

      setState(() {
        final idx = _records.indexWhere((r) => r.docId == record.docId);
        if (idx != -1) {
          _records[idx] = _records[idx].copyWith(autoSalaryDate: newTs);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Updated ${record.empName} → ${DateFormat('MMM dd, yyyy').format(picked)}'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }

  List<_EmpHistRecord> get _filtered {
    if (_searchQuery.isEmpty) return _records;
    final q = _searchQuery.toLowerCase();
    return _records
        .where((r) =>
            r.empName.toLowerCase().contains(q) ||
            r.empId.toLowerCase().contains(q) ||
            r.itemName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Edit AutoSalaryDate'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () => _load(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, empId, item...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  '${filtered.length} record${filtered.length != 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount:
                  filtered.length + (_hasMore && _searchQuery.isEmpty ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == filtered.length) {
                  // Load more trigger
                  WidgetsBinding.instance.addPostFrameCallback((_) => _load());
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }

                final r = filtered[i];
                final logDateStr = r.logDate != null
                    ? DateFormat('MMM dd, yyyy').format(r.logDate!.toDate())
                    : '—';
                final autoDateStr = r.autoSalaryDate != null
                    ? DateFormat('MMM dd, yyyy')
                        .format(r.autoSalaryDate!.toDate())
                    : 'Not set';
                final hasAuto = r.autoSalaryDate != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      '${r.empName} — ${r.itemName}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LogDate: $logDateStr',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                        Row(
                          children: [
                            Text(
                              'AutoSalaryDate: $autoDateStr',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hasAuto
                                    ? Colors.teal.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (!hasAuto)
                              Icon(Icons.warning_amber,
                                  size: 12, color: Colors.orange.shade700),
                          ],
                        ),
                        Text(
                          '₱${r.currentCounter}  ${r.remarks.isNotEmpty ? '· ${r.remarks}' : ''}',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit_calendar,
                          color: Colors.blueGrey.shade600),
                      tooltip: 'Pick date',
                      onPressed: () => _pickDate(r),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmpHistRecord {
  final String docId;
  final String empName;
  final String empId;
  final String itemName;
  final int currentCounter;
  final Timestamp? logDate;
  final Timestamp? autoSalaryDate;
  final String remarks;

  const _EmpHistRecord({
    required this.docId,
    required this.empName,
    required this.empId,
    required this.itemName,
    required this.currentCounter,
    required this.logDate,
    required this.autoSalaryDate,
    required this.remarks,
  });

  _EmpHistRecord copyWith({Timestamp? autoSalaryDate}) => _EmpHistRecord(
        docId: docId,
        empName: empName,
        empId: empId,
        itemName: itemName,
        currentCounter: currentCounter,
        logDate: logDate,
        autoSalaryDate: autoSalaryDate ?? this.autoSalaryDate,
        remarks: remarks,
      );
}
