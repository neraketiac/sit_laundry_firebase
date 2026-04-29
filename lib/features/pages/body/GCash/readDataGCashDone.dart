import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/services/database_gcash.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/showUploadedImage.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';

Widget readDataGCashDone() => const _GCashDoneWidget();

class _GCashDoneWidget extends StatefulWidget {
  const _GCashDoneWidget();

  @override
  State<_GCashDoneWidget> createState() => _GCashDoneWidgetState();
}

class _GCashDoneWidgetState extends State<_GCashDoneWidget> {
  static const int _pageSize = 10;

  final List<GCashModel> _items = [];
  final Set<String> _loadedIds = {};

  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  int? _selectedIndex;

  final ScrollController _scroll = ScrollController();
  final DatabaseGCashDone _db = DatabaseGCashDone();

  StreamSubscription? _liveSub;

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

  // ✅ REALTIME (SAFE MERGE, NO UI CHANGE)
  void _startLiveListener() {
    _liveSub?.cancel();

    _liveSub = _db.streamTop(_pageSize).listen((snap) {
      if (!mounted) return;

      final docs = snap.docs;

      setState(() {
        for (int i = 0; i < docs.length; i++) {
          final doc = docs[i];
          final id = doc.id;

          final newItem = GCashModel.fromJson(doc.data())..docId = id;

          final index = _items.indexWhere((e) => e.docId == id);

          if (index >= 0) {
            // 🔁 update existing
            _items[index] = newItem;
          } else {
            // ➕ insert new at top
            _items.insert(i, newItem);
            _loadedIds.add(id);
          }
        }
      });
    });
  }

  // ✅ PAGINATION (UNCHANGED LOGIC + docId fix)
  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    final snap = await _db.fetchPaginated(lastDoc: _lastDoc);
    final docs = snap.docs;

    final newItems = docs.map((d) => GCashModel.fromJson(d.data())).toList();

    setState(() {
      _loading = false;

      if (newItems.length < _pageSize) _hasMore = false;
      if (docs.isNotEmpty) _lastDoc = docs.last;

      for (int i = 0; i < docs.length; i++) {
        final id = docs[i].id;

        if (!_loadedIds.contains(id)) {
          _loadedIds.add(id);
          newItems[i].docId = id; // ✅ IMPORTANT FIX
          _items.add(newItems[i]);
        }
      }

      // 🚀 start realtime AFTER first load
      if (_liveSub == null && docs.isNotEmpty) {
        _startLiveListener();
      }

      FsUsageTracker.instance.track('readDataGCashDone', docs.length);
    });
  }

  Future<void> _refresh() async {
    _liveSub?.cancel();

    setState(() {
      _items.clear();
      _loadedIds.clear();
      _lastDoc = null;
      _hasMore = true;
      _selectedIndex = null;
    });

    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(child: Text('No completed GCash records'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            '✅ GCash Done',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scroll,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                          child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }

              final snapshotData = _items[index];
              final gRepo = GCashRepository()..setModel(snapshotData);
              final isSelected = _selectedIndex == index;
              final isDark = Theme.of(context).brightness == Brightness.dark;

              final cardBg = isSelected
                  ? (isDark ? Colors.green.shade900 : Colors.green.shade50)
                  : (isDark ? const Color(0xFF1E2E1E) : Colors.white);
              final borderCol = isSelected
                  ? Colors.green.shade400
                  : (isDark ? Colors.green.shade800 : Colors.grey.shade300);
              final primaryText = isSelected
                  ? (isDark ? Colors.green.shade200 : Colors.green.shade800)
                  : (isDark ? Colors.white : Colors.black87);
              final secondaryText =
                  isDark ? Colors.white60 : Colors.grey.shade600;
              final remarksText =
                  isDark ? Colors.white70 : Colors.grey.shade700;
              final badgeBg =
                  isDark ? Colors.green.shade900 : Colors.green.shade50;
              final badgeText =
                  isDark ? Colors.green.shade300 : Colors.green.shade700;
              final amountText =
                  isDark ? Colors.green.shade300 : Colors.green.shade700;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: borderCol, width: isSelected ? 2 : 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  value: gRepo.gCashStatus,
                                  strokeWidth: 4,
                                  color: Colors.green.shade400,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700, size: 22),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone Number with Copy Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gRepo.customerNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: primaryText,
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () async {
                                          final cleanNumber =
                                              gRepo.customerNumber.replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                          await Clipboard.setData(
                                            ClipboardData(text: cleanNumber),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Copied $cleanNumber ${gRepo.remarks}'),
                                              duration:
                                                  Duration(milliseconds: 800),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.copy,
                                            size: 18,
                                            color: isSelected
                                                ? Colors.deepPurple
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(gRepo.itemName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: badgeText,
                                              fontSize: 12)),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(Icons.access_time,
                                        size: 14, color: secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MM/dd hh:mm a')
                                          .format(gRepo.logDate.toDate()),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: secondaryText,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${gRepo.customerName}: ${gRepo.remarks}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: remarksText,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₱${NumberFormat('#,##0').format(gRepo.customerAmount)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: amountText),
                              ),
                              const SizedBox(height: 8),
                              showUploadedImage(context, gRepo),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
