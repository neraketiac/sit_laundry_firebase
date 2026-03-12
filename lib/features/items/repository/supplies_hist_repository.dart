import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class SuppliesHistRepository {
  SuppliesHistRepository._();
  static final SuppliesHistRepository instance = SuppliesHistRepository._();

  /// Single job (nullable until set)
  SuppliesModelHist? suppliesModelHist;

  Future<void> reset() async {
    clear();
    // if (_loaded) return;

    // // intentionally blank
    // // job will be assigned later

    // _loaded = true;
  }

  void setSuppliesCurrent(SuppliesModelHist value) {
    suppliesModelHist = value;
  }

  void clear() {
    // suppliesModelHist = null;
    suppliesModelHist = SuppliesModelHist(
        docId: "",
        countId: 0,
        itemId: 123,
        itemUniqueId: 123,
        itemName: "123",
        currentCounter: 0,
        currentStocks: 0,
        logDate: Timestamp.now(),
        empId: empIdGlobal,
        customerId: 1,
        customerName: "",
        remarks: "");
  }

  void setItemId(int value) {
    suppliesModelHist!.itemId = value;
  }

  void setItemUniqueId(int value) {
    suppliesModelHist!.itemUniqueId = value;
  }

  void setItemName(String value) {
    suppliesModelHist!.itemName = value;
  }

  void setCurrentCounter(int value) {
    suppliesModelHist!.currentCounter = value;
  }

  void setEmpId(String value) {
    suppliesModelHist!.empId = value;
  }

  void setCustomerId(int value) {
    suppliesModelHist!.customerId = value;
  }

  void setCustomerName(String value) {
    suppliesModelHist!.customerName = value;
  }

  void setLogDate(Timestamp value) {
    suppliesModelHist!.logDate = value;
  }

  void setRemarks(String value) {
    suppliesModelHist!.remarks = value;
  }
}
