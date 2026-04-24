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
  static const int _pageSize = 20;

  final List<GCashModel> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  int? _selectedIndex;
  final ScrollController _scroll = ScrollController();
  final _db = DatabaseGCashDone();

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
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    final snap = await _db.fetchPaginated(lastDoc: _lastDoc);
    final newItems =
        snap.docs.map((d) => GCashModel.fromJson(d.data())).toList();

    setState(() {
      _loading = false;
      if (newItems.length < _pageSize) _hasMore = false;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      _items.addAll(newItems);
      FsUsageTracker.instance.track('readDataGCashDone', snap.docs.length);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
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
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 12 : 4,
                          offset: Offset(0, isSelected ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  value: gRepo.gCashStatus,
                                  strokeWidth: 4,
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.green.shade400,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700, size: 22),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    if (gRepo.customerNumber.isNotEmpty)
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: gRepo.customerNumber
                                                  .replaceAll(
                                                      RegExp(r'[^0-9]'), '')));
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Customer number copied'),
                                              duration:
                                                  Duration(milliseconds: 800),
                                            ));
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(Icons.copy,
                                              size: 18, color: primaryText),
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
                                    SizedBox(width: 5),
                                    Icon(Icons.access_time,
                                        size: 14, color: secondaryText),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        DateFormat('MM/dd hh:mm a')
                                            .format(gRepo.logDate.toDate()),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: secondaryText,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                if (gRepo.customerName.isNotEmpty ||
                                    gRepo.remarks.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${gRepo.customerName}${gRepo.customerName.isNotEmpty && gRepo.remarks.isNotEmpty ? ": " : ""}${gRepo.remarks}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: remarksText,
                                        fontSize: 12),
                                  ),
                                ],
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
