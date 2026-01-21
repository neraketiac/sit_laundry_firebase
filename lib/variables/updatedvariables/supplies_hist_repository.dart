import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/variables/variables.dart';

class SuppliesHistRepository {
  SuppliesHistRepository._();
  static final SuppliesHistRepository instance =
      SuppliesHistRepository._();

  /// Single job (nullable until set)
  SuppliesModelHist? suppliesModelHist;

  bool _loaded = false;

  Future<void> reset() async {
    clear();
    // if (_loaded) return;

    // // intentionally blank
    // // job will be assigned later

    // _loaded = true;
  }

  void setSuppliesCurrent(SuppliesModelHist supplies) {
    suppliesModelHist = supplies;
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


  void setItemId(int itemId) {
    suppliesModelHist!.itemId = itemId;
  }

  void setItemUniqueId(int itemUniqueId) {
    suppliesModelHist!.itemUniqueId = itemUniqueId;
  }

  void setItemName(String itemName) {
    suppliesModelHist!.itemName = itemName;
  }

  void setCurrentCounter(int currentCounter) {
    suppliesModelHist!.currentCounter = currentCounter;
  } 

  void setCustomerId(int customerId) {
    suppliesModelHist!.customerId = customerId;
  }

  void setCustomerName(String customerName) {
    suppliesModelHist!.customerName = customerName;
  }

  void setLogDate(Timestamp logDate) {
    suppliesModelHist!.logDate = logDate;
  }

  void setRemarks(String remarks) {
    suppliesModelHist!.remarks = remarks;
  }

}
