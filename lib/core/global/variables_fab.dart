import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listFabItems = [];

//fab
Map<int, String> mapFabNames = {};
const int menuFabSurf24mlDVal = 201,
    menuFabDowny24mlDVal = 202,
    menuFabDownyTripidDVal = 203,
    menuFabDowny36mlDVal = 204,
    menuFabSurfTripidDVal = 205,
    // menuFabWKLDVal = 2061,
    // menuFabWKL24mlDVal = 206,
    // menuFabWKL48mlDVal = 207,
    menuFabWKLDValPurpleDVal = 208,
    menuFabWKLDValPurple24mlDVal = 2081,
    menuFabWKLDValPurple48mlDVal = 2082,
    menuFabWKLDValPinkDVal = 209,
    menuFabWKLDValPink24mlDVal = 2091,
    menuFabWKLDValPink48mlDVal = 2092,
    menuFabWKLDValGreenDVal = 210,
    menuFabWKLDValGreen24mlDVal = 2101,
    menuFabWKLDValGreen48mlDVal = 2102,
    menuFabWKLDValAny8ml = 2103;

final addFabAnyItemModel = OtherItemModel(
  docId: "",
  itemId: menuFabWKLDValAny8ml,
  itemUniqueId: menuFabWKLDValAny8ml,
  itemGroup: groupFab,
  itemName: "WKL(any 8ml)",
  itemPrice: 8,
  stocksAlert: 5,
  stocksType: "pcs",
);
final addBleItemModel = OtherItemModel(
  docId: "",
  itemId: menuFabWKLDValAny8ml,
  itemUniqueId: menuFabWKLDValAny8ml,
  itemGroup: groupFab,
  itemName: "CS(30ml ₱5)",
  itemPrice: 5,
  stocksAlert: 5,
  stocksType: "ml",
);

void addListFabItems() {
  //fab items
  listFabItems.add(addFabAnyItemModel);
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabSurf24mlDVal,
    itemUniqueId: menuFabSurf24mlDVal,
    itemGroup: groupFab,
    itemName: "Surf 24",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabDowny24mlDVal,
    itemUniqueId: menuFabDowny24mlDVal,
    itemGroup: groupFab,
    itemName: "Downy 24/26",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabDownyTripidDVal,
    itemUniqueId: menuFabDownyTripidDVal,
    itemGroup: groupFab,
    itemName: "Downy 3P",
    itemPrice: 17,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabDowny36mlDVal,
    itemUniqueId: menuFabDowny36mlDVal,
    itemGroup: groupFab,
    itemName: "Downy 36",
    itemPrice: 10,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabSurfTripidDVal,
    itemUniqueId: menuFabSurfTripidDVal,
    itemGroup: groupFab,
    itemName: "Surf 3P",
    itemPrice: 17,
    stocksAlert: 5,
    stocksType: "pcs",
  ));

  //fab purple
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValPurpleDVal,
    itemUniqueId: menuFabWKLDValPurple24mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Ppl24",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "btl",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValPurpleDVal,
    itemUniqueId: menuFabWKLDValPurple48mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Ppl48",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "btl",
  ));

  //fab green
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValGreenDVal,
    itemUniqueId: menuFabWKLDValGreen24mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Grn24",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "btl",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValGreenDVal,
    itemUniqueId: menuFabWKLDValGreen48mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Grn48",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "btl",
  ));

  //pink
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValPinkDVal,
    itemUniqueId: menuFabWKLDValPink24mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Pnk24",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "btl",
  ));
  listFabItems.add(OtherItemModel(
    docId: "",
    itemId: menuFabWKLDValPinkDVal,
    itemUniqueId: menuFabWKLDValPink48mlDVal,
    itemGroup: groupFab,
    itemName: "WKL Pnk48",
    itemPrice: 15,
    stocksAlert: 5,
    stocksType: "btl",
  ));

  //fab names
  mapFabNames.addEntries({menuFabSurf24mlDVal: "Surf 24(P8)"}.entries);
  mapFabNames.addEntries({menuFabDowny24mlDVal: "Downy 24(P8)"}.entries);
  mapFabNames.addEntries({menuFabDownyTripidDVal: "Downy 3P(P17)"}.entries);
  mapFabNames.addEntries({menuFabDowny36mlDVal: "Downy 36(P10)"}.entries);
  mapFabNames.addEntries({menuFabSurfTripidDVal: "Surf 3P(P17)"}.entries);
  // mapFabNames.addEntries({menuFabWKL24mlDVal: "WKL Fab 24(P8)"}.entries);
  // mapFabNames.addEntries({menuFabWKL48mlDVal: "WKL Fab 48(P15)"}.entries);
}
