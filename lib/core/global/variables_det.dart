import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listDetItemsFB = [];
Map<int, String> mapDetNames = {};
Map<int, int> mapDetPrice = {};

final detWKL15 = OtherItemModel(
  docId: "",
  itemId: menuDetWKL,
  itemUniqueId: menuDetWKL15,
  itemGroup: groupDet,
  itemName: "WKL15",
  itemPrice: 15,
  stocksAlert: 5,
  stocksType: "btl",
  logDate: timestamp1900,
);

final detAriel15 = OtherItemModel(
  docId: "",
  itemId: menuDetArielDVal,
  itemUniqueId: menuDetArielDVal,
  itemGroup: groupDet,
  itemName: "Ariel",
  itemPrice: 15,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

void addlistDetItemsFB() {
  //detItems
  listDetItemsFB.add(detAriel15);
  listDetItemsFB.add(OtherItemModel(
    docId: "",
    itemId: menuDetWKL,
    itemUniqueId: menuDetWKL,
    itemGroup: groupDet,
    itemName: "WKL",
    itemPrice: 8,
    stocksAlert: 5,
    stocksType: "btl",
    logDate: timestamp1900,
  ));
  listDetItemsFB.add(detWKL15);
}
