import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listOthItemsFB = [];

List<OtherItemModel> listOthItems = [];
List<OtherItemModel> listOthOnlyItems = [];

//others
final reg155ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOth155,
  itemUniqueId: menuOth155,
  itemGroup: groupOth,
  itemName: "Reg155",
  itemPrice: 155,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final nf155ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOthNF155,
  itemUniqueId: menuOthNF155,
  itemGroup: groupOth,
  itemName: "NF155",
  itemPrice: 143,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final nf125ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOthNF125,
  itemUniqueId: menuOthNF125,
  itemGroup: groupOth,
  itemName: "NF125",
  itemPrice: 108,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final washDryOnlytemModel = OtherItemModel(
  docId: "",
  itemId: menuOthWD98,
  itemUniqueId: menuOthWD98,
  itemGroup: groupOth,
  itemName: "WD98",
  itemPrice: 98,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final promoFree = OtherItemModel(
  docId: "",
  itemId: menuOthFree,
  itemUniqueId: menuOthFree,
  itemGroup: groupOth,
  itemName: "Free",
  itemPrice: -155,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final reg125ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOth125,
  itemUniqueId: menuOth125,
  itemGroup: groupOth,
  itemName: "Reg125",
  itemPrice: 125,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final reg150ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOth150,
  itemUniqueId: menuOth150,
  itemGroup: groupOth,
  itemName: "Reg150",
  itemPrice: 150,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final reg225ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOth150,
  itemUniqueId: menuOth150,
  itemGroup: groupOth,
  itemName: "Reg225",
  itemPrice: 225,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final xDItemModel = OtherItemModel(
  docId: "",
  itemId: menuOthXD,
  itemUniqueId: menuOthXD,
  itemGroup: groupOth,
  itemName: "Extra Dry",
  itemPrice: 15,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final xWashItemModel = OtherItemModel(
  docId: "",
  itemId: menuOthXW,
  itemUniqueId: menuOthXW,
  itemGroup: groupOth,
  itemName: "Extra Wash",
  itemPrice: 20,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final xSpinItemModel = OtherItemModel(
  docId: "",
  itemId: menuOthXS,
  itemUniqueId: menuOthXS,
  itemGroup: groupOth,
  itemName: "Extra Spin",
  itemPrice: 20,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

void addListOthItems() {
  //oth items
  listOthItems.add(reg155ItemModel);
  listOthItems.add(reg125ItemModel);
  listOthItems.add(reg150ItemModel);
  listOthItems.add(xDItemModel);
  listOthItems.add(xWashItemModel);
  listOthItems.add(xSpinItemModel);

  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthWash,
    itemUniqueId: menuOthWash,
    itemGroup: groupOth,
    itemName: "Wash",
    itemPrice: 49,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthDry,
    itemUniqueId: menuOthDry,
    itemGroup: groupOth,
    itemName: "Dry",
    itemPrice: 49,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));

  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthDO,
    itemUniqueId: menuOthDO,
    itemGroup: groupOth,
    itemName: "Drop Off",
    itemPrice: 10,
    stocksAlert: 1,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));

  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthDOF,
    itemUniqueId: menuOthDOF,
    itemGroup: groupOth,
    itemName: "Drop W/Fold",
    itemPrice: 30,
    stocksAlert: 1,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));

  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOth2W1DR,
    itemUniqueId: menuOth2W1DR,
    itemGroup: groupOth,
    itemName: "2W 1D(R)",
    itemPrice: 195,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOth2W1DSS,
    itemUniqueId: menuOth2W1DSS,
    itemGroup: groupOth,
    itemName: "2W 1D(SS)",
    itemPrice: 165,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));

  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthXR,
    itemUniqueId: menuOthXR,
    itemGroup: groupOth,
    itemName: "Extra Rinse",
    itemPrice: 20,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(nf125ItemModel);
  listOthItems.add(washDryOnlytemModel);
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF165,
    itemUniqueId: menuOthNF165,
    itemGroup: groupOth,
    itemName: "NF165",
    itemPrice: 157,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(nf155ItemModel);
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF195,
    itemUniqueId: menuOthNF195,
    itemGroup: groupOth,
    itemName: "NF195",
    itemPrice: 192,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthW8t9,
    itemUniqueId: menuOthW8t9,
    itemGroup: groupOth,
    itemName: "Reg190",
    itemPrice: 35,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthW9t10,
    itemUniqueId: menuOthW9t10,
    itemGroup: groupOth,
    itemName: "Reg260",
    itemPrice: 105,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: timestamp1900,
  ));
  // listOthItems.add(OtherItemModel(
  //   docId: "",
  //   itemId: menuOthW10t11,
  //   itemUniqueId: menuOthW10t11,
  //   itemGroup: groupOth,
  //   itemName: "Plastic",
  //   itemPrice: 2,
  //   stocksAlert: 10,
  //   stocksType: "pcs",
  //   logDate: timestamp1900,
  // ));
  if (isAdmin) listOthItems.add(promoFree);
}
