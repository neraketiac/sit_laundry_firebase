import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

List<OtherItemModel> listOthItems = [];

//others
Map<int, String> mapOthNames = {};
const int menuOthWash = 401,
    menuOth2W1DR = 402,
    menuOth2W1DSS = 403,
    menuOthDry = 404,
    menuOth195 = 405,
    menuOth165 = 406,
    menuOthXD = 407,
    menuOthXW = 408,
    menuOthXR = 409,
    menuOth155 = 410,
    menuOth125 = 411,
    menuOthDO = 412,
    menuOthDOF = 413,
    menuOthNF155 = 414,
    menuOthNF195 = 415,
    menuOthNF125 = 416,
    menuOthNF165 = 417,
    menuOthW8t9 = 418,
    menuOthW9t10 = 419,
    menuOthW10t11 = 420,
    menuOthW11t12 = 421,
    menuOthXS = 422,
    menuOthFree = 423;
const int menuOthUniqIdCashIn = 4401,
    menuOthUniqIdCashOut = 4402,
    menuOthUniqIdFundsIn = 4403,
    menuOthUniqIdFundsOut = 4404,
    menuOthLaundryPayment = 4405,
    menuOthSalaryPayment = 4406;

final reg155ItemModel = OtherItemModel(
  docId: "",
  itemId: menuOth155,
  itemUniqueId: menuOth155,
  itemGroup: groupOth,
  itemName: "Reg155",
  itemPrice: 155,
  stocksAlert: 5,
  stocksType: "pcs",
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
);

void addListOthItems() {
  //oth items
  listOthItems.add(reg155ItemModel);
  listOthItems.add(reg125ItemModel);
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
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF125,
    itemUniqueId: menuOthNF125,
    itemGroup: groupOth,
    itemName: "NF125",
    itemPrice: 108,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF165,
    itemUniqueId: menuOthNF165,
    itemGroup: groupOth,
    itemName: "NF165",
    itemPrice: 157,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF155,
    itemUniqueId: menuOthNF155,
    itemGroup: groupOth,
    itemName: "NF155",
    itemPrice: 143,
    stocksAlert: 5,
    stocksType: "pcs",
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthNF195,
    itemUniqueId: menuOthNF195,
    itemGroup: groupOth,
    itemName: "NF195",
    itemPrice: 192,
    stocksAlert: 5,
    stocksType: "pcs",
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
  ));
  listOthItems.add(OtherItemModel(
    docId: "",
    itemId: menuOthW10t11,
    itemUniqueId: menuOthW10t11,
    itemGroup: groupOth,
    itemName: "Plastic",
    itemPrice: 2,
    stocksAlert: 10,
    stocksType: "pcs",
  ));
  listOthItems.add(promoFree);

  //oth names
  mapOthNames.addEntries({menuOthWash: "Wash"}.entries);
  mapOthNames.addEntries({menuOthDry: "Dry"}.entries);
  mapOthNames.addEntries({menuOthXD: "Extra Dry"}.entries);
  mapOthNames.addEntries({menuOthXW: "Extra Wash"}.entries);
  mapOthNames.addEntries({menuOthXR: "Extra Rinse"}.entries);
}
