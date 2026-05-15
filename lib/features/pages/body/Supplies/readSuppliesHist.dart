//########################### Supplies History ###############################
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_funds_history.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

final DatabaseFundsHist dbFundsHist = DatabaseFundsHist();

Widget _buildSupplyRow(SuppliesModelHist sMH) {
  bool bNegative = (sMH.currentCounter < 0 ? true : false);
  bool bNegativePCF = (sMH.currentStocks < 0 ? true : false);

  // Determine if this is Funds In transaction
  final isFundsIn = sMH.itemUniqueId == 4403;

  if (ifMenuUniqueIsEOD(sMH)) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cFundsEOD,
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 89, 89, 89),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
            style: TextStyle(
              fontSize: 9,
              color: const Color.fromARGB(255, 68, 68, 68),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "₱${value.format(sMH.currentCounter)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isFundsIn
                  ? const Color(0xFF0D47A1) // Blue for Funds In
                  : (bNegative
                      ? const Color.fromARGB(
                          255, 185, 57, 48) // Red for negative
                      : const Color(0xFF0D47A1)), // Blue for positive
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "${sMH.itemName} by ${sMH.empId} : ${sMH.remarks}",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
          ),
          Text(
            " pCF ₱${value.format(sMH.currentStocks)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (bNegativePCF
                  ? Color.fromARGB(255, 185, 57, 48)
                  : Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }

  return Container(
    height: 22,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: isFundsIn ? Colors.green.shade100 : Colors.grey[400],
      border: Border(
        bottom: BorderSide(
          color: const Color.fromARGB(255, 89, 89, 89),
          width: 0.6,
        ),
      ),
    ),
    child: Row(
      children: [
        Text(
          DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
          style: TextStyle(
            fontSize: 9,
            color: const Color.fromARGB(255, 68, 68, 68),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "₱${value.format(sMH.currentCounter)}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isFundsIn
                ? const Color(0xFF0D47A1) // Blue for Funds In
                : (bNegative
                    ? const Color.fromARGB(255, 185, 57, 48) // Red for negative
                    : const Color(0xFF0D47A1)), // Blue for positive
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName} : ${sMH.remarks}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ),
        Text(
          sMH.empId,
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
        ),
        Text(
          "pCF ₱${value.format(sMH.currentStocks)}",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: (bNegativePCF
                ? Color.fromARGB(255, 185, 57, 48)
                : Color(0xFF0D47A1)),
          ),
        ),
      ],
    ),
  );
}

Widget readDataSuppliesHistory() {
  return const _SuppliesHistoryList();
}

class _SuppliesHistoryList extends StatefulWidget {
  const _SuppliesHistoryList();

  @override
  State<_SuppliesHistoryList> createState() => _SuppliesHistoryListState();
}

class _SuppliesHistoryListState extends State<_SuppliesHistoryList> {
  final List<SuppliesModelHist> _liveItems = []; // Real-time first page items
  final List<SuppliesModelHist> _paginatedItems = []; // Older paginated items
  final Set<String> _loadedIds = {};
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  final ScrollController _scroll = ScrollController();
  StreamSubscription? _newDocSub;
  Timestamp? _newestLogDate;

  static const int _pageSize = 30;

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
    _newDocSub?.cancel();
    super.dispose();
  }

  void _startNewDocListener() {
    _newDocSub?.cancel();
    // Listen to the first page — handles adds, updates AND deletes
    _newDocSub = FirebaseService.suppliesFirestore
        .collection('SuppliesHist')
        .orderBy('LogDate', descending: true)
        .limit(_pageSize)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;

      final liveDocs =
          snap.docs.map((d) => SuppliesModelHist.fromJson(d.data())).toList();
      final liveIds = snap.docs.map((d) => d.id).toSet();

      setState(() {
        // Update only the live items (first page)
        _liveItems
          ..clear()
          ..addAll(liveDocs);

        // Update loaded IDs for first page
        _loadedIds
          ..removeWhere((id) => !liveIds.contains(id))
          ..addAll(liveIds);

        if (snap.docs.isNotEmpty) {
          _newestLogDate = snap.docs.first.data()['LogDate'] as Timestamp?;
        }
      });
    });
  }

  Future<void> _refresh() async {
    _newDocSub?.cancel();
    setState(() {
      _liveItems.clear();
      _paginatedItems.clear();
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

    final snap = await dbFundsHist.getSuppliesHistoryPaginated(
      false,
      lastDoc: _lastDoc,
    );

    final newItems =
        snap.docs.map((d) => d.data() as SuppliesModelHist).toList();

    setState(() {
      _loading = false;
      if (newItems.length < _pageSize) _hasMore = false;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;

      // Add only new items to paginated list
      for (int i = 0; i < snap.docs.length; i++) {
        if (!_loadedIds.contains(snap.docs[i].id)) {
          _loadedIds.add(snap.docs[i].id);
          _paginatedItems.add(newItems[i]);
        }
      }

      // Start real-time listener on first load
      if (_newestLogDate == null && snap.docs.isNotEmpty) {
        final firstData = snap.docs.first.data() as SuppliesModelHist;
        _newestLogDate = firstData.logDate;
        _startNewDocListener();
      }
      FsUsageTracker.instance.track('readSuppliesHist', snap.docs.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Combine live items (top) with paginated items (bottom)
    final allItems = [..._liveItems, ..._paginatedItems];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊💰 FUNDS HISTORY', style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: allItems.isEmpty && _loading
              ? const Center(child: CircularProgressIndicator())
              : allItems.isEmpty
                  ? const Center(child: Text('No supplies history'))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: allItems.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == allItems.length) {
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
                              )),
                            );
                          }
                          return SizedBox(
                            height: 24,
                            child: _buildSupplyRow(allItems[index]),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
