import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/core/services/database_gcash.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';
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
            _items[index] = newItem;
          } else {
            _items.insert(i, newItem);
            _loadedIds.add(id);
          }
        }
      });
    });
  }

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
          newItems[i].docId = id;
          _items.add(newItems[i]);
        }
      }

      if (_liveSub == null && docs.isNotEmpty) {
        _startLiveListener();
      }

      FsUsageTracker.instance.track('readDataGCashDoneNewFormat', docs.length);
    });
  }

  Future<void> _refresh() async {
    _liveSub?.cancel();

    setState(() {
      _items.clear();
      _loadedIds.clear();
      _lastDoc = null;
      _hasMore = true;
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
            itemBuilder: _buildItem,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyImageViewer(
      BuildContext context, GCashRepository gRepo) {
    // Determine which image to show - prioritize whichever URL is not empty
    final String imageUrl = gRepo.cashInImageUrl.isNotEmpty
        ? gRepo.cashInImageUrl
        : gRepo.cashOutImageUrl;
    final IconData fallbackIcon =
        gRepo.cashOutImageUrl.isNotEmpty && gRepo.cashInImageUrl.isEmpty
            ? Icons.logout
            : Icons.login;

    // Only show SS link if image exists
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('GCash Receipt'),
            content: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    fallbackIcon,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          'SS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == _items.length) {
      if (!_loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final snapshotData = _items[index];
    final gRepo = GCashRepository()..setModel(snapshotData);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2E1E) : Colors.white;
    final borderCol = isDark ? Colors.green.shade800 : Colors.grey.shade300;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white60 : Colors.grey.shade600;
    final amountText = isDark ? Colors.green.shade300 : Colors.green.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Phone Number, Copy Icon, Amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    gRepo.customerNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: primaryText,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final cleanNumber = gRepo.customerNumber
                          .replaceAll(RegExp(r'[^0-9]'), '');
                      await Clipboard.setData(
                        ClipboardData(text: cleanNumber),
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied $cleanNumber'),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.copy,
                        size: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₱${NumberFormat('#,##0').format(gRepo.customerAmount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: amountText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Row 2: Date, LogBy, Remarks, SS Link
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${gRepo.itemName} : ${DateFormat('MM/dd hh:mm a').format(gRepo.logDate.toDate())} : ${gRepo.logBy} : ${gRepo.remarks}',
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 6),
                // SS Link - view only image display
                _buildReadOnlyImageViewer(context, gRepo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
