import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/features/employees/models/employeesetupmodel.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/loyalty_admin.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

//DocumentSnapshot? lastCompletedDoc;
bool loadingCompleted = false;
//bool hasMoreCompleted = true;
ScrollController completedScrollController = ScrollController();

bool usePromoFree = false;
bool isProcessing = false;
bool bFirebaseInitialized = false;
const String storageKey = 'customer_code';
const int intSortByDateC = 1,
    intSortByCustomerName = 2,
    intSortByDateD = 3,
    intFindCustomerNameId = 9;
const int intSortUnpaidClothesGone = 4;

Timestamp adminTimestampDateD = Timestamp.now();
bool useAdminTimestampDateD = false;
//sorting
//completed
List<JobModel> originalJobsCompleted = [];
//List<JobModel> sortedJobsCompleted = [];
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

int intSelectedSortCompleted = 1;
int intSelectedSortDone = 3;

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
    showIncome: false);
bool loading = true;
bool loggedIn = false;
bool rememberMe = true;
TextEditingController memberController = TextEditingController();

bool showDet = false, showFab = false, showBle = false, showOth = false;
bool bDelAddOnsVar = true;
bool bCustomerName = false;
//bool bAutoLaundry = false;
//bool bInsertDataSuppliesHist = false;
//bool bTest = false;
bool bGcashFee = false;
bool bNagbigayFee = true;
final value = NumberFormat("##,##0", "en_US");
bool isAdmin = false;
const bool allowPayment = true;
late int alwaysTheLatestFunds;

final GCashModel finalGCashModel = GCashModel(
    docId: "",
    countId: 0,
    logDate: Timestamp.now(),
    logBy: empIdGlobal,
    completeDate: Timestamp.now(),
    itemId: selectedSupVar.itemId,
    itemUniqueId: selectedSupVar.itemUniqueId,
    itemName: selectedSupVar.itemName,
    customerAmount: 0,
    gCashStatus: 0.25,
    customerId: 1,
    customerName: '',
    customerNumber: '',
    remarks: "",
    cashInImageUrl: "",
    cashOutImageUrl: "");
late SuppliesModelHist suppliesModelHistGlobal;
late SuppliesModelHist sMHGLaundryPayment;
late SuppliesModelHist sMHGLaundryPaymentDonP;
late SuppliesModelHist sMHGLaundryPaymentGCash;
String empIdGlobal = "";
String selectedNumberVar = "1";
int iAmountDisplay = 0, iAmountFinal = 0;
String allClear = "c";

// Create a DateTime for Jan 1, 1900
final oldDate = DateTime(1900, 1, 1);

// Convert to Firestore Timestamp
final timestamp1900 = Timestamp.fromDate(oldDate);

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

List<OtherItemModel> listAddOnItemsGlobal = [];
late OtherItemModel gselectedItemModel;
List<OtherItemModel> listAddedOtherItemModel = [];
List<CustomerModel> customerOptionsFromVariable = [];
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
//new end

int autoNumber = 0;
//queuestats
Map<int, String> mapQueueStat = {};
const int intForSorting = 501,
    intRiderPickup = 502,
    intRegularPackage = 503,
    intSayoSabonPackage = 504,
    intOthersPackage = 505,
    intWaitingStat = 601,
    intWashingStat = 602,
    intDryingStat = 603,
    intFoldingStat = 604,
    intWaitCustomerPickup = 701,
    intWaitRiderDelivery = 702,
    intNasaCustomerNa = 703;

const int processWaiting = 650,
    processWashing = 651,
    processDrying = 652,
    processFolding = 653,
    processDone = 654;

//paymentStats
//Map<int, String> mapPaymentStat = {};
const int unpaid = 801,
    paidCash = 802,
    paidGCash = 803,
    partialPaidCash = 804,
    partialPaidGCash = 805;

// class OthItems {
//   int menuDVal;
//   String menuName;
//   OthItems({
//     required this.menuDVal,
//     required this.menuName,
//   });
//   static OthItems fromJson(json) => OthItems(
//         menuDVal: json['menuDVal'],
//         menuName: json['menuName'],
//       );
// }

// List<OthItems> othItems = [];

List<String> finListNumbering = [];
List<String> lasListNumbering = [];
final List<String> completeListNumbering = [
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10",
  "11",
  "12",
  "13",
  "14",
  "15",
  "16",
  "17",
  "18",
  "19",
  "20",
  "21",
  "22",
  "23",
  "24",
  "25"
];

const mobileWidth = 600;

bool bViewMoreOptions = false;
bool bViewAddOnDtlOnGoing = false;

//variable in alterDetailJobsJson for all jobs
bool bRiderPickupVar = false;
bool bRegularSabonVar = true,
    bSayoSabonVar = false,
    bOtherServicesVar = false,
    bShowKiloLoadDisplayVar = true,
    bShowKiloDisplayOthVar = false;
bool bAddOnVar = false,
    bDetAddOnVar = false,
    bFabAddOnVar = false,
    bBleAddOnVar = false,
    bOthAddOnVar = false;
// int iInitialKiloVar = 8,
//     iInitialLoadVar = 1,
//     iInitialPriceVar = 155,
//     iInitialOthersPriceVar = 155;
late OtherItemModel selectedDetVar,
    selectedFabVar,
    selectedBleVar,
    selectedOthVar,
    selectedSupVar;

bool allowDecimal = false;
// int iBasketVar = 0, iBagVar = 0;
bool bUnpaidVar = true, bPaidCashVar = false, bPaidGCashVar = false;
// bool bMixVar = true, bFoldVar = true;
TextEditingController remarksControllerVar = TextEditingController();
TextEditingController remarksSuppliesVar = TextEditingController();
TextEditingController counterControllerVar = TextEditingController();

DateTime dNeedOnVar = DateTime.now().add(Duration(minutes: 210));

// Timestamp tNeedOnVar = Timestamp.now();

void putEntries() {
  resetAddOnsGlobalVar();
  fetchUsers();
  refillJobsList();
  listDetItems.clear();
  listFabItems.clear();
  listBleItems.clear();
  listOthItems.clear();
  listSuppItems.clear();
  listSuppItemsAll.clear();

  addListDetItems();
  addListFabItems();
  addListBleItems();
  addListOthItems();

  //queueStat
  mapQueueStat.addEntries({intForSorting: "ForSorting"}.entries);
  mapQueueStat.addEntries({intRiderPickup: "RiderPickup"}.entries);
  mapQueueStat.addEntries({intWaitingStat: "Waiting"}.entries);
  mapQueueStat.addEntries({intWashingStat: "Washing"}.entries);
  mapQueueStat.addEntries({intDryingStat: "Drying"}.entries);
  mapQueueStat.addEntries({intFoldingStat: "Folding"}.entries);
  mapQueueStat
      .addEntries({intWaitCustomerPickup: "WaitCustomerPickup"}.entries);
  mapQueueStat.addEntries({intWaitRiderDelivery: "WaitRiderDelivery"}.entries);
  mapQueueStat.addEntries({intNasaCustomerNa: "NasaCustomerNa"}.entries);

  // //paymentStat
  // mapPaymentStat.addEntries({unpaid: "Unpaid"}.entries);
  // mapPaymentStat.addEntries({paidCash: "PaidCash"}.entries);
  // mapPaymentStat.addEntries({paidGCash: "PaidGCash"}.entries);
  // mapPaymentStat.addEntries({waitGCash: "WaitGCash"}.entries);

  //dropdown first value
  selectedDetVar = listDetItems[0];
  selectedFabVar = listFabItems[0];
  selectedBleVar = listBleItems[0];
  selectedOthVar = listOthItems[0];
  //listAddedOtherItemModel.add(selectedOthVar);

  addListSuppItems();

  selectedSupVar = listSuppItems[0];
  gselectedItemModel = listSuppItems[0];

  listSuppItems.addAll(listDetItems);
  listSuppItemsAll.addAll(listDetItems);
  listSuppItems.addAll(listFabItems);
  listSuppItemsAll.addAll(listFabItems);
  listSuppItems.addAll(listBleItems);
  listSuppItemsAll.addAll(listBleItems);

  resetSHGlobalVar();
}

void putEntriesWhileEmpIsNull() {
  // resetJOQMGlobalVar();
  // resetAddOnsGlobalVar();
  // fetchUsers();
  refillJobsList();
  listDetItems.clear();
  listFabItems.clear();
  listBleItems.clear();
  listOthItems.clear();
  listSuppItems.clear();
  listSuppItemsAll.clear();

  addListDetItems();
  addListFabItems();
  addListBleItems();
  addListOthItems();

  //queueStat
  mapQueueStat.addEntries({intForSorting: "ForSorting"}.entries);
  mapQueueStat.addEntries({intRiderPickup: "RiderPickup"}.entries);
  mapQueueStat.addEntries({intWaitingStat: "Waiting"}.entries);
  mapQueueStat.addEntries({intWashingStat: "Washing"}.entries);
  mapQueueStat.addEntries({intDryingStat: "Drying"}.entries);
  mapQueueStat.addEntries({intFoldingStat: "Folding"}.entries);
  mapQueueStat
      .addEntries({intWaitCustomerPickup: "WaitCustomerPickup"}.entries);
  mapQueueStat.addEntries({intWaitRiderDelivery: "WaitRiderDelivery"}.entries);
  mapQueueStat.addEntries({intNasaCustomerNa: "NasaCustomerNa"}.entries);

  // //paymentStat
  // mapPaymentStat.addEntries({unpaid: "Unpaid"}.entries);
  // mapPaymentStat.addEntries({paidCash: "PaidCash"}.entries);
  // mapPaymentStat.addEntries({paidGCash: "PaidGCash"}.entries);
  // mapPaymentStat.addEntries({waitGCash: "WaitGCash"}.entries);

  //dropdown first value
  selectedDetVar = listDetItems[0];
  selectedFabVar = listFabItems[0];
  selectedBleVar = listBleItems[0];
  selectedOthVar = listOthItems[0];

  addListSuppItems();

  selectedSupVar = listSuppItems[0];
  gselectedItemModel = listSuppItems[0];

  listSuppItems.addAll(listDetItems);
  listSuppItemsAll.addAll(listDetItems);
  listSuppItems.addAll(listFabItems);
  listSuppItemsAll.addAll(listFabItems);
  listSuppItems.addAll(listBleItems);
  listSuppItemsAll.addAll(listBleItems);

  // resetSHGlobalVar(); change by repository
}

String getRegexStringVar() =>
    allowDecimal ? r'[0-9] + [,.]{0,1}[0-9]*' : r'[0-9]';

//var mapEmpId = {"0550", "Jeng", "0808", "Abi", "0413", "Ket", "0316", "DonP"};

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

// Map<String, int> mapEmpAccess = {
//   'Jeng': 20001, //jeng salary
//   'Rowel': 20002,
//   'Abi': 20003,
//   'Let': 20004,
//   'Seiji': 20005,
//   'Ken': 20006,
//   'DonF': 10001, //gcash account
//   'Ket': 10001,
//   'DonF': 10002,
//   'Ket': 10002,
// };
//1 enabled
//0 or others disabled cannot view queue_mobile_dart
// Map<String, int> mapEmpAccessv2 = {
//   // 'Jeng20001': 1, //jeng salary
//   // 'Rowel20002': 1,
//   // 'Abi20003': 1,
//   // 'Let20004': 1,
//   // 'Seiji20005': 1,
//   // 'Ken20006': 1,
//   'DonP$menuOth977GCash': 1, //gcash account
//   'DonP$menuOth977GCashIn': 1,
//   'DonP$menuOth977GCashOut': 1,
//   'Ket$menuOth152GCash': 1,
//   'Ket$menuOth152GCashIn': 1,
//   'Ket$menuOth152GCashOut': 1,
//   'DonP$menuOthLPDonPCash': 1,
// };

/*
  '05#05': 'Jeng',
  '90#90': 'Rowel',
  '08#08': 'Abi',
  '28#28': 'Let',
  '20#20': 'Seiji',
  '80#80': 'Ken',
*/

Map<String, int> mapDisplayInSummary = {
  'DonP$menuOth977GCashIn': 1,
  'DonP$menuOth977GCashOut': 1,
  'DonP$menuOthLPDonPCash': 1,
  'DonP$menuOthLaundryPaymentGCash': 1,
  'Ket$menuOth152GCashIn': 1,
  'Ket$menuOth152GCashOut': 1,
  'Ket$menuOthLaundryPaymentGCash': 1,
};

//history and list should be the same for now
Map<String, int> mapDisplayInHistory = {
  'DonP$menuOth977GCashIn': 1,
  'DonP$menuOth977GCashOut': 1,
  'DonP$menuOthLPDonPCash': 1,
  'DonP$menuOthLaundryPaymentGCash': 1,
  'Ket$menuOth152GCashIn': 1,
  'Ket$menuOth152GCashOut': 1,
  'Ket$menuOthLaundryPaymentGCash': 1,
  'Jeng$menuOthLaundryPaymentGCash': 1,
  'Rowel$menuOthLaundryPaymentGCash': 1,
  'Abi$menuOthLaundryPaymentGCash': 1,
  'Seiji$menuOthLaundryPaymentGCash': 1,
  'Ken$menuOthLaundryPaymentGCash': 1,
};

Map<String, int> mapDisplayInList = {
  'DonP$menuOth977GCashIn': 1,
  'DonP$menuOth977GCashOut': 1,
  'DonP$menuOthLPDonPCash': 1,
  'DonP$menuOthLaundryPaymentGCash': 1,
  'Ket$menuOth152GCashIn': 1,
  'Ket$menuOth152GCashOut': 1,
  'Ket$menuOthLaundryPaymentGCash': 1,
  'Jeng$menuOthLaundryPaymentGCash': 1,
  'Rowel$menuOthLaundryPaymentGCash': 1,
  'Abi$menuOthLaundryPaymentGCash': 1,
  'Seiji$menuOthLaundryPaymentGCash': 1,
  'Ken$menuOthLaundryPaymentGCash': 1,
};

String autoPriceDisplay(int price, bool bRegularSabon) {
  int x = 0, y = 0, z = 0;
  int divider;
  if (bRegularSabon) {
    divider = 155;
  } else {
    divider = 125;
  }
  if (price % divider == 0) {
    return "Php $price";
  } else {
    if (price ~/ divider == 1) {
      return "Php $price";
    } else {
      x = price ~/ divider;
      x--;
      x = x * divider;
      y = price % divider;
      y = y + divider;
      z = x + y;
      return "$x + $y=Php $z";
    }
  }
}

String kiloDisplay(int kilo) {
  return "max $kilo.0";
  // if (kilo % 8 == 0) {
  //   return "$kilo.0";
  // } else {
  //   return "${(kilo - 1)}.1 - $kilo.0";
  // }
}

//fontsize
final double fontQueue = 10;

//Colors
final Color cButtons = Color.fromRGBO(134, 218, 252, 0.733);
//JobsOnQueue Colors
final Color cRiderPickup = Color.fromRGBO(62, 255, 45, 1); //rider
final Color cForSorting = Color.fromRGBO(170, 170, 170, 1);
//JobsOnGoing Colors
final Color cWaiting = Color.fromRGBO(170, 170, 170, 1);
final Color cWashing =
    Color.fromRGBO(1, 255, 244, 1); //same washing, drying, folding
final Color cDrying =
    Color.fromRGBO(91, 255, 244, 1); //same washing, drying, folding
final Color cFolding =
    Color.fromRGBO(171, 255, 244, 1); //same washing, drying, folding
//JobsDone Colors
final Color cWaitCustomerPickup = Color.fromRGBO(170, 170, 170, 1);
final Color cWaitRiderDelivery = Color.fromRGBO(62, 255, 45, 1); //rider
final Color cNasaCustomerNa = Color.fromRGBO(92, 91, 91, 1);
final Color cRiderOnDelivery = Color.fromRGBO(62, 255, 45, 1); //rider

final Color cAdmin = Colors.blueGrey;
final Color cShowGCash = Colors.lightBlueAccent;
final Color cFundsInFundsOut = Colors.amberAccent;
final Color cFundsCheck = Colors.lightGreenAccent;
final Color cJobsOnQueue = Colors.blue;
final Color cEmployeeMaintenance = Colors.deepOrangeAccent;

Color paymentStatColor(String paymentStat) {
  if (paymentStat == "Paid" ||
      paymentStat == "PaidGCash" ||
      paymentStat == "PaidCash") {
    return Colors.transparent;
  } else {
    return Color.fromARGB(115, 255, 97, 97);
  }
}

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

BoxDecoration decoFundsInFundsOut() {
  return BoxDecoration(
      color: cFundsInFundsOut,
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? colGreenAccent() {
  return Colors.greenAccent;
}

BoxDecoration decoGreenAccent() {
  return BoxDecoration(
      color: colGreenAccent(),
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? colGreenAccent2() {
  return Colors.greenAccent[100];
}

BoxDecoration decoGreenAccent2() {
  return BoxDecoration(
      color: colGreenAccent2(),
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? colPurpleAccen() {
  return Colors.purpleAccent[100];
}

BoxDecoration decoOtherItems() {
  return BoxDecoration(
      color: colPurpleAccen(),
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? colPinkAccent() {
  return Colors.pinkAccent[100];
}

BoxDecoration decoPinkAccent() {
  return BoxDecoration(
      color: colPinkAccent(),
      border: Border.all(color: borderColor(), width: 2.0));
}

BoxDecoration decoGreenAccentNoBorder() {
  return BoxDecoration(
    color: colGreenAccent(),
  );
}

Color? colDarkBlue() {
  return Colors.blue[300];
}

BoxDecoration decoDarkBlue() {
  return BoxDecoration(
      color: colDarkBlue(),
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? containerTotalPriceColor() {
  return Colors.red[50];
}

BoxDecoration containerTotalPriceBoxDecoration() {
  return BoxDecoration(
      color: containerTotalPriceColor(),
      border: Border.all(color: borderColor(), width: 2.0));
}

int iPriceDivider(bool bRegularSabon) {
  if (bRegularSabon) {
    return 155;
  } else {
    return 125;
  }
}

Future<void> fetchUsers() {
  customerOptionsFromVariable = [];
  CollectionReference users = FirebaseFirestore.instance.collection('loyalty');
  return users.get().then((QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      //print(doc.id + " " + doc['Name'] + " " + doc['Address']);
      customerOptionsFromVariable.add(CustomerModel(
          customerId: int.parse(doc.id),
          name: doc['Name'],
          address: doc['Address'],
          contact: doc['Name'],
          remarks: doc['Name'],
          loyaltyCount: doc['Count']));
    }
  }).catchError((error) => print("Failed to fetch users: $error"));
}

String customerName(String customerId) {
  String thisCustomerName = "err pls relogin";
  for (var thisData in customerOptionsFromVariable) {
    if (thisData.customerId == int.parse(customerId)) {
      thisCustomerName = thisData.name;
    }
  }

  return thisCustomerName;
}

String getItemName(int itemId, int itemUniqueId) {
  String thisItemName = "no data";
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName =
          "${thisData.itemGroup} - ${thisData.itemName}(${thisData.stocksType})";
    }
  }

  return thisItemName;
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

String getItemNameOnlyTest(int itemId, int itemUniqueId) {
  String thisItemName = "no data";
  print("itemid=$itemId unique=$itemUniqueId");
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName = "${thisData.itemGroup} ${thisData.itemName}";
      exit;
    }
  }
  return thisItemName;
}

String getItemNameStocksType(int itemId, int itemUniqueId) {
  String thisItemName = "no data";
  for (var thisData in listSuppItemsAll) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName = thisData.stocksType;
    }
  }

  return thisItemName;
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

void resetAddOnVar() {
  bDetAddOnVar = false;
  bFabAddOnVar = false;
  bBleAddOnVar = false;
  bOthAddOnVar = false;
}

void allCardsVar(BuildContext context) {
  Navigator.pop(context);
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const LoyaltyAdmin()));
}

void refillJobsList() {
  finListNumbering = [
    "#1#",
    "#2#",
    "#3#",
    "#4#",
    "#5#",
    "#6#",
    "#7#",
    "#8#",
    "#9#",
    "#10#",
    "#11#",
    "#12#",
    "#13#",
    "#14#",
    "#15#",
    "#16#",
    "#17#",
    "#18#",
    "#19#",
    "#20#",
    "#21#",
    "#22#",
    "#23#",
    "#24#",
    "#25#"
  ];

  lasListNumbering = [
    "#1#",
    "#2#",
    "#3#",
    "#4#",
    "#5#",
    "#6#",
    "#7#",
    "#8#",
    "#9#",
    "#10#",
    "#11#",
    "#12#",
    "#13#",
    "#14#",
    "#15#",
    "#16#",
    "#17#",
    "#18#",
    "#19#",
    "#20#",
    "#21#",
    "#22#",
    "#23#",
    "#24#",
    "#25#"
  ];
}

void resetAddOnsGlobalVar() {
  listAddOnItemsGlobal.clear();
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

bool ifMenuUniqueIsFundsIn(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdFundsIn) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsFundsInEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdFundsIn) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsFee(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdFee) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsFeeEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdFee) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLaundryPayment(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthLaundryPayment) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLaundryPaymentEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthLaundryPayment) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLoad(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthUniqIdLoad) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLoadEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdLoad) {
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

bool ifMenuUniqueIsCashOutEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdCashOut) {
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

bool ifMenuUniqueIsEODEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdFundsEOD) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLPaymentGCash(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthLaundryPaymentGCash) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLPaymentGCashEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthLaundryPaymentGCash) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsLPDonPCash(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthLPDonPCash) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsExpense(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId == menuOthExpense) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsExpenseEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthExpense) {
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

bool ifMenuUniqueIsFundsOutEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthUniqIdFundsOut) {
    return true;
  }
  return false;
}

bool ifMenuUniqueIsSalaryPayEmp(EmployeeModel eM) {
  if (eM.itemUniqueId == menuOthSalaryPayment) {
    return true;
  }
  return false;
}

void resetSHGlobalVar() {
  bNagbigayFee = true;
  bGcashFee = false;
  remarksSuppliesVar.text = "";
  suppliesModelHistGlobal = SuppliesModelHist(
      docId: "",
      countId: 0,
      itemId: selectedSupVar.itemId,
      itemUniqueId: selectedSupVar.itemUniqueId,
      itemName: selectedSupVar.itemName,
      currentCounter: 0,
      currentStocks: 0,
      logDate: Timestamp.now(),
      empId: empIdGlobal,
      customerId: 1,
      customerName: '',
      remarks: "");

  sMHGLaundryPayment = SuppliesModelHist(
      docId: "",
      countId: 0,
      itemId: menuOthCashInOutFunds,
      itemUniqueId: menuOthLaundryPayment,
      itemName: 'Laundry Payment',
      currentCounter: 0,
      currentStocks: 0,
      logDate: Timestamp.now(),
      empId: empIdGlobal,
      customerId: 1,
      customerName: '',
      remarks: "");

  sMHGLaundryPaymentDonP = SuppliesModelHist(
      docId: "",
      countId: 0,
      itemId: menuOthLPDonP,
      itemUniqueId: menuOthLPDonPCash,
      itemName: 'Laundry Payment DonP Cash',
      currentCounter: 0,
      currentStocks: 0,
      logDate: Timestamp.now(),
      empId: empIdGlobal,
      customerId: 1,
      customerName: '',
      remarks: "");

  sMHGLaundryPaymentGCash = SuppliesModelHist(
      docId: "",
      countId: 0,
      itemId: menuOthLaundryPaymentGCash,
      itemUniqueId: menuOthLaundryPaymentGCash,
      itemName: 'Laundry Payment GCash',
      currentCounter: 0,
      currentStocks: 0,
      logDate: Timestamp.now(),
      empId: empIdGlobal,
      customerId: 1,
      customerName: '',
      remarks: "");
}

void updateSelectedVar(OtherItemModel selectedItemModel) {
  if (listDetItems.contains(selectedItemModel)) {
    selectedDetVar = selectedItemModel;
  } else if (listFabItems.contains(selectedItemModel)) {
    selectedFabVar = selectedItemModel;
  } else if (listBleItems.contains(selectedItemModel)) {
    selectedBleVar = selectedItemModel;
  } else if (listOthItems.contains(selectedItemModel)) {
    selectedOthVar = selectedItemModel;
  }
}

Widget cancelButtonVar(BuildContext context) {
  return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);
      },
      color: cButtons,
      child: const Text("Cancel"));
}

Widget closeButtonVar(BuildContext context) {
  return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);
      },
      color: cButtons,
      child: const Text("Close"));
}

Widget closeButton2popVar(BuildContext context) {
  return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);
        Navigator.pop(context);
      },
      color: cButtons,
      child: const Text("Close"));
}

Widget createNewSuppVar(BuildContext context, SuppliesModelHist sMH) {
  return MaterialButton(
    onPressed: () async {
      //bInsertDataSuppliesHist = false;
      //if (!bAutoLaundry) {
      sMH.customerId = autocompleteSelected.customerId;
      sMH.remarks = remarksSuppliesVar.text;
      //}

      if (sMH.customerId == 1 || !bCustomerName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Select Customer Name')),
        );
      } else if ((ifMenuUniqueIsCashIn(sMH) ||
              ifMenuUniqueIsFundsIn(sMH) ||
              ifMenuUniqueIsLaundryPayment(sMH)
          //ifMenuUniqueIsLPaymentGCash(sMH) ||
          //ifMenuUniqueIsLPDonPCash(sMH)
          ) &&
          sMH.currentCounter <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cash In/Funds In/Laundry Payment should be positive number.')),
        );
      } else if ((ifMenuUniqueIsCashOut(sMH) ||
              ifMenuUniqueIsFundsOut(sMH) ||
              ifMenuUniqueIsExpense(sMH)) &&
          sMH.currentCounter >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Cash Out/Funds Out should be negative number.')),
        );
      } else {
        if (await insertDataSuppliesHistVar(sMH)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Success')),
          );
          //bInsertDataSuppliesHist = true;
          print("Sucess");
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot Save')),
          );
          print("Failed");
        }
      }

      //pop box
    },
    color: cButtons,
    child: const Text("Save"),
  );
}

Widget readAddedDataVar(List<OtherItemModel> listAddedOthers) {
  bool zebra = false;
  //read

  List<TableRow> rowDatas = [];

  if (listAddedOthers.isNotEmpty) {
    const rowData =
        TableRow(decoration: BoxDecoration(color: Colors.blueGrey), children: [
      Text(
        "Group ",
        style: TextStyle(fontSize: 10),
      ),
      Text(
        "Product ",
        style: TextStyle(fontSize: 10),
      ),
      Text(
        "Price",
        style: TextStyle(fontSize: 10),
      ),
    ]);
    rowDatas.add(rowData);
  }

  for (var listAddedOther in listAddedOthers) {
    if (zebra) {
      zebra = false;
    } else {
      zebra = true;
    }
    final rowData = TableRow(
        decoration: BoxDecoration(color: zebra ? Colors.grey : Colors.white),
        children: [
          Text(
            listAddedOther.itemGroup,
            style: TextStyle(fontSize: 10),
          ),
          Text(
            listAddedOther.itemName,
            style: TextStyle(fontSize: 10),
          ),
          Text(
            "${listAddedOther.itemPrice}.00",
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.end,
          ),
        ]);
    rowDatas.add(rowData);
  }

  return Table(
    defaultColumnWidth: IntrinsicColumnWidth(),
    children: rowDatas,
  );
}

bool displayInList(int itemUniqueId) {
  if (itemUniqueId >= 10000) {
    if (mapDisplayInList[empIdGlobal + itemUniqueId.toString()] == 1) {
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

String convertTimeStampVar(Timestamp timestamp) {
  //assert(timestamp != null);
  String convertedDate;
  convertedDate = DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  //return "${convertedDate.substring(0, convertedDate.indexOf(',') + 1)} ${convertedDate.substring(convertedDate.indexOf(':') - 2, convertedDate.indexOf(':'))} ${convertedDate.substring(convertedDate.indexOf(':') + 4, convertedDate.indexOf(':') + 6)}";
  return convertedDate;
}

void showMessage(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(backgroundColor: Colors.amber[300]),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            closeButtonVar(context),
          ],
        );
      });
    },
  );
}

void addField(String colRef, SuppliesModelHist sMH) {
  // _suppliesCurrRef --if reuse, will not work

  // var weekNum2 = Timestamp.now();
  var weekNum =
      DateTime.fromMicrosecondsSinceEpoch(sMH.logDate.microsecondsSinceEpoch);

  //print("week of year=${weekNum.weekOfYear}");

  var collectionRef = FirebaseFirestore.instance;
  collectionRef
      .collection(colRef)
      .doc(sMH.docId)
      .set({'WeekOfYear': weekNum}, SetOptions(merge: true)).then((value) {});
  // print("currentstocks=${sMH.currentStocks}");
}
