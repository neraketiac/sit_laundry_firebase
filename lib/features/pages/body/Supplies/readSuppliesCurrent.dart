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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    databaseSuppliesCurrent = DatabaseSuppliesCurrent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: StreamBuilder(
            stream: databaseSuppliesCurrent.getSuppliesCurrent(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final docs = snapshot.data!.docs;
              final supplies = docs.map((doc) => doc.data() as SuppliesModelHist).toList();
              
              if (supplies.isEmpty) {
                return const Center(child: Text('No supplies data'));
              }
              
              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: supplies.length,
                itemBuilder: (context, index) {
                  final sMH = supplies[index];
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
