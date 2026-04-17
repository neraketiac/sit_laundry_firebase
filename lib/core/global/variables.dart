import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/features/employees/models/employeesetupmodel.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/loyalty_admin.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

List<OtherItemModel> listAllItemsFB = [];
Map<(int, int), String> stocksTypeLookup = {};
bool usePromoFree = false;
bool isProcessing = false;
const String storageKey = 'customer_code';
const int intSortByDateC = 1, intSortByDateD = 3;
Timestamp adminTimestampDateD = Timestamp.now();
bool useAdminTimestampDateD = false;
int selectedIndexCompleted = intSortByDateC;
//done
List<JobModel> originalJobsDone = [];
List<JobModel> sortedJobsDone = [];
List<JobModel> sortedJobsDoneClothesHere = [];
List<JobModel> sortedJobsDoneClothesGoneCash = [];
List<JobModel> sortedJobsDoneClothesGoneGCash = [];
int selectedIndexDone = intSortByDateD;

int intJobsDoneDefault = 0,
    intJobsDoneClothesHere = 0,
    intJobsDoneClothesGoneCash = 0,
    intJobsDoneClothesGoneGCash = 0;

bool isLoading = true;
String? cachedToken;
final FirebaseMessaging messaging = FirebaseMessaging.instance;

final finalEmpSetup = EmployeeSetupModel(
    docId: '',
    empId: empNameToId[empIdGlobal]!,
    empName: empIdGlobal,
    logDate: Timestamp.now(),
    logBy: empIdGlobal,
    remarks: '',
    showLaundry: false,
    showFunds: false,
    showFundsHistory: false,
    showEmployee: false,
    showIncome: false,
    showUnpaidLaundry: false);
bool loading = true;
bool loggedIn = false;
bool rememberMe = true;
TextEditingController memberController = TextEditingController();
final value = NumberFormat("##,##0", "en_US");
bool isAdmin = false;
int alwaysTheLatestFunds = 0;

final GCashModel finalGCashModel = GCashModel(
    docId: "",
    countId: 0,
    logDate: Timestamp.now(),
    logBy: empIdGlobal,
    completeDate: Timestamp.now(),
    itemId: menuOthUniqIdCashIn,
    itemUniqueId: menuOthUniqIdCashIn,
    itemName: 'Cash-In',
    customerAmount: 0,
    gCashStatus: 0.25,
    customerId: 1,
    customerName: '',
    customerNumber: '',
    remarks: "",
    cashInImageUrl: "",
    cashOutImageUrl: "");
String empIdGlobal = "";

// Create a DateTime for Jan 1, 1900
final oldDate = DateTime(1900, 1, 1);

// Convert to Firestore Timestamp
final timestamp1900 = Timestamp.fromDate(oldDate);

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

CustomerModel autocompleteSelected = CustomerModel(
    customerId: 0,
    name: '',
    address: '',
    contact: '',
    remarks: '',
    loyaltyCount: 0);
const String groupDet = "Det",
    groupFab = "Fab",
    groupBle = "Ble",
    groupOth = "Oth";

const mobileWidth = 600;

TextEditingController remarksSuppliesVar = TextEditingController();

void putEntries() {
  listBleItems.clear();
  addListBleItems();

  listOthItems.clear();
  addListOthItems();

  listSuppItems.clear();
  listSuppItemsAll.clear();

  addListSuppItems();

  listSuppItems.addAll(listDetItemsFB);
  listSuppItemsAll.addAll(listDetItemsFB);
  listSuppItems.addAll(listFabItemsFB);
  listSuppItemsAll.addAll(listFabItemsFB);
  listSuppItems.addAll(listBleItems);
  listSuppItemsAll.addAll(listBleItems);
  listSuppItems.addAll(listOthItems);
  listSuppItemsAll.addAll(listOthItems);
  listSuppItems.addAll(listOthItemsFB);
  listSuppItemsAll.addAll(listOthItemsFB);

  remarksSuppliesVar.text = "";
}

const Map<String, String> nameMap = {
  'jeng': 'Jeng',
  'lorie': 'Lorie',
  'abby': 'Abby',
  'ket': 'Ket',
  'analyn': 'Analyn',
  'seiji': 'Seiji',
  'donf': 'DonF',
};

const Map<String, String> mapEmpId = {
  '#1515': 'Jeng',
  '#1212': 'Abby',
  '#1919': 'Lorie',
  '#2020': 'Seiji',
  '#3131': 'Analyn',
  '1313#': 'Ket',
  '1616#': 'DonF',
};

const Map<String, int> mapEmpIdRates = {
  '#1515': 400,
  '#1212': 450,
  '#1919': 500,
  '#2020': 400,
  '#3131': 400,
};

final Map<String, String> empNameToId = {
  for (var e in mapEmpId.entries) e.value: e.key
};

//Colors
final Color cButtons = Color.fromRGBO(134, 218, 252, 0.733);
//JobsOnQueue Colors
final Color cRiderPickup = Color.fromRGBO(62, 255, 45, 1); //rider
//JobsOnGoing Colors
final Color cWaiting = Color.fromRGBO(170, 170, 170, 1);
final Color cWashing =
    Color.fromRGBO(1, 255, 244, 1); //same washing, drying, folding

final Color cAdmin = Colors.blueGrey;
final Color cShowGCash = Colors.lightBlueAccent;
final Color cFundsInFundsOut = const Color.fromARGB(255, 133, 107, 14);
final Color cJobsOnQueue = Colors.blue;
final Color cEmployeeMaintenance = Colors.deepOrangeAccent;

Color borderColor() {
  return Colors.black54;
}

Color? colAmber() {
  return Colors.amber[50];
}

BoxDecoration decoAmber() {
  return BoxDecoration(
      color: colAmber(), border: Border.all(color: borderColor(), width: 2.0));
}

Color? colLightBlue() {
  return Colors.lightBlue[100];
}

BoxDecoration decoLightBlue() {
  return BoxDecoration(
      color: colLightBlue(),
      border: Border.all(color: borderColor(), width: 2.0));
}

String getItemNameOnly(int itemId, int itemUniqueId) {
  String thisItemName = "no data";
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName = thisData.itemName;
      exit;
    }
  }
  return thisItemName;
}

String getItemNameStocksType(int itemId, int itemUniqueId) {
  return stocksTypeLookup[(itemId, itemUniqueId)] ?? "no stockstype";
}

int getItemNameStocksAlert(int itemId, int itemUniqueId) {
  int thisReturn = 0;
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisReturn = thisData.stocksAlert;
    }
  }

  return thisReturn;
}

int getItemPrice(int itemId, int itemUniqueId) {
  int thisReturn = 0;
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisReturn = thisData.itemPrice;
    }
  }

  return thisReturn;
}

void allCardsVar(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const LoyaltyAdmin()));
}

bool ifMenuUniqueIsCashIn(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdCashIn) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsCashInEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdCashIn ||
      eM.itemUniqueId == menuOthSalaryPayment) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsCashOut(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdCashOut) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsEOD(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdFundsEOD) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsFundsOut(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdFundsOut) {
    return true;
  }
  return false;
}
