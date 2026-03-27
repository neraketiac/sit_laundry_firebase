//########################### Supplies History ###############################
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';
import 'package:laundry_firebase/core/services/database_items_history.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class ReadDataItemsHistoryWidget extends StatefulWidget {
  const ReadDataItemsHistoryWidget({super.key});

  @override
  State<ReadDataItemsHistoryWidget> createState() =>
      _ReadDataItemsHistoryWidgetState();
}

class _ReadDataItemsHistoryWidgetState
    extends State<ReadDataItemsHistoryWidget> {
  final List<SuppliesModelHist> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  late ScrollController _scrollController;
  late DatabaseItemsHist dbItemsHist;
  StreamSubscription? _newDocSub;
  Timestamp? _newestLogDate;

  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    dbItemsHist = DatabaseItemsHist();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newDocSub?.cancel();
    super.dispose();
  }

  void _startNewDocListener() {
    _newDocSub?.cancel();
    if (_newestLogDate == null) return;
    _newDocSub = FirebaseFirestore.instance
        .collection('ItemsHist')
        .orderBy('LogDate', descending: true)
        .where('LogDate', isGreaterThan: _newestLogDate)
        .snapshots()
        .listen((snap) {
      if (!mounted || snap.docs.isEmpty) return;
      final incoming =
          snap.docs.map((d) => SuppliesModelHist.fromJson(d.data())).toList();
      setState(() {
        _items.insertAll(0, incoming);
        _newestLogDate = snap.docs.first.data()['LogDate'] as Timestamp?;
      });
    });
  }

  Future<void> _refresh() async {
    _newDocSub?.cancel();
    setState(() {
      _items.clear();
      _lastDoc = null;
      _hasMore = true;
      _newestLogDate = null;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    final snap = await dbItemsHist.getItemsHistoryPaginated(lastDoc: _lastDoc);
    final newItems =
        snap.docs.map((d) => d.data() as SuppliesModelHist).toList();

    setState(() {
      _loading = false;
      if (newItems.length < _pageSize) _hasMore = false;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      _items.addAll(newItems);
      if (_newestLogDate == null && snap.docs.isNotEmpty) {
        final firstData = snap.docs.first.data() as SuppliesModelHist;
        _newestLogDate = firstData.logDate;
        _startNewDocListener();
      }
    });
  }

  Widget _buildItemRow(SuppliesModelHist sMH) {
    bool bNegative = (sMH.currentCounter < 0 ? true : false);
    bool bNegativePCF = (sMH.currentStocks < 0 ? true : false);

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
                color: (bNegative
                    ? Color.fromARGB(255, 185, 57, 48)
                    : Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "₱${value.format(sMH.expenseAmount)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 185, 57, 48),
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
        color: Colors.grey[400],
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
            (getItemNameStocksType(sMH.itemId, sMH.itemUniqueId) == 'php'
                ? "₱${value.format(sMH.currentCounter)}"
                : "${value.format(sMH.currentCounter)} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)}"),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: (bNegative
                  ? Color.fromARGB(255, 185, 57, 48)
                  : Color(0xFF0D47A1)),
            ),
          ),
          const SizedBox(width: 4),
          if ((sMH.expenseAmount ?? 0) > 0)
            Text(
              "₱${value.format(sMH.expenseAmount)}",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 185, 57, 48),
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
            (getItemNameStocksType(sMH.itemId, sMH.itemUniqueId) == 'php'
                ? "pCF ₱${value.format(sMH.currentStocks)}"
                : "pCF ${value.format(sMH.currentStocks)} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)}"),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📑✨ ITEMS HISTORY", style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: _items.isEmpty && _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? const Center(child: Text('No items history'))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scrollController,
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
                            child: _buildItemRow(_items[index]),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

Widget readDataItemsHistory() {
  return const ReadDataItemsHistoryWidget();
}
