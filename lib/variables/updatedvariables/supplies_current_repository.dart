import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/variables/variables.dart';

class SuppliesCurrentRepository {
  SuppliesCurrentRepository._();
  static final SuppliesCurrentRepository instance =
      SuppliesCurrentRepository._();

  /// Single job (nullable until set)
  SuppliesModelHist? suppliesModelCurrent;

  bool _loaded = false;

  Future<void> reset() async {
    clear();
    // if (_loaded) return;

    // // intentionally blank
    // // job will be assigned later

    // _loaded = true;
  }

  void setSuppliesCurrent(SuppliesModelHist supplies) {
    suppliesModelCurrent = supplies;
  }

  void clear() {
    //suppliesModelCurrent = null;
    suppliesModelCurrent = SuppliesModelHist(
      docId: "",
      countId: 0,
      itemId: 123,
      itemUniqueId: 123,
      itemName: '',
      currentCounter: 0,
      currentStocks: 0,
      logDate: Timestamp.now(),
      empId: empIdGlobal,
      customerId: 1,
      customerName: '',
      remarks: "");
  }

  void setItemId(int i) {}

}
