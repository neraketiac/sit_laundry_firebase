import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/database_item_models/database_other_items.dart';
import 'package:laundry_firebase/core/services/database_item_models/database_other_items_hist.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';

class OtherItemsPage extends StatefulWidget {
  const OtherItemsPage({super.key});

  @override
  State<OtherItemsPage> createState() => _OtherItemsPageState();
}

class _OtherItemsPageState extends State<OtherItemsPage> {
  final service = OtherItemsService();
  final histService = OtherItemsServiceHist();

  List<OtherItemModel> items = [];
  List<OtherItemModel> deletedItems = [];

  final Map<int, TextEditingController> itemIdCtrls = {};
  final Map<int, TextEditingController> uniqueCtrls = {};
  final Map<int, TextEditingController> nameCtrls = {};
  final Map<int, TextEditingController> priceCtrls = {};
  final Map<int, TextEditingController> alertCtrls = {};
  final Map<int, TextEditingController> typeCtrls = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    items = await service.getItems();

    /// ensure correct order
    items.sort((a, b) => a.itemId.compareTo(b.itemId));

    itemIdCtrls.clear();
    uniqueCtrls.clear();
    nameCtrls.clear();
    priceCtrls.clear();
    alertCtrls.clear();
    typeCtrls.clear();

    for (int i = 0; i < items.length; i++) {
      _createControllers(i);
    }

    setState(() {
      loading = false;
    });
  }

  void _createControllers(int index) {
    final item = items[index];

    itemIdCtrls[index] = TextEditingController(text: item.itemId.toString());

    uniqueCtrls[index] =
        TextEditingController(text: item.itemUniqueId.toString());

    nameCtrls[index] = TextEditingController(text: item.itemName);

    priceCtrls[index] = TextEditingController(text: item.itemPrice.toString());

    alertCtrls[index] =
        TextEditingController(text: item.stocksAlert.toString());

    typeCtrls[index] = TextEditingController(text: item.stocksType);
  }

  /// ADD ROW
  void addRow() {
    int nextItemId = 1;
    int nextUniqueId = 1;

    if (items.isNotEmpty) {
      final last = items.last;

      nextItemId = last.itemId + 1;
      nextUniqueId = last.itemUniqueId + 1;
    }

    final newItem = OtherItemModel.makeEmpty().coyWith(
      itemGroup: groupOth,
      itemId: nextItemId,
      itemUniqueId: nextUniqueId,
    );

    items.add(newItem);

    _createControllers(items.length - 1);

    setState(() {});
  }

  Future<void> deleteRow(int index) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            )
          ],
        );
      },
    );

    if (ok != true) return;

    final item = items[index];

    if (item.docId.isNotEmpty) {
      deletedItems.add(item);
    }

    items.removeAt(index);

    setState(() {});
  }

  Future<void> saveAll() async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Save all changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Save"),
            )
          ],
        );
      },
    );

    if (ok != true) return;

    /// DELETE
    for (var item in deletedItems) {
      await service.deleteItem(item.docId);
      await histService.logAction(item, "delete");
    }

    /// INSERT / UPDATE
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      final updated = item.coyWith(
        // itemId and itemUniqueId are locked for existing records
        itemId: item.docId.isEmpty
            ? (int.tryParse(itemIdCtrls[i]?.text ?? "0") ?? 0)
            : item.itemId,
        itemUniqueId: item.docId.isEmpty
            ? (int.tryParse(uniqueCtrls[i]?.text ?? "0") ?? 0)
            : item.itemUniqueId,
        itemName: nameCtrls[i]?.text ?? "",
        itemPrice: int.tryParse(priceCtrls[i]?.text ?? "0") ?? 0,
        stocksAlert: int.tryParse(alertCtrls[i]?.text ?? "0") ?? 0,
        stocksType: typeCtrls[i]?.text ?? "",
        logDate: Timestamp.now(),
      );

      if (item.docId.isEmpty) {
        final newItem = await service.addItem(updated);
        await histService.logAction(newItem, "insert");
      } else {
        await service.updateItem(updated);
        await histService.logAction(updated, "update");
      }
    }

    deletedItems.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved")));

    await load();
  }

  Widget cell(TextEditingController ctrl,
      {double width = 120, bool numeric = false}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: ctrl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget readOnlyCell(String value, {double width = 120}) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Other Items Maintenance"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        children: [
                          SizedBox(width: 50),
                          SizedBox(width: 90, child: Text("ItemId")),
                          SizedBox(width: 120, child: Text("UniqueId")),
                          SizedBox(width: 220, child: Text("Item Name")),
                          SizedBox(width: 100, child: Text("Price")),
                          SizedBox(width: 120, child: Text("Alert")),
                          SizedBox(width: 120, child: Text("Type")),
                          SizedBox(width: 80, child: Text("Del")),
                        ],
                      ),
                    ),

                    /// IF NO RECORDS → show only ADD button
                    if (items.isEmpty)
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: addRow,
                            ),
                          ),
                          const SizedBox(width: 90),
                          const SizedBox(width: 120),
                          const SizedBox(width: 220),
                          const SizedBox(width: 100),
                          const SizedBox(width: 120),
                          const SizedBox(width: 120),
                          const SizedBox(width: 80),
                        ],
                      ),

                    /// NORMAL LIST
                    ...List.generate(items.length, (index) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: index == items.length - 1
                                ? IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: addRow,
                                  )
                                : const SizedBox(),
                          ),
                          items[index].docId.isEmpty
                              ? cell(itemIdCtrls[index]!,
                                  width: 90, numeric: true)
                              : readOnlyCell(itemIdCtrls[index]!.text,
                                  width: 90),
                          items[index].docId.isEmpty
                              ? cell(uniqueCtrls[index]!,
                                  width: 120, numeric: true)
                              : readOnlyCell(uniqueCtrls[index]!.text,
                                  width: 120),
                          cell(nameCtrls[index]!, width: 220),
                          cell(priceCtrls[index]!, width: 100, numeric: true),
                          cell(alertCtrls[index]!, width: 120, numeric: true),
                          cell(typeCtrls[index]!, width: 120),
                          SizedBox(
                            width: 80,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteRow(index);
                              },
                            ),
                          ),
                        ],
                      );
                    })
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: saveAll,
                  child: const Text("Save"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
