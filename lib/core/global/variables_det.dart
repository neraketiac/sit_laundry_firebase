import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listDetItems = [];

//det
Map<int, String> mapDetNames = {};
Map<int, int> mapDetPrice = {};
const int menuDetBreezeDVal = 103,
    menuDetArielDVal = 101,
    menuDetTideDVal = 104,
    menuDetWingsBlueDVal = 105,
    menuDetWingsRedDVal = 107,
    menuDetWKL = 106,
    menuDetSurfDVal = 102,
    menuDetKlinDVal = 108,
    menuDetWKL15 = 109,
    menuDetAriel3P = 110;

void addListDetItems() {
  //detItems
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetBreezeDVal,
      itemUniqueId: menuDetBreezeDVal,
      itemGroup: groupDet,
      itemName: "Breeze",
      itemPrice: 15,
      stocksAlert: 5,
      stocksType: "pcs"));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetArielDVal,
    itemUniqueId: menuDetArielDVal,
    itemGroup: groupDet,
    itemName: "Ariel",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetTideDVal,
    itemUniqueId: menuDetTideDVal,
    itemGroup: groupDet,
    itemName: "Tide",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetWingsBlueDVal,
    itemUniqueId: menuDetWingsBlueDVal,
    itemGroup: groupDet,
    itemName: "Wings B",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetWingsRedDVal,
    itemUniqueId: menuDetWingsRedDVal,
    itemGroup: groupDet,
    itemName: "Wings R",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetWKL,
    itemUniqueId: menuDetWKL,
    itemGroup: groupDet,
    itemName: "WKL",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "btl",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetWKL,
    itemUniqueId: menuDetWKL15,
    itemGroup: groupDet,
    itemName: "WKL15",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "btl",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetWKL,
    itemUniqueId: menuDetAriel3P,
    itemGroup: groupDet,
    itemName: "Ariel 3P",
    itemPrice: 18,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetSurfDVal,
    itemUniqueId: menuDetSurfDVal,
    itemGroup: groupDet,
    itemName: "Surf",
    itemPrice: 10,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listDetItems.add(OtherItemModel(
    docId: "",
    itemId: menuDetKlinDVal,
    itemUniqueId: menuDetKlinDVal,
    itemGroup: groupDet,
    itemName: "Klin",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "pcs",
  ));

  //det names
  mapDetNames.addEntries({menuDetBreezeDVal: "Breeze"}.entries);
  mapDetNames.addEntries({menuDetArielDVal: "Ariel"}.entries);
  mapDetNames.addEntries({menuDetTideDVal: "Tide"}.entries);
  mapDetNames.addEntries({menuDetWingsBlueDVal: "Wings B"}.entries);
  mapDetNames.addEntries({menuDetWingsRedDVal: "Wings R"}.entries);
  mapDetNames.addEntries({menuDetWKL: "WKL"}.entries);
  mapDetNames.addEntries({menuDetWKL15: "WKL15"}.entries);
  mapDetNames.addEntries({menuDetSurfDVal: "Surf"}.entries);
  mapDetNames.addEntries({menuDetKlinDVal: "Klin"}.entries);

  //det price
  mapDetPrice.addEntries({menuDetBreezeDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetArielDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetTideDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetWingsBlueDVal: 8}.entries);
  mapDetPrice.addEntries({menuDetWingsRedDVal: 8}.entries);
  mapDetPrice.addEntries({menuDetWKL: 8}.entries);
  mapDetPrice.addEntries({menuDetWKL15: 15}.entries);
  mapDetPrice.addEntries({menuDetSurfDVal: 10}.entries);
  mapDetPrice.addEntries({menuDetKlinDVal: 15}.entries);
}
