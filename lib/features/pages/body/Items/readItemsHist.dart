//########################### Supplies History ###############################
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/database_items_history.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

class ReadDataItemsHistoryWidget extends StatefulWidget {
  const ReadDataItemsHistoryWidget({super.key});

  @override
  State<ReadDataItemsHistoryWidget> createState() =>
      _ReadDataItemsHistoryWidgetState();
}

class _ReadDataItemsHistoryWidgetState
    extends State<ReadDataItemsHistoryWidget> {
  late ScrollController _scrollController;
  late DatabaseItemsHist dbItemsHist;
  List<SuppliesModelHist> allItems = [];
  List<SuppliesModelHist> displayedItems = [];
  int itemsPerPage = 50;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    dbItemsHist = DatabaseItemsHist();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final snapshot = await dbItemsHist.getItemsHistory(false).first;
    final docs = snapshot.docs;

    setState(() {
      allItems = docs.map((doc) => doc.data() as SuppliesModelHist).toList();
      displayedItems = allItems.take(itemsPerPage).toList();
      hasMore = allItems.length > itemsPerPage;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final currentLength = displayedItems.length;
    final nextBatch = allItems.skip(currentLength).take(itemsPerPage).toList();

    setState(() {
      displayedItems.addAll(nextBatch);
      hasMore = displayedItems.length < allItems.length;
      isLoading = false;
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
        Flexible(
          child: displayedItems.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: displayedItems.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayedItems.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final sMH = displayedItems[index];
                    return SizedBox(
                      height: 24,
                      child: _buildItemRow(sMH),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Widget readDataItemsHistory() {
  return const ReadDataItemsHistoryWidget();
}
