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
    // Determine if fund check was done in morning (before 12nn) or afternoon
    final logTime = sMH.logDate.toDate();
    final isMorning = logTime.hour < 12;
    final rowColor = isMorning
        ? Colors.purple.shade200 // Light purple for morning
        : cFundsEOD; // Original color for afternoon

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 89, 89, 89),
            width: 0.6,
          ),
        ),
      ),
      child: isAdmin
          ? Row(
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
            )
          : Row(
              children: [
                Text(
                  DateFormat('MM/dd hh:mm a').format(sMH.logDate.toDate()),
                  style: TextStyle(
                    fontSize: 9,
                    color: const Color.fromARGB(255, 68, 68, 68),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Fund Check by ${sMH.empId} : ${sMH.remarks}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "₱${value.format(sMH.currentStocks + sMH.currentCounter)}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D47A1),
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
    child: isAdmin
        ? Row(
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
          )
        : Row(
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
                  "${sMH.itemName} ${ifMenuUniqueIsCashIn(sMH) ? 'to' : 'by'} ${sMH.customerName} : ${sMH.remarks}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
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

  // Auto-reload properties
  bool _hasError = false;
  Timer? _autoReloadTimer;
  int _autoReloadAttempts = 0;
  static const int _maxAutoReloadAttempts = 5;
  static const Duration _initialReloadDelay = Duration(seconds: 3);

  static const int _pageSize = 30;
  static const int _nonAdminLimit =
      50; // Non-admin users can only see 50 records

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
    _autoReloadTimer?.cancel();
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

      setState(() {
        // Only keep items that are NOT in the paginated list (avoid duplicates)
        _liveItems.clear();
        for (var doc in snap.docs) {
          if (!_loadedIds.contains(doc.id)) {
            _liveItems.add(SuppliesModelHist.fromJson(doc.data()));
          }
        }

        if (snap.docs.isNotEmpty) {
          _newestLogDate = snap.docs.first.data()['LogDate'] as Timestamp?;
          _hasError = false; // Clear error on successful load
          _autoReloadAttempts = 0; // Reset retry attempts
          _autoReloadTimer?.cancel();
        }
      });
    }, onError: (e) {
      if (!mounted) return;
      // On listener error, trigger auto-reload
      _scheduleAutoReload();
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

    // Check if non-admin user has reached the limit
    if (!isAdmin &&
        (_liveItems.length + _paginatedItems.length) >= _nonAdminLimit) {
      setState(() => _hasMore = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final snap = await dbFundsHist.getSuppliesHistoryPaginated(
        false,
        lastDoc: _lastDoc,
      );

      final newItems =
          snap.docs.map((d) => d.data() as SuppliesModelHist).toList();

      setState(() {
        _loading = false;
        _hasError = false; // Clear error on successful load
        _autoReloadAttempts = 0; // Reset retry attempts
        _autoReloadTimer?.cancel();

        // Add only new items to paginated list
        for (int i = 0; i < snap.docs.length; i++) {
          if (!_loadedIds.contains(snap.docs[i].id)) {
            // For non-admin users, check if we've reached the limit
            if (!isAdmin &&
                (_liveItems.length + _paginatedItems.length) >=
                    _nonAdminLimit) {
              _hasMore = false;
              break;
            }
            _loadedIds.add(snap.docs[i].id);
            _paginatedItems.add(newItems[i]);
          }
        }

        // Determine if there are more items to load
        if (newItems.length < _pageSize) {
          _hasMore = false;
        } else if (!isAdmin &&
            (_liveItems.length + _paginatedItems.length) >= _nonAdminLimit) {
          _hasMore = false;
        }

        if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;

        // Start real-time listener on first load
        if (_newestLogDate == null && snap.docs.isNotEmpty) {
          final firstData = snap.docs.first.data() as SuppliesModelHist;
          _newestLogDate = firstData.logDate;
          _startNewDocListener();
        }
        FsUsageTracker.instance.track('readSuppliesHist', snap.docs.length);
      });
    } catch (e) {
      setState(() => _loading = false);
      _scheduleAutoReload();
    }
  }

  void _scheduleAutoReload() {
    if (_autoReloadAttempts >= _maxAutoReloadAttempts) {
      // Max retries reached, mark as error and show message
      setState(() => _hasError = true);
      return;
    }

    _autoReloadTimer?.cancel();

    // Exponential backoff: 3s, 6s, 12s, 24s, 48s
    final delaySecs =
        _initialReloadDelay.inSeconds * (1 << _autoReloadAttempts);
    final delay = Duration(seconds: delaySecs);

    _autoReloadTimer = Timer(delay, () {
      if (!mounted) return;
      _autoReloadAttempts++;
      _loadMore();
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
              : allItems.isEmpty && _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No data (auto-retrying...)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Attempt ${_autoReloadAttempts}/$_maxAutoReloadAttempts',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _refresh(),
                            child: const Text('Refresh Now'),
                          ),
                        ],
                      ),
                    )
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
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
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
