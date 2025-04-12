import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/variables/variables.dart';

List<OtherItemModel> listBleItems = [];

//bleach
Map<int, String> mapBleNames = {};
const int menuBleOriginalDVal = 302, menuBleColorSafeDVal = 301;

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
