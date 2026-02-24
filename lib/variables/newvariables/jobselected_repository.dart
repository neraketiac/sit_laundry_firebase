import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

class JobselectedRepository {
  TextEditingController customerAmountVar = TextEditingController();
  TextEditingController customerNameVar = TextEditingController();
  TextEditingController cashAmountVar = TextEditingController();
  TextEditingController gCashAmountVar = TextEditingController();
  TextEditingController remarksVar = TextEditingController();

  int selectedRiderPickup = forSorting;
  int selectedPackage = regularPackage;
  int selectedPackagePrev = regularPackage;
  int selectedOthers = menuOthDVal;
  bool isPerKg = true;
  double quantityKg = 8;
  int quantityLoad = 1;
  int totalPriceRegSS = 155;
  int totalPriceShortCutRegSS = 0;
  int totalPriceOthers = 0;
  int pricePerSet = 0;
  int maxPartial = 0;
  OtherItemModel selectedItemModel = reg125ItemModel;
  List<OtherItemModel> listSelectedItemModel = [];
  int selectedOthersShortCut = menuOth155;
  int addFabCount = 0;
  int addExtraDryCount = 0;
  int addExtraWashCount = 0;
  int addExtraSpinCount = 0;

  void reset() {
    customerAmountVar.text = '';
    customerNameVar.text = '';
    cashAmountVar.text = '';
    gCashAmountVar.text = '';
    remarksVar.text = '';

    selectedRiderPickup = forSorting;
    selectedPackage = regularPackage;
    selectedPackagePrev = regularPackage;
    selectedOthers = menuOthDVal;
    isPerKg = true;
    quantityKg = 8;
    quantityLoad = 1;
    totalPriceRegSS = 155;
    totalPriceShortCutRegSS = 0;
    totalPriceOthers = 0;
    pricePerSet = 0;
    maxPartial = 0;
    selectedItemModel = reg125ItemModel;
    listSelectedItemModel = [];
    selectedOthersShortCut = menuOth155;
    addFabCount = 0;
    addExtraDryCount = 0;
    addExtraWashCount = 0;
    addExtraSpinCount = 0;
  }
}
