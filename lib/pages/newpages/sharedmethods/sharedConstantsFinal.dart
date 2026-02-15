//
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

const double fieldIndentWidth = 40;
bool isGcashCredit = false;
final NumberFormat pesoFormat = NumberFormat('#,##0', 'en_PH');

//end of day
final List<int> denominations = [1000, 500, 200, 100, 50, 20, 10, 5, 1];

final Map<int, int> qtyMap = {
  for (final d in [1000, 500, 200, 100, 50, 20, 10, 5, 1]) d: 0,
};
int? selectedFundCode;
bool successInsertFB = false;
final int tier1Increase = 35;
final int tier2Increase = 105;

const maxPartialOptions = {
  regularPackage: 3,
  sayoSabonPackage: 2,
  othersPackage: 2,
};

const prices = {
  regularPackage: 155,
  sayoSabonPackage: 125,
  othersPackage: 0,
};

final List<int> listOthersDropDown = [
  menuOthDVal,
  menuDetDVal,
  menuFabDVal,
  menuBleDVal,
];
final List<int> listOthersDropDownShortCuts = [
  menuOth155,
  menuOth125,
  menuOthXD,
  menuFabWKLDValAny8ml,
];
final List<int> listPackage = [
  regularPackage,
  sayoSabonPackage,
  othersPackage,
];

final List<int> listRiderPickup = [
  forSorting,
  riderPickup,
];

TextEditingController customerAmountVar = TextEditingController();

const String titlePaymentStatus = 'Payment Status';
String actualPaymentStatus = 'Unpaid';

//for repo

// TextEditingController customerNameVar = TextEditingController();
// TextEditingController partialCashAmountVar = TextEditingController();
// TextEditingController partialGCashAmountVar = TextEditingController();
// TextEditingController remarksVar = TextEditingController();

// int selectedRiderPickup = forSorting;
// int selectedPackage = regularPackage;
// int selectedPackagePrev = regularPackage;
// int selectedOthers = menuOthDVal;
// bool isPerKg = true;
// double quantityKg = 8;
// int quantityLoad = 1;
// int totalPriceRegSS = 155;
// int totalPriceShortCutRegSS = 0;
// int totalPriceOthers = 0;
// int pricePerSet = 0;
// int maxPartial = 0;
// OtherItemModel selectedItemModel = reg125ItemModel;
// int selectedOthersShortCut = menuOth155;
// int selectedPaidUnpaid = unpaid;
// bool selectedPaidPartialCash = false;
// bool selectedPaidPartialGCash = false;
// bool selectedPaidGCashVerified = false;
// bool selectedFold = true;
// bool selectedMix = true;
// int basketCount = 0;
// int ecoBagCount = 0;
// int sakoCount = 0;
// int addFabCount = 0;
// int addExtraDryCount = 0;
// int addExtraWashCount = 0;
// int addExtraSpinCount = 0;
