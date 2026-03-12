//
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';

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
  intRegularPackage: 3,
  intSayoSabonPackage: 2,
  intOthersPackage: 2,
};

const prices = {
  intRegularPackage: 155,
  intSayoSabonPackage: 125,
  intOthersPackage: 0,
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
  intRegularPackage,
  intSayoSabonPackage,
  intOthersPackage,
];

const Map<int, String> itemNameAliases = {
  menuOthXD: 'xD',
  menuOthXW: 'xW',
  menuOthXS: 'xS',
};

final List<String> listOnGoingStatus = [
  'waiting',
  'washing',
  'drying',
  'folding',
];

final List<int> listRiderPickup = [
  intForSorting,
  intRiderPickup,
];

TextEditingController customerAmountVar = TextEditingController();

const String titlePaymentStatus = 'Payment Status';
String actualPaymentStatus = 'Unpaid';

const double fontSizeTotalPrice = 24;
const double fontSizeKiloLoad = 18;
