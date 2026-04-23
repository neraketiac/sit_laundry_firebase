import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/services/database_employee_hist.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';

Widget readDataEmployeeHist() => const _EmployeeHistWidget();

class _EmployeeHistWidget extends StatefulWidget {
  const _EmployeeHistWidget();

  @override
  State<_EmployeeHistWidget> createState() => _EmployeeHistWidgetState();
}

class _EmployeeHistWidgetState extends State<_EmployeeHistWidget> {
  static const int _pageSize = 20;

  final List<EmployeeModel> _items = [];
  final Set<String> _loadedIds = {};
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  final ScrollController _scroll = ScrollController();
  StreamSubscription? _liveSub;
  Timestamp? _newestLogDate;

  String? _selectedEmpId; // null = ALL

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _liveSub?.cancel();
    super.dispose();
  }

  void _startLiveListener() {
    _liveSub?.cancel();
    final db = DatabaseEmployeeHist();
    // Live listener on first page — handles adds, updates, deletes
    _liveSub =
        db.getEmployeeHistory(filterEmpId: _selectedEmpId).listen((snap) {
      if (!mounted) return;
      final liveDocs = snap.docs.map((d) => d.data() as EmployeeModel).toList();
      final liveIds = snap.docs.map((d) => d.id).toSet();
      setState(() {
        final older = _items.length > _pageSize
            ? _items.sublist(_pageSize)
            : <EmployeeModel>[];
        _items
          ..clear()
          ..addAll(liveDocs)
          ..addAll(older);
        _loadedIds
          ..removeWhere((id) => !liveIds.contains(id))
          ..addAll(liveIds);
        if (snap.docs.isNotEmpty) {
          _newestLogDate = (snap.docs.first.data() as EmployeeModel).logDate;
        }
      });
    });
  }

  Future<void> _refresh() async {
    _liveSub?.cancel();
    setState(() {
      _items.clear();
      _loadedIds.clear();
      _lastDoc = null;
      _hasMore = true;
      _newestLogDate = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    final db = DatabaseEmployeeHist();
    final snap = await db.getEmployeeHistoryPaginated(
      lastDoc: _lastDoc,
      filterEmpId: _selectedEmpId,
    );

    final newItems = snap.docs.map((d) => d.data() as EmployeeModel).toList();

    setState(() {
      _loading = false;
      if (newItems.length < _pageSize) _hasMore = false;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      for (int i = 0; i < snap.docs.length; i++) {
        if (!_loadedIds.contains(snap.docs[i].id)) {
          _loadedIds.add(snap.docs[i].id);
          _items.add(newItems[i]);
        }
      }
      if (_newestLogDate == null && snap.docs.isNotEmpty) {
        _newestLogDate = newItems.first.logDate;
        _startLiveListener();
      }
      FsUsageTracker.instance.track('readDataEmployeeHist', snap.docs.length);
    });
  }

  Widget _buildRow(EmployeeModel eM) {
    final bNegative = eM.currentCounter < 0;
    final bNegativePCF = eM.currentStocks < 0;
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: const Border(
          bottom:
              BorderSide(color: Color.fromARGB(255, 89, 89, 89), width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Text(
            DateFormat('MM/dd hh:mm a').format(eM.logDate.toDate()),
            style: const TextStyle(
                fontSize: 9, color: Color.fromARGB(255, 68, 68, 68)),
          ),
          const SizedBox(width: 4),
          Text(
            '₱${value.format(eM.currentCounter)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: bNegative
                  ? const Color.fromARGB(255, 185, 57, 48)
                  : const Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${eM.itemName} ${ifMenuUniqueIsCashInEmp(eM) ? 'to' : 'by'} ${eM.empName} : ${eM.remarks}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238)),
            ),
          ),
          Text(
            eM.logBy,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800]),
          ),
          Text(
            'pCF ₱${value.format(eM.currentStocks)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: bNegativePCF
                  ? const Color.fromARGB(255, 185, 57, 48)
                  : const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👤📊 EMPLOYEE HISTORY',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DropdownButtonFormField<String>(
              value: _selectedEmpId,
              hint: const Text('All', style: TextStyle(fontSize: 12)),
              isDense: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...mapEmpId.entries
                    .where((e) => e.key != '1313#' && e.key != '1616#')
                    .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (v) {
                setState(() {
                  _selectedEmpId = v;
                  _items.clear();
                  _loadedIds.clear();
                  _lastDoc = null;
                  _hasMore = true;
                  _newestLogDate = null;
                  _liveSub?.cancel();
                  _liveSub = null;
                });
                _loadMore();
              },
            ),
          ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: _items.isEmpty && _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('No employee history'))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _items.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _items.length) {
                            if (!_loading) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) => _loadMore());
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 24,
                            child: _buildRow(_items[index]),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
