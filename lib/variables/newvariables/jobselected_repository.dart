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
  //int selectedPaidUnpaid = unpaid;
  bool selectedPaidGCashVerified = false;
  bool selectedFold = true;
  bool selectedMix = true;
  int basketCount = 0;
  int ecoBagCount = 0;
  int sakoCount = 0;
  int addFabCount = 0;
  int addExtraDryCount = 0;
  int addExtraWashCount = 0;
  int addExtraSpinCount = 0;
  String selectedOnGoingStatus = '';
}
