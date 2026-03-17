//########################### Supplies Current ###############################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';


class ReadDataSuppliesCurrent extends StatefulWidget {
  const ReadDataSuppliesCurrent({super.key});

  @override
  State<ReadDataSuppliesCurrent> createState() =>
      _ReadDataSuppliesCurrentState();
}

class _ReadDataSuppliesCurrentState extends State<ReadDataSuppliesCurrent> {
  late ScrollController _scrollController;
  late DatabaseSuppliesCurrent databaseSuppliesCurrent;
  List<SuppliesModelHist> allSupplies = [];
  List<SuppliesModelHist> displayedSupplies = [];
  int itemsPerPage = 50;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    databaseSuppliesCurrent = DatabaseSuppliesCurrent();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final snapshot = await databaseSuppliesCurrent.getSuppliesCurrent().first;
    final docs = snapshot.docs;

    setState(() {
      allSupplies = docs.map((doc) => doc.data() as SuppliesModelHist).toList();
      displayedSupplies = allSupplies.take(itemsPerPage).toList();
      hasMore = allSupplies.length > itemsPerPage;
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

    final currentLength = displayedSupplies.length;
    final nextBatch =
        allSupplies.skip(currentLength).take(itemsPerPage).toList();

    setState(() {
      displayedSupplies.addAll(nextBatch);
      hasMore = displayedSupplies.length < allSupplies.length;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📦✨ SUPPLIES CURRENT", style: TextStyle(color: Colors.white)),
          ],
        ),
        Flexible(
          child: displayedSupplies.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: displayedSupplies.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayedSupplies.length - 1) {
                      _loadMore();
                    }

                    if (index == displayedSupplies.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final sMH = displayedSupplies[index];
                    if (sMH.itemId == menuOthCashInOutFunds) {
                      alwaysTheLatestFunds = sMH.currentStocks;
                    }

                    final isAlert = sMH.currentStocks <=
                        getItemNameStocksAlert(sMH.itemId, sMH.itemUniqueId);

                    return SizedBox(
                      height: 24,
                      child: Container(
                        color: isAlert ? cRiderPickup : cWaiting,
                        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  nameForSuppliesCurrent(sMH.itemId, sMH.itemUniqueId),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "(${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)})",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                getItemNameStocksType(sMH.itemId, sMH.itemUniqueId) ==
                                        "php"
                                    ? "₱ ${value.format(sMH.currentStocks)}"
                                    : value.format(sMH.currentStocks),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

Widget readDataSuppliesCurrent() {
  return const ReadDataSuppliesCurrent();
}
