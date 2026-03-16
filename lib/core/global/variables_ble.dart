import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listBleItems = [];

//bleach
Map<int, String> mapBleNames = {};

final addBleItemModel = OtherItemModel(
  docId: "",
  itemId: menuBleColorSafeDVal,
  itemUniqueId: menuBleColorSafeDVal,
  itemGroup: groupFab,
  itemName: "CS(30ml ₱5)",
  itemPrice: 5,
  stocksAlert: 5,
  stocksType: "ml",
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
  ));

  //ble names
  mapBleNames.addEntries({menuBleOriginalDVal: "Bleach OR(P5)"}.entries);
  mapBleNames.addEntries({menuBleColorSafeDVal: "Color S(P5)"}.entries);
}
