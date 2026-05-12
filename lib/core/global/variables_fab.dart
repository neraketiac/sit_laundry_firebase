import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

List<OtherItemModel> listFabItemsFB = [];
const int menuFabDowny36mlDVal = 204;
const int menuFabWKLDValAny8ml = 2103;

final addFabAnyItemModel = OtherItemModel(
  docId: "",
  itemId: menuFabWKLDValAny8ml,
  itemUniqueId: menuFabWKLDValAny8ml,
  itemGroup: groupFab,
  itemName: "Fab-WKL(any SOF 8ml)",
  itemPrice: 8,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

final addFabDowny36mlModel = OtherItemModel(
  docId: "",
  itemId: menuFabDowny36mlDVal,
  itemUniqueId: menuFabDowny36mlDVal,
  itemGroup: groupFab,
  itemName: "Downy 36ml",
  itemPrice: 10,
  stocksAlert: 5,
  stocksType: "pcs",
  logDate: timestamp1900,
);

void addlistFabItemsFB() {
  //detItems
  listFabItemsFB.add(addFabAnyItemModel);
  listFabItemsFB.add(addFabDowny36mlModel);
}
