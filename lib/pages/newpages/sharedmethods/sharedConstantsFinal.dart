//
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  forSorting,
  riderPickup,
];

TextEditingController customerAmountVar = TextEditingController();

const String titlePaymentStatus = 'Payment Status';
String actualPaymentStatus = 'Unpaid';

const double fontSizeTotalPrice = 24;
const double fontSizeKiloLoad = 18;
