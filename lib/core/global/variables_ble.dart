import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listBleItemsFB = [];
List<OtherItemModel> listBleItems = [];

final addBleItemModel = OtherItemModel(
  docId: "",
  itemId: menuBleColorSafeDVal,
  itemUniqueId: menuBleColorSafeDVal,
  itemGroup: groupFab,
  itemName: "CS(30ml ₱5)",
  itemPrice: 5,
  stocksAlert: 5,
  stocksType: "ml",
  logDate: timestamp1900,
);

void addListBleItems() {
  //bel items
  listBleItems.add(OtherItemModel(
    docId: "",
    itemId: menuBleColorSafeDVal,
    itemUniqueId: menuBleColorSafeDVal,
    itemGroup: groupBle,
    itemName: "Color Safe",
    itemPrice: 5,
    stocksAlert: 2,
    stocksType: "btl",
    logDate: timestamp1900,
  ));
}
