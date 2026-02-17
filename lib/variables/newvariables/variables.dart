import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';
import 'package:laundry_firebase/models/oldmodels/customermodel.dart';
import 'package:laundry_firebase/models/newmodels/employeemodel.dart';
import 'package:laundry_firebase/models/oldmodels/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/loyalty_admin.dart';
import 'package:laundry_firebase/pages/oldpages/queue.dart';
import 'package:laundry_firebase/services/oldservices/database_jobsonqueue.dart';
import 'package:laundry_firebase/services/oldservices/database_other_items.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';
import 'package:laundry_firebase/variables/oldvariables/vairables_jobsonqueue.dart';
import 'package:laundry_firebase/variables/newvariables/variables_ble.dart';
import 'package:laundry_firebase/variables/newvariables/variables_det.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/oldvariables/variables_jobsdone.dart';
import 'package:laundry_firebase/variables/oldvariables/variables_jobsongoing.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

const String storageKey = 'customer_code';

bool loading = true;
bool loggedIn = false;
bool rememberMe = true;
TextEditingController memberController = TextEditingController();

late bool bHaveInternet = false;
bool showDet = false, showFab = false, showBle = false, showOth = false;
bool bDelAddOnsVar = true;
bool bCustomerName = false;
//bool bAutoLaundry = false;
//bool bInsertDataSuppliesHist = false;
//bool bTest = false;
bool bGcashFee = false;
bool bNagbigayFee = true;
final value = new NumberFormat("##,##0", "en_US");
late bool isAdmin = false;
const bool allowPayment = true;
late int alwaysTheLatestFunds;

late JobsOnQueueModel jobsOnQueueModelGlobal;
final GCashModel finalGCashModel = GCashModel(
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
    remarks: "",
    imageUrl: "");
late SuppliesModelHist suppliesModelHistGlobal;
late SuppliesModelHist sMHGLaundryPayment;
late SuppliesModelHist sMHGLaundryPaymentDonP;
late SuppliesModelHist sMHGLaundryPaymentGCash;
late String empIdGlobal = "";
late String selectedNumberVar = "1";
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
const int forSorting = 501,
    riderPickup = 502,
    regularPackage = 503,
    sayoSabonPackage = 504,
    othersPackage = 505,
    waitingStat = 601,
    washingStat = 602,
    dryingStat = 603,
    foldingStat = 604,
    waitCustomerPickup = 701,
    waitRiderDelivery = 702,
    nasaCustomerNa = 703;

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

late List<String> finListNumbering = [];
late List<String> lasListNumbering = [];
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

late bool allowDecimal = false;
// int iBasketVar = 0, iBagVar = 0;
bool bUnpaidVar = true, bPaidCashVar = false, bPaidGCashVar = false;
// bool bMixVar = true, bFoldVar = true;
TextEditingController remarksControllerVar = TextEditingController();
TextEditingController remarksSuppliesVar = TextEditingController();
TextEditingController counterControllerVar = TextEditingController();

DateTime dNeedOnVar = DateTime.now().add(Duration(minutes: 210));

// Timestamp tNeedOnVar = Timestamp.now();

void putEntries() {
  resetJOQMGlobalVar();
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
  mapQueueStat.addEntries({forSorting: "ForSorting"}.entries);
  mapQueueStat.addEntries({riderPickup: "RiderPickup"}.entries);
  mapQueueStat.addEntries({waitingStat: "Waiting"}.entries);
  mapQueueStat.addEntries({washingStat: "Washing"}.entries);
  mapQueueStat.addEntries({dryingStat: "Drying"}.entries);
  mapQueueStat.addEntries({foldingStat: "Folding"}.entries);
  mapQueueStat.addEntries({waitCustomerPickup: "WaitCustomerPickup"}.entries);
  mapQueueStat.addEntries({waitRiderDelivery: "WaitRiderDelivery"}.entries);
  mapQueueStat.addEntries({nasaCustomerNa: "NasaCustomerNa"}.entries);

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
  mapQueueStat.addEntries({forSorting: "ForSorting"}.entries);
  mapQueueStat.addEntries({riderPickup: "RiderPickup"}.entries);
  mapQueueStat.addEntries({waitingStat: "Waiting"}.entries);
  mapQueueStat.addEntries({washingStat: "Washing"}.entries);
  mapQueueStat.addEntries({dryingStat: "Drying"}.entries);
  mapQueueStat.addEntries({foldingStat: "Folding"}.entries);
  mapQueueStat.addEntries({waitCustomerPickup: "WaitCustomerPickup"}.entries);
  mapQueueStat.addEntries({waitRiderDelivery: "WaitRiderDelivery"}.entries);
  mapQueueStat.addEntries({nasaCustomerNa: "NasaCustomerNa"}.entries);

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

Future<void> checkInternet(BuildContext context) async {
  bHaveInternet = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      bHaveInternet = true;
    } else {
      bHaveInternet = false;
    }
  } on Exception catch (exception) {
  } catch (error) {}
  if (!bHaveInternet) {
    showMessageNoInternet(context);
  }
}

void showMessageNoInternet(BuildContext context) {
  showMessage(context, "No internet", "Check your internet.");
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
  customerOptionsFromVariable.forEach((thisData) {
    if (thisData.customerId == int.parse(customerId)) {
      thisCustomerName = thisData.name;
    }
  });

  return thisCustomerName;
}

String getItemName(int itemId, int itemUniqueId) {
  String thisItemName = "no data";
  listSuppItemsAll.forEach((thisData) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName =
          "${thisData.itemGroup} - ${thisData.itemName}(${thisData.stocksType})";
    }
  });

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
  listSuppItemsAll.forEach((thisData) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisItemName = thisData.stocksType;
    }
  });

  return thisItemName;
}

int getItemNameStocksAlert(int itemId, int itemUniqueId) {
  int thisReturn = 0;
  listSuppItemsAll.forEach((thisData) {
    if (thisData.itemId == itemId && thisData.itemUniqueId == itemUniqueId) {
      thisReturn = thisData.stocksAlert;
    }
  });

  return thisReturn;
}

JobsOnQueueModel resetPaymentQueueBool(JobsOnQueueModel jOQM) {
  jOQM.unpaid = false;
  jOQM.paidcash = false;
  jOQM.paidgcash = false;

  return jOQM;
  // bUnpaidVar = false;
  // bPaidCashVar = false;
  // bPaidGCashVar = false;
}

JobsOnQueueModel resetRegular(JobsOnQueueModel jOQM) {
  jOQM.regular = false;
  jOQM.sayosabon = false;
  jOQM.others = false;
  bShowKiloLoadDisplayVar = true;
  bShowKiloDisplayOthVar = false;
  return jOQM;

  // bRegularSabonVar = false;
  // bSayoSabonVar = false;
  // bOtherServicesVar = false;
  // bShowKiloLoadDisplayVar = true;
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

void resetJOQMGlobalVar() {
  jobsOnQueueModelGlobal = JobsOnQueueModel(
      docId: "",
      dateQ: Timestamp.now(),
      forSorting: true,
      riderPickup: false,
      initTagForDeliveryWhenDone: false,
      createdBy: "",
      currentEmpId: "",
      customerId: 0,
      customerName: "",
      perKilo: true,
      initialKilo: 8,
      initialLoad: 1,
      initialPrice: 155,
      initialOthersPrice: 0,
      finalKilo: 0,
      finalLoad: 0,
      finalPrice: 0,
      finalOthersPrice: 0,
      regular: true,
      sayosabon: false,
      others: false,
      addOns: false,
      needOn: Timestamp.now(),
      fold: true,
      mix: true,
      basket: 0,
      bag: 0,
      remarks: "",
      unpaid: true,
      paidcash: false,
      paidgcash: false,
      paidgcashverified: false,
      paymentReceivedBy: "",
      paymentLaundryGenerated: false,
      dateO: Timestamp.fromDate(DateTime(2000)),
      paidD: Timestamp.fromDate(DateTime(2000)),
      jobsId: 99,
      waiting: false,
      washing: false,
      drying: false,
      folding: false,
      dateD: Timestamp.fromDate(DateTime(2000)),
      waitCustomerPickup: false,
      waitRiderDelivery: false,
      nasaCustomerNa: false,
      waitingOneWeek: false,
      waitingTwoWeeks: false,
      forDisposal: false,
      disposed: false);
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

Widget cancelButtonReloginVar(BuildContext context, JobsOnQueueModel jOQM) {
  return MaterialButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Records not save')),
        );
        //pop box
        Navigator.pop(context);
        Navigator.pop(context);

        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MyQueue(empIdGlobal)));
      },
      color: cButtons,
      child: const Text("Cancel"));
}

Widget cancelButtonNoChangeVar(
  BuildContext context,
  Function setState,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) {
  return MaterialButton(
      onPressed: () {
        //pop box
        //not working
        //jOQM = jOQMNoChange;

        resetJOQMToNoChange(jOQM, jOQMNoChange);
        lOIM.clear();
        lOIM.addAll(lOIMNoChange);
        setState(() {
          jOQM;
          lOIM;
        });
        Navigator.pop(context);
      },
      color: cButtons,
      child: const Text("Cancel"));
}

void resetTest(JobsOnQueueModel jOQM, JobsOnQueueModel jOQMNoChange) {
  jOQM = jOQMNoChange;
}

void resetJOQMToNoChange(JobsOnQueueModel jOQM, JobsOnQueueModel jOQMNoChange) {
  jOQM.docId = jOQMNoChange.docId;
  jOQM.dateQ = jOQMNoChange.dateQ;
  jOQM.createdBy = jOQMNoChange.createdBy;
  jOQM.currentEmpId = jOQMNoChange.currentEmpId;
  jOQM.customerId = jOQMNoChange.customerId;
  jOQM.perKilo = jOQMNoChange.perKilo;
  jOQM.initialKilo = jOQMNoChange.initialKilo;
  jOQM.initialLoad = jOQMNoChange.initialLoad;
  jOQM.initialPrice = jOQMNoChange.initialPrice;
  jOQM.initialOthersPrice = jOQMNoChange.initialOthersPrice;
  jOQM.finalKilo = jOQMNoChange.finalKilo;
  jOQM.finalLoad = jOQMNoChange.finalLoad;
  jOQM.finalPrice = jOQMNoChange.finalPrice;
  jOQM.finalOthersPrice = jOQMNoChange.finalOthersPrice;
  jOQM.regular = jOQMNoChange.regular;
  jOQM.sayosabon = jOQMNoChange.sayosabon;
  jOQM.others = jOQMNoChange.others;
  jOQM.addOns = jOQMNoChange.addOns;
  jOQM.needOn = jOQMNoChange.needOn;
  jOQM.fold = jOQMNoChange.fold;
  jOQM.mix = jOQMNoChange.mix;
  jOQM.basket = jOQMNoChange.basket;
  jOQM.bag = jOQMNoChange.bag;
  jOQM.remarks = jOQMNoChange.remarks;
  jOQM.unpaid = jOQMNoChange.unpaid;
  jOQM.paidcash = jOQMNoChange.paidcash;
  jOQM.paidgcash = jOQMNoChange.paidgcash;
  jOQM.paymentReceivedBy = jOQMNoChange.paymentReceivedBy;
  jOQM.dateO = jOQMNoChange.dateO;
  jOQM.paidD = jOQMNoChange.paidD;
  jOQM.forSorting = jOQMNoChange.forSorting;
  jOQM.riderPickup = jOQMNoChange.riderPickup;
  jOQM.jobsId = jOQMNoChange.jobsId;
  jOQM.waiting = jOQMNoChange.waiting;
  jOQM.washing = jOQMNoChange.washing;
  jOQM.drying = jOQMNoChange.drying;
  jOQM.folding = jOQMNoChange.folding;
  jOQM.dateD = jOQMNoChange.dateD;
  jOQM.waitCustomerPickup = jOQMNoChange.waitCustomerPickup;
  jOQM.waitRiderDelivery = jOQMNoChange.waitRiderDelivery;
  jOQM.nasaCustomerNa = jOQMNoChange.nasaCustomerNa;
  jOQM.waitingOneWeek = jOQMNoChange.waitingOneWeek;
  jOQM.waitingTwoWeeks = jOQMNoChange.waitingTwoWeeks;
  jOQM.forDisposal = jOQMNoChange.forDisposal;
  jOQM.disposed = jOQMNoChange.disposed;
}

void resetJOQMNoChangeToJOQM(
    JobsOnQueueModel jOQMNoChange, JobsOnQueueModel jOQM) {
  jOQMNoChange.docId = jOQM.docId;
  jOQMNoChange.dateQ = jOQM.dateQ;
  jOQMNoChange.createdBy = jOQM.createdBy;
  jOQMNoChange.currentEmpId = jOQM.currentEmpId;
  jOQMNoChange.customerId = jOQM.customerId;
  jOQMNoChange.perKilo = jOQM.perKilo;
  jOQMNoChange.initialKilo = jOQM.initialKilo;
  jOQMNoChange.initialLoad = jOQM.initialLoad;
  jOQMNoChange.initialPrice = jOQM.initialPrice;
  jOQMNoChange.initialOthersPrice = jOQM.initialOthersPrice;
  jOQMNoChange.finalKilo = jOQM.finalKilo;
  jOQMNoChange.finalLoad = jOQM.finalLoad;
  jOQMNoChange.finalPrice = jOQM.finalPrice;
  jOQMNoChange.finalOthersPrice = jOQM.finalOthersPrice;
  jOQMNoChange.regular = jOQM.regular;
  jOQMNoChange.sayosabon = jOQM.sayosabon;
  jOQMNoChange.others = jOQM.others;
  jOQMNoChange.addOns = jOQM.addOns;
  jOQMNoChange.needOn = jOQM.needOn;
  jOQMNoChange.fold = jOQM.fold;
  jOQMNoChange.mix = jOQM.mix;
  jOQMNoChange.basket = jOQM.basket;
  jOQMNoChange.bag = jOQM.bag;
  jOQMNoChange.remarks = jOQM.remarks;
  jOQMNoChange.unpaid = jOQM.unpaid;
  jOQMNoChange.paidcash = jOQM.paidcash;
  jOQMNoChange.paidgcash = jOQM.paidgcash;
  jOQMNoChange.paymentReceivedBy = jOQM.paymentReceivedBy;
  jOQMNoChange.dateO = jOQM.dateO;
  jOQMNoChange.paidD = jOQM.paidD;
  jOQMNoChange.forSorting = jOQM.forSorting;
  jOQMNoChange.riderPickup = jOQM.riderPickup;
  jOQMNoChange.jobsId = jOQM.jobsId;
  jOQMNoChange.waiting = jOQM.waiting;
  jOQMNoChange.washing = jOQM.washing;
  jOQMNoChange.drying = jOQM.drying;
  jOQMNoChange.folding = jOQM.folding;
  jOQMNoChange.dateD = jOQM.dateD;
  jOQMNoChange.waitCustomerPickup = jOQM.waitCustomerPickup;
  jOQMNoChange.waitRiderDelivery = jOQM.waitRiderDelivery;
  jOQMNoChange.nasaCustomerNa = jOQM.nasaCustomerNa;
  jOQMNoChange.waitingOneWeek = jOQM.waitingOneWeek;
  jOQMNoChange.waitingTwoWeeks = jOQM.waitingTwoWeeks;
  jOQMNoChange.forDisposal = jOQM.forDisposal;
  jOQMNoChange.disposed = jOQM.disposed;
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

Future<void> insertDataSuppliesHistoryVarLaundry(
    BuildContext context, JobsOnQueueModel jOQM) async {
  SuppliesModelHist sMH;
  if (jOQM.paidgcash) {
    sMH = sMHGLaundryPaymentGCash;
  } else {
    if (empIdGlobal == "DonP") {
      sMH = sMHGLaundryPaymentDonP;
    } else {
      sMH = sMHGLaundryPayment;
    }
  }

  sMH.customerId = jOQM.customerId;
  sMH.currentCounter = jOQM.initialPrice + jOQM.initialOthersPrice;

  jOQM.remarks = "${jOQM.remarks} Paid=${sMH.currentCounter}";

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

  listAddedOthers.forEach((listAddedOther) {
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
  });

  return Table(
    defaultColumnWidth: IntrinsicColumnWidth(),
    children: rowDatas,
  );
}

//insert new Queue
void insertDataJobsOnQueueVar(JobsOnQueueModel jOQM) {
  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  databaseJobsOnQueue.addJobsOnQueue(jOQM, listAddOnItemsGlobal);
}

//displays in Popup
Container conEnterCustomer(BuildContext context, Function setState) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Enter Customer Name',
          style: TextStyle(fontSize: 10),
        ),
        //AutoCompleteCustomer(),
        SizedBox(
          height: 5,
        ),
        MaterialButton(
          color: cButtons,
          onPressed: () {
            allCardsVar(context);
          },
          child: Text("New Account"),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    ),
  );
}

Container conCustomerName(
    BuildContext context, Function setState, JobsOnQueueModel jOQM) {
  return Container(
    width: 300,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Customer Name',
          style: TextStyle(fontSize: 10),
        ),
        Text(customerName(jOQM.customerId.toString())),
        SizedBox(
          height: 5,
        ),
      ],
    ),
  );
}

Container conGCashVerified(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            value: jOQM.paidgcashverified,
            onChanged: (val) {
              setState(
                () {
                  jOQM.paidgcashverified = val!;
                },
              );
            }),
        Text("Gcash Verification Done"),
      ],
    ),
  );
}

Visibility visExtraOnQueueVar(BuildContext context, Function setState,
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Add WKL Fab"),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          lOIM.add(OtherItemModel(
                            docId: "",
                            itemId: menuFabWKLDValPurpleDVal,
                            itemUniqueId: menuFabWKLDValPurple24mlDVal,
                            itemGroup: groupFab,
                            itemName: "WKL Fabcon 24ml",
                            itemPrice: 8,
                            stocksAlert: 5,
                            stocksType: "pcs",
                          ));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;

                          jOQM.remarks = "${jOQM.remarks} +Fab";

                          showMessage(context, "Extras", "Add Fab added.");
                        },
                      );
                    },
                    icon: const Icon(Icons.flare_outlined),
                    color: Colors.blueAccent,
                  ),
                  Text("Extra Dry"),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          lOIM.add(OtherItemModel(
                            docId: "",
                            itemId: menuOthXD,
                            itemUniqueId: menuOthXD,
                            itemGroup: groupOth,
                            itemName: "Extra Dry",
                            itemPrice: 15,
                            stocksAlert: 5,
                            stocksType: "pcs",
                          ));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;
                          jOQM.remarks = "${jOQM.remarks} +XD";

                          showMessage(context, "Extras", "Extra Dry added.");
                        },
                      );
                    },
                    icon: const Icon(Icons.dry_cleaning_outlined),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Extra Wash"),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          lOIM.add(OtherItemModel(
                            docId: "",
                            itemId: menuOthXW,
                            itemUniqueId: menuOthXW,
                            itemGroup: groupOth,
                            itemName: "Extra Wash",
                            itemPrice: 15,
                            stocksAlert: 5,
                            stocksType: "pcs",
                          ));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;
                          jOQM.remarks = "${jOQM.remarks} +XW";

                          showMessage(context, "Extras", "Extra Wash added.");
                        },
                      );
                    },
                    icon: const Icon(Icons.water_drop_outlined),
                    color: Colors.blueAccent,
                  ),
                  Text("Extra Rinse"),
                  IconButton(
                    onPressed: () {
                      setState(
                        () {
                          lOIM.add(OtherItemModel(
                            docId: "",
                            itemId: menuOthXR,
                            itemUniqueId: menuOthXR,
                            itemGroup: groupOth,
                            itemName: "Extra Rinse",
                            itemPrice: 15,
                            stocksAlert: 5,
                            stocksType: "pcs",
                          ));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;
                          jOQM.remarks = "${jOQM.remarks} +XR";

                          showMessage(context, "Extras", "Extra Rinse added.");
                        },
                      );
                    },
                    icon: const Icon(Icons.webhook_outlined),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Visibility visExtraOnGoingVar(BuildContext context, Function setState,
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  return Visibility(
    visible: true,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Extra Dry"),
              IconButton(
                onPressed: () {
                  setState(
                    () {
                      lOIM.add(OtherItemModel(
                        docId: "",
                        itemId: menuOthXD,
                        itemUniqueId: menuOthXD,
                        itemGroup: groupOth,
                        itemName: "Extra Dry",
                        itemPrice: 15,
                        stocksAlert: 5,
                        stocksType: "pcs",
                      ));
                      bViewAddOnDtlOnGoing = true;

                      jOQM.initialOthersPrice = jOQM.initialOthersPrice + 15;
                      jOQM.remarks = "${jOQM.remarks} +XD";

                      showMessage(context, "Extras", "Extra Dry added.");
                    },
                  );
                },
                icon: const Icon(Icons.dry_cleaning_outlined),
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Container conOrderModeVar(
    Function setState, JobsOnQueueModel jOQM, BoxDecoration conDecoration) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: conDecoration,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  "Regular",
                  style: TextStyle(fontSize: 10),
                ),
                Checkbox(
                    value: jOQM.regular,
                    onChanged: (val) {
                      jOQM = resetRegular(jOQM);

                      if (val!) {
                        setState(
                          () {
                            jOQM.regular = val;
                          },
                        );
                      }

                      jOQM.initialKilo = 8;
                      jOQM.initialPrice =
                          (jOQM.initialKilo ~/ 8) * iPriceDivider(jOQM.regular);
                      jOQM.initialLoad = (jOQM.initialKilo ~/ 8);
                    })
              ],
            ),
            Column(
              children: [
                Text(
                  "Sayo Sabon",
                  style: TextStyle(fontSize: 10),
                ),
                Checkbox(
                    value: jOQM.sayosabon,
                    onChanged: (val) {
                      jOQM = resetRegular(jOQM);

                      if (val!) {
                        setState(
                          () {
                            jOQM.sayosabon = val;
                          },
                        );
                      }

                      jOQM.initialKilo = 8;
                      jOQM.initialPrice =
                          (jOQM.initialKilo ~/ 8) * iPriceDivider(jOQM.regular);
                      jOQM.initialLoad = (jOQM.initialKilo ~/ 8);
                    })
              ],
            ),
            Column(
              children: [
                Text(
                  "Others",
                  style: TextStyle(fontSize: 10),
                ),
                Checkbox(
                    value: jOQM.others,
                    onChanged: (val) {
                      jOQM = resetRegular(jOQM);
                      bShowKiloLoadDisplayVar = false;
                      bShowKiloDisplayOthVar = true;

                      if (val!) {
                        setState(
                          () {
                            jOQM.others = val;
                          },
                        );
                      }

                      jOQM.initialKilo = 0;
                      jOQM.initialPrice = 0;
                      jOQM.initialLoad = 0;
                    })
              ],
            ),
          ],
        ),
        //New Estimate Load display
        Visibility(
          visible: bShowKiloLoadDisplayVar,
          child: Container(
            padding: EdgeInsets.all(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Weight:"),
                      Text("${kiloDisplay(jOQM.initialKilo)} kilo"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Load:"),
                      Text("${jOQM.initialLoad}"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Load Price:"),
                      Text(
                          "${autoPriceDisplay(jOQM.initialPrice, jOQM.regular)}.00"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        //New estimate load +-8 kilo
        Visibility(
          visible: bShowKiloLoadDisplayVar,
          child: Container(
            padding: EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
                  decoration: BoxDecoration(
                      color: Colors.amber[400],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (jOQM.initialKilo < 8) {
                            jOQM.initialKilo = 8;
                            jOQM.initialPrice = (jOQM.initialKilo ~/ 8) *
                                iPriceDivider(jOQM.regular);
                            jOQM.initialLoad = (jOQM.initialKilo ~/ 8);
                          } else {
                            if (jOQM.initialKilo % 8 != 0) {
                              jOQM.initialKilo =
                                  jOQM.initialKilo - (jOQM.initialKilo % 8);
                            } else {
                              jOQM.initialKilo = jOQM.initialKilo - 8;
                            }

                            jOQM.initialPrice = (jOQM.initialKilo ~/ 8) *
                                iPriceDivider(jOQM.regular);

                            jOQM.initialLoad = (jOQM.initialKilo ~/ 8);
                          }
                          setState(() {
                            jOQM.initialKilo;
                            jOQM.initialLoad;
                            jOQM.initialPrice;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outlined),
                        color: Colors.blueAccent,
                      ),
                      Text("-8 kg"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
                  decoration: BoxDecoration(
                      color: Colors.amber[400],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("+8 kg"),
                      IconButton(
                        onPressed: () {
                          if (jOQM.initialKilo % 8 != 0) {
                            jOQM.initialKilo =
                                jOQM.initialKilo + 8 - (jOQM.initialKilo % 8);
                          } else {
                            jOQM.initialKilo = jOQM.initialKilo + 8;
                          }

                          jOQM.initialPrice = (jOQM.initialKilo ~/ 8) *
                              (iPriceDivider(jOQM.regular));
                          jOQM.initialLoad = jOQM.initialKilo ~/ 8;
                          setState(() {
                            jOQM.initialKilo;
                            jOQM.initialLoad;
                            jOQM.initialPrice;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        //New Estimate Load (+- 1 kilo)
        Visibility(
          visible: bShowKiloLoadDisplayVar,
          child: Container(
            padding: EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
                  decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (jOQM.initialKilo > 8) {
                            if (jOQM.initialKilo % 8 == 1) {
                              jOQM.initialPrice = jOQM.initialPrice -
                                  (jOQM.regular ? 25 : 25); //8-9kilo 25

                              //should be after kilo - 1;
                              // jOQM.initialLoad =
                              //     jOQM.initialLoad - 1;
                            } else if (jOQM.initialKilo % 8 == 2) {
                              jOQM.initialPrice = jOQM.initialPrice -
                                  (jOQM.regular ? 45 : 50); //9-10kilo 45
                            } else if (jOQM.initialKilo % 8 == 3) {
                              jOQM.initialPrice = jOQM.initialPrice -
                                  (jOQM.regular ? 25 : 25); //10-11kilo 25
                            } else if (jOQM.initialKilo % 8 == 4) {
                              jOQM.initialPrice = jOQM.initialPrice -
                                  (jOQM.regular ? 25 : 25); //11-12kilo
                            } else if (jOQM.initialKilo % 8 == 5) {
                              jOQM.initialPrice = jOQM.initialPrice -
                                  (jOQM.regular ? 35 : 0); //12-13kilo
                            }
                            // else if (jOQM.initialKilo % 8 ==
                            //     6) {
                            //   jOQM.initialPrice =
                            //       jOQM.initialPrice -
                            //           (jOQM.regular
                            //               ? 10
                            //               : 0); //13-16kilo
                            // }
                            jOQM.initialKilo = jOQM.initialKilo - 1;

                            if (jOQM.initialKilo % 8 == 1) {
                              //8-9kilo 25

                              jOQM.initialLoad = jOQM.initialLoad - 1;
                            }
                          }
                          setState(() {
                            jOQM.initialKilo;
                            jOQM.initialLoad;
                            jOQM.initialPrice;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outlined),
                        color: Colors.blueAccent,
                      ),
                      Text("-1 kg"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 3, bottom: 0, top: 0, right: 3),
                  decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Row(
                    children: [
                      Text("+1 kg"),
                      IconButton(
                        onPressed: () {
                          if (jOQM.initialKilo >= 8) {
                            jOQM.initialKilo = jOQM.initialKilo + 1;
                          }

                          if (jOQM.initialKilo % 8 == 1) {
                            jOQM.initialPrice = jOQM.initialPrice +
                                (jOQM.regular ? 25 : 25); //8-9kilo
                          } else if (jOQM.initialKilo % 8 == 2) {
                            jOQM.initialPrice = jOQM.initialPrice +
                                (jOQM.regular ? 45 : 50); //9-10kilo
                            jOQM.initialLoad = jOQM.initialLoad + 1;
                          } else if (jOQM.initialKilo % 8 == 3) {
                            jOQM.initialPrice = jOQM.initialPrice +
                                (jOQM.regular ? 25 : 25); //10-11kilo
                          } else if (jOQM.initialKilo % 8 == 4) {
                            jOQM.initialPrice = jOQM.initialPrice +
                                (jOQM.regular ? 25 : 25); //11-12kilo
                          } else if (jOQM.initialKilo % 8 == 5) {
                            jOQM.initialPrice = jOQM.initialPrice +
                                (jOQM.regular ? 35 : 0); //12-13kilo
                          }
                          // else {
                          //   if (jOQM.initialPrice %
                          //           (iPriceDivider(
                          //               jOQM.regular)) !=
                          //       0) {
                          //     jOQM.initialPrice =
                          //         jOQM.initialPrice +
                          //             (jOQM.regular
                          //                 ? 10
                          //                 : 0); //13-16kilo
                          //   }
                          // }

                          setState(() {
                            jOQM.initialKilo;
                            jOQM.initialLoad;
                            jOQM.initialPrice;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Visibility visAddOnVar(
    BuildContext context,
    Function setState,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    String colRef,
    JobsOnQueueModel jOQMNoChange) {
  return Visibility(
    visible: (bViewAddOnDtlOnGoing
        ? true
        : (bViewMoreOptions ? true : (jOQM.others ? true : false))),
    child: Container(
      decoration: decoLightBlue(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                "Clear Add Ons",
                style: TextStyle(fontSize: 10),
              ),
              IconButton(
                  onPressed: () {
                    showMessageDeleteAddOns(
                        context,
                        setState,
                        "Delete Add On $colRef",
                        "Delete?",
                        jOQM,
                        lOIM,
                        colRef,
                        jOQMNoChange);
                  },
                  icon: Icon(Icons.delete_outline)),
              //checkboxes add on
              Visibility(
                visible:
                    (bViewMoreOptions ? true : (jOQM.others ? true : false)),
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Det",
                            style: TextStyle(fontSize: 10),
                          ),
                          Checkbox(
                              value: bDetAddOnVar,
                              onChanged: (val) {
                                resetAddOnVar();
                                setState(
                                  () {
                                    bDetAddOnVar = val!;
                                  },
                                );
                              })
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Fab",
                            style: TextStyle(fontSize: 10),
                          ),
                          Checkbox(
                              value: bFabAddOnVar,
                              onChanged: (val) {
                                resetAddOnVar();
                                setState(
                                  () {
                                    bFabAddOnVar = val!;
                                  },
                                );
                              })
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Ble",
                            style: TextStyle(fontSize: 10),
                          ),
                          Checkbox(
                              value: bBleAddOnVar,
                              onChanged: (val) {
                                resetAddOnVar();
                                setState(
                                  () {
                                    bBleAddOnVar = val!;
                                  },
                                );
                              })
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Oth",
                            style: TextStyle(fontSize: 10),
                          ),
                          Checkbox(
                              value: bOthAddOnVar,
                              onChanged: (val) {
                                resetAddOnVar();
                                setState(
                                  () {
                                    bOthAddOnVar = val!;
                                  },
                                );
                              })
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: bDetAddOnVar,
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      DropdownButton<OtherItemModel>(
                        value: selectedDetVar,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.purple[700]),
                        underline: Container(
                          height: 2,
                          color: Colors.purple[700],
                        ),
                        items: listDetItems.map((OtherItemModel map) {
                          return DropdownMenuItem<OtherItemModel>(
                              value: map,
                              child: Text(
                                  "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                        }).toList(),
                        onChanged: (newItemModel) {
                          setState(
                            () {
                              updateSelectedVar(newItemModel!);
                            },
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(
                            () {
                              lOIM.add(selectedDetVar);
                              jOQM.initialOthersPrice =
                                  jOQM.initialOthersPrice +
                                      selectedDetVar.itemPrice;
                            },
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: bFabAddOnVar,
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      DropdownButton<OtherItemModel>(
                        value: selectedFabVar,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.purple[700]),
                        underline: Container(
                          height: 2,
                          color: Colors.purple[700],
                        ),
                        items: listFabItems.map((OtherItemModel map) {
                          return DropdownMenuItem<OtherItemModel>(
                              value: map,
                              child: Text(
                                  "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                        }).toList(),
                        onChanged: (newItemModel) {
                          setState(
                            () {
                              updateSelectedVar(newItemModel!);
                            },
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(
                            () {
                              lOIM.add(selectedFabVar);
                              jOQM.initialOthersPrice =
                                  jOQM.initialOthersPrice +
                                      selectedFabVar.itemPrice;
                            },
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: bBleAddOnVar,
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      DropdownButton<OtherItemModel>(
                        value: selectedBleVar,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.purple[700]),
                        underline: Container(
                          height: 2,
                          color: Colors.purple[700],
                        ),
                        items: listBleItems.map((OtherItemModel map) {
                          return DropdownMenuItem<OtherItemModel>(
                              value: map,
                              child: Text(
                                  "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                        }).toList(),
                        onChanged: (newItemModel) {
                          setState(
                            () {
                              updateSelectedVar(newItemModel!);
                            },
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(
                            () {
                              lOIM.add(selectedBleVar);
                              jOQM.initialOthersPrice =
                                  jOQM.initialOthersPrice +
                                      selectedBleVar.itemPrice;
                            },
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: bOthAddOnVar,
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      DropdownButton<OtherItemModel>(
                        value: selectedOthVar,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.purple[700]),
                        underline: Container(
                          height: 2,
                          color: Colors.purple[700],
                        ),
                        items: listOthItems.map((OtherItemModel map) {
                          return DropdownMenuItem<OtherItemModel>(
                              value: map,
                              child: Text(
                                  "${map.itemGroup}-${map.itemName}(${map.itemPrice}Php)"));
                        }).toList(),
                        onChanged: (newItemModel) {
                          setState(
                            () {
                              updateSelectedVar(newItemModel!);
                            },
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(
                            () {
                              lOIM.add(selectedOthVar);
                              jOQM.initialOthersPrice =
                                  jOQM.initialOthersPrice +
                                      selectedOthVar.itemPrice;
                            },
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
              readAddedDataVar(lOIM),
              //_dtAddedOthers(addOnItems),
              //_addedOn(addOnItems),
            ],
          ),
        ],
      ),
    ),
  );
}

Container conTotalPriceVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    decoration: containerTotalPriceBoxDecoration(),
    padding: EdgeInsets.only(left: 10, right: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Price:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "Php ${jOQM.initialPrice + jOQM.initialOthersPrice}.00",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Container conBasketVar(
    Function setState, JobsOnQueueModel jOQM, BoxDecoration conDecoration) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: conDecoration, //decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() => jOQM.basket--);
          },
          icon: const Icon(Icons.remove_circle_outlined),
          color: Colors.blueAccent,
        ),
        Text("Basket: ${jOQM.basket}"),
        IconButton(
          onPressed: () {
            setState(() => jOQM.basket++);
          },
          icon: const Icon(Icons.add_circle),
          color: Colors.blueAccent,
        ),
      ],
    ),
  );
}

Container conBagVar(
    Function setState, JobsOnQueueModel jOQM, BoxDecoration conDecoration) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: conDecoration,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() => jOQM.bag--);
          },
          icon: const Icon(Icons.remove_circle_outlined),
          color: Colors.blueAccent,
        ),
        Text("Bag: ${jOQM.bag}"),
        IconButton(
          onPressed: () {
            setState(() => jOQM.bag++);
          },
          icon: const Icon(Icons.add_circle),
          color: Colors.blueAccent,
        ),
      ],
    ),
  );
}

Container conPaymentVar(
    BuildContext context, Function setState, JobsOnQueueModel jOQM) {
  return Container(
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(
              "Unpaid",
              style: TextStyle(fontSize: 10),
            ),
            Checkbox(
                value: jOQM.unpaid,
                onChanged: (val) {
                  if (jOQM.paidcash || jOQM.paidgcash) {
                    showMessage(context, "Stop", "Cannot set to unpaid.");
                  } else {
                    resetPaymentQueueBool(jOQM);
                    if (val!) {
                      setState(
                        () {
                          jOQM.unpaid = val;
                          jOQM.paidD = Timestamp.fromDate(DateTime(2000));
                        },
                      );
                    }
                  }
                })
          ],
        ),
        Column(
          children: [
            Text(
              "PaidCash",
              style: TextStyle(fontSize: 10),
            ),
            Checkbox(
                value: jOQM.paidcash,
                onChanged: (val) {
                  if (jOQM.paymentLaundryGenerated) {
                    showMessage(context, "Stop",
                        "Transaction already generated, cannot unchange.");
                  } else {
                    resetPaymentQueueBool(jOQM);
                    if (val!) {
                      // SuppliesModelHist sMH;
                      // sMH = sMHGLaundryPayment;
                      // sMH.customerId = jOQM.customerId;
                      // sMH.currentCounter =
                      //     jOQM.initialPrice + jOQM.initialOthersPrice;
                      // bCustomerName = true;
                      // bAutoLaundry = true;

                      setState(
                        () {
                          jOQM.paidcash = val;
                          jOQM.paidD = Timestamp.now();
                          // createNewSuppVar(context, sMH); //plan b
                        },
                      );
                      //showMessage(context, title, message);

                      // showMessageSuppliseSaveJobs(
                      //     context,
                      //     setState,
                      //     "Save Laundry Payment",
                      //     "Save ${(getItemNameOnly(sMH.itemId, sMH.itemUniqueId))} (${sMH.currentCounter} ${getItemNameStocksType(sMH.itemId, sMH.itemUniqueId)})?",
                      //     sMH);
                    }
                  }
                })
          ],
        ),
        Column(
          children: [
            Text(
              "PaidGcash",
              style: TextStyle(fontSize: 10),
            ),
            Checkbox(
                value: jOQM.paidgcash,
                onChanged: (val) {
                  if (jOQM.paymentLaundryGenerated) {
                    showMessage(context, "Stop",
                        "Transaction already generated, cannot unchange.");
                  } else {
                    resetPaymentQueueBool(jOQM);
                    if (val!) {
                      setState(
                        () {
                          jOQM.paidgcash = val;
                          jOQM.paidD = Timestamp.now();
                        },
                      );
                    }
                  }
                })
          ],
        ),
      ],
    ),
  );
}

Container conRemarksVar(Function setState, JobsOnQueueModel jOQM) {
  remarksControllerVar.text = jOQM.remarks;
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: TextFormField(
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.start,
      controller: remarksControllerVar,
      decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
      validator: (val) {
        jOQM.remarks = val!;
      },
    ),
  );
}

Container conMoreOptions(Function setState) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoLightBlue(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Hide"),
        Switch.adaptive(
          value: bViewMoreOptions,
          onChanged: (bool value) {
            setState(() {
              bViewMoreOptions = value;
            });
          },
        ),
        Text("More"),
      ],
    ),
  );
}

Visibility visFoldVar(Function setState, JobsOnQueueModel jOQM) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No Fold"),
          Switch.adaptive(
            value: jOQM.fold,
            onChanged: (bool value) {
              setState(() {
                jOQM.fold = value;
              });
            },
          ),
          Text("Fold"),
        ],
      ),
    ),
  );
}

Visibility visMixVar(Function setState, JobsOnQueueModel jOQM) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Dont Mix"),
          Switch.adaptive(
            value: jOQM.mix,
            onChanged: (bool value) {
              setState(() {
                jOQM.mix = value;
              });
            },
          ),
          Text("Mix"),
        ],
      ),
    ),
  );
}

Visibility visITFDWDVar(Function setState, JobsOnQueueModel jOQM) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("CustPickup"),
          Switch.adaptive(
            value: jOQM.initTagForDeliveryWhenDone,
            onChanged: (bool value) {
              setState(() {
                jOQM.initTagForDeliveryWhenDone = value;
              });
            },
          ),
          Text("DelToCust"),
        ],
      ),
    ),
  );
}

Visibility visNeedOn(Function setState) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoLightBlue(),
      child: Column(
        children: [
          //Need On date?
          Container(
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(0, 212, 212, 212), width: 0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Need On: ${dNeedOnVar.toString().substring(5, 14)}00",
                ),
              ],
            ),
          ),
          //Need On Date +
          Container(
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(0, 212, 212, 212), width: 0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(days: -1)));
                  },
                  icon: const Icon(Icons.remove_circle_outlined),
                  color: Colors.blueAccent,
                ),
                Text("-1 day"),
                SizedBox(
                  width: 30,
                ),
                Text("+1 day"),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(days: 1)));
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(0, 212, 212, 212), width: 0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(hours: -1)));
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.blueAccent,
                ),
                Text("-1 hr"),
                SizedBox(
                  width: 30,
                ),
                Text("+1 hr"),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(hours: 1)));
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

//Display Queue Tables
Color getCOlorStatusVar(JobsOnQueueModel jOQM) {
//JobsOnQueue Colors
  if (jOQM.forSorting) {
    return cForSorting;
  } else if (jOQM.waiting) {
    return cWaiting;
  } else if (jOQM.washing) {
    return cWashing;
  } else if (jOQM.drying) {
    return cDrying;
  } else if (jOQM.folding) {
    return cFolding;
  } else if (jOQM.waitCustomerPickup) {
    return cWaitCustomerPickup;
  } else if (jOQM.waitRiderDelivery) {
    return cWaitRiderDelivery;
  } else if (jOQM.nasaCustomerNa) {
    return cNasaCustomerNa;
  } else if (jOQM.riderPickup) {
    return cRiderPickup;
  } else {
    return cRiderOnDelivery;
  }
  ;
}

bool isItToday(Timestamp timestamp) {
  if (DateUtils.isSameDay(timestamp.toDate(), DateTime.now())) {
    return true;
  }
  return false;
}

bool isItTomorrow(Timestamp timestamp) {
  if (DateUtils.isSameDay(
      timestamp.toDate(), DateTime.now().add(const Duration(days: 1)))) {
    return true;
  }
  return false;
}

bool displayInSummary(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId >= 10000) {
    if (mapDisplayInSummary[empIdGlobal + sMH.itemUniqueId.toString()] == 1) {
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

bool displayInHistory(SuppliesModelHist sMH) {
  if (sMH.itemUniqueId >= 10000) {
    if (mapDisplayInHistory[empIdGlobal + sMH.itemUniqueId.toString()] == 1) {
      return true;
    } else {
      return false;
    }
  } else {
    return true;
  }
}

// bool hasAccessInUniqueIdDisplay(SuppliesModelHist sMH) {
//   if (sMH.itemUniqueId >= 10000) {
//     if (mapEmpAccessv2[empIdGlobal + sMH.itemUniqueId.toString()] == 1) {
//       return true;
//     } else {
//       return false;
//     }
//   } else {
//     return true;
//   }
// }

// bool hasAccessInUniqueIdAddList(int itemUniqueId) {
//   if (itemUniqueId >= 10000) {
//     if (mapEmpAccessv2[empIdGlobal + itemUniqueId.toString()] == 1) {
//       return true;
//     } else {
//       return false;
//     }
//   } else {
//     return true;
//   }
// }

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

String displayDateVar(String s) {
  return "${s.substring(0, s.indexOf(',') + 1)} ${s.substring(s.indexOf(':') - 2, s.indexOf(':'))} ${s.substring(s.indexOf(':') + 4, s.indexOf(':') + 6)}";
}

// //
// Future<void> assignNumberAutoVar() async {
//   var colAuto = FirebaseFirestore.instance
//       .collection('JobsOnGoing')
//       .orderBy('D30_JobsId');
//   var queryAuto = await colAuto.get();
//   bool bOnlyOne = false;
//   bool bFirstLoopOnly = true;
//   bool bMiddleVacant = true;
//   int nFirstLowest = 0, nSecondLowest = 0, nPrevJobsIdFetch = 0;
//   if (queryAuto.size == 1) {
//     bOnlyOne = true;
//   }
//   for (var doc in queryAuto.docs) {
//     //once only
//     if (bOnlyOne && doc['D30_JobsId'] == 99) {
//       await doc.reference.update({
//         'D30_JobsId': 1,
//       });
//       break;
//     }

//     //once only
//     if (bFirstLoopOnly) {
//       if (doc['D30_JobsId'] != 1) {
//         nFirstLowest = 1;
//       }
//       bFirstLoopOnly = false;
//     }

//     //once only
//     if (nPrevJobsIdFetch == 0) {
//       if (doc['D30_JobsId'] == 1) {
//         nPrevJobsIdFetch = 1;
//       } else {
//         nPrevJobsIdFetch = doc['D30_JobsId'] - 1;
//       }
//     }

//     //loop
//     if (nPrevJobsIdFetch != 0) {
//       if (nPrevJobsIdFetch + 1 == doc['D30_JobsId']) {
//         nPrevJobsIdFetch = doc['D30_JobsId'];
//       } else {
//         //once found
//         if (bMiddleVacant) {
//           nPrevJobsIdFetch++;
//           if (nFirstLowest == 0) {
//             nFirstLowest = nPrevJobsIdFetch;
//           } else if (nSecondLowest == 0 && nPrevJobsIdFetch <= 25) {
//             nSecondLowest = nPrevJobsIdFetch;
//           }
//           bMiddleVacant = false;
//         }
//       }
//     }

//     //final
//     if (doc['D30_JobsId'] == 99) {
//       if (nSecondLowest == 0) {
//         await doc.reference.update({
//           'D30_JobsId': nFirstLowest,
//         });
//       } else {
//         await doc.reference.update({
//           'D30_JobsId': nSecondLowest,
//         });
//       }
//       // await doc.reference.update({
//       //   'D30_JobsId': 9,
//       // });
//     }
//   }
// }

// Future<void> assignNumberAutoVarV2() async {
//   var colAuto = FirebaseFirestore.instance
//       .collection('JobsOnGoing')
//       .orderBy('D30_JobsId');
//   var queryAuto = await colAuto.get();
//   int nFirstLowest = 0,
//       nSecondLowest = 0,
//       nPrevJobsIdFetch = 0,
//       nCurrJobsIdFetch = 0;
//   for (var doc in queryAuto.docs) {
//     if (nCurrJobsIdFetch != doc['D30_JobsId']) {
//       nPrevJobsIdFetch = nCurrJobsIdFetch;
//       nCurrJobsIdFetch = doc['D30_JobsId'];
//     }

//     if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
//         nFirstLowest != 0 &&
//         nSecondLowest == 0) {
//       nSecondLowest = nPrevJobsIdFetch + 1;
//     }

//     if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
//         nFirstLowest == 0 &&
//         nSecondLowest == 0) {
//       nFirstLowest = nPrevJobsIdFetch + 1;
//     }

//     print("nFirstLowest=$nFirstLowest nSecondLowest=$nSecondLowest");

//     //final
//     if (doc['D30_JobsId'] == 99) {
//       if (nSecondLowest == 0 || nSecondLowest > 25) {
//         //autoNumber = nFirstLowest;
//         await doc.reference.update({
//           'D30_JobsId': nFirstLowest,
//         });
//       } else {
//         //autoNumber = nSecondLowest;
//         await doc.reference.update({
//           'D30_JobsId': nSecondLowest,
//         });
//       }
//     }
//   }
// }

//Display
Container conDisplayVar(
  BuildContext context,
  bool showUpArrow,
  JobsOnQueueModel jOQM,
  //[int buffExtraDryPrice = 0, int buffJobsId = 0]
) {
  return Container(
    height: 80,
    color: getCOlorStatusVar(jOQM),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "${customerName(jOQM.customerId.toString())} (${jOQM.finalLoad == 0 ? jOQM.initialLoad : jOQM.finalLoad}) ${jOQM.basket == 0 ? "" : "${jOQM.basket}BK"} ${jOQM.bag == 0 ? "" : "${jOQM.bag}BG"}",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
              Text(
                "${jOQM.finalKilo == 0 ? jOQM.initialKilo : jOQM.finalKilo} kg ${jOQM.mix ? "" : "DM"} ${jOQM.fold ? "" : "NF"}",
                style: const TextStyle(fontSize: 9),
              ),
              Text(
                "${jOQM.unpaid ? "Unpaid" : jOQM.paidcash ? "Paid Cash" : jOQM.paidgcash ? "Paid GCash" : "Unknown"} : Php ${jOQM.initialPrice + jOQM.initialOthersPrice}.00",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  backgroundColor: (jOQM.unpaid
                      ? Colors.red[300]
                      : (jOQM.paidgcash
                          ? (jOQM.paidgcashverified
                              ? Colors.transparent
                              : Colors.red[100])
                          : Colors.transparent)),
                ),
              ),
              Text(
                (jOQM.waiting
                    ? "Waiting"
                    : (jOQM.washing
                        ? "Washing"
                        : (jOQM.drying
                            ? "Drying"
                            : (jOQM.folding
                                ? "Folding"
                                : (jOQM.forSorting
                                    ? "For Sorting"
                                    : (jOQM.waitCustomerPickup
                                        ? "Wait Customer"
                                        : (jOQM.waitRiderDelivery
                                            ? "Deliver to Customer"
                                            : (jOQM.nasaCustomerNa
                                                ? "Nasa Customer Na"
                                                : "N/A")))))))),
                style: const TextStyle(fontSize: 9),
              ),
              Text(
                //displayDateVar(convertTimeStampVar(jOQM.needOn)),
                "Need On: ${isItToday(jOQM.needOn) ? "Today" : (isItTomorrow(jOQM.needOn) ? "Tomorrow" : (displayDateVar(convertTimeStampVar(jOQM.needOn))))}",
                style: const TextStyle(
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        Column(
          children: [
            InkWell(
              onDoubleTap: () {
                if (jOQM.waiting) {
                  alterNumberMobileVar(context, jOQM);
                }
              },
              child: Text(
                //(buffJobsId == 0 ? "" : "#$buffJobsId"),
                (jOQM.jobsId == 99 ? "" : "#${jOQM.jobsId}"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Visibility(
              visible: showUpArrow,
              child: IconButton(
                onPressed: () {
                  //moveUpVar(jOQM.jobsId);
                  showMessageOptionChangeJobId(
                      context,
                      "Move/Swap Up Job#",
                      "Move up #${jOQM.jobsId} (${customerName(jOQM.customerId.toString())}) to #${(jOQM.jobsId == 1 ? 25 : jOQM.jobsId - 1)}?",
                      jOQM);
                },
                icon: const Icon(Icons.arrow_upward),
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ],
    ),
  );
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

void showMessageDeleteAddOns(
    BuildContext context,
    Function setState,
    String title,
    String message,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    String colRef,
    JobsOnQueueModel jOQMNoChange) {
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
            deleteButtonAddOnVar(context, setState, jOQM.docId, jOQM, lOIM,
                colRef, jOQMNoChange),
          ],
        );
      });
    },
  );
}

Widget deleteButtonAddOnVar(
    BuildContext context,
    Function setState,
    String docId,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    String colRef,
    JobsOnQueueModel jOQMNoChange) {
  return MaterialButton(
    onPressed: () {
      DatabaseOtherItems databaseOtherItems =
          DatabaseOtherItems(colRef, jOQM.docId);
      lOIM.forEach((aOIG) async {
        jOQM.initialOthersPrice = jOQM.initialOthersPrice - aOIG.itemPrice;
        await databaseOtherItems.deleteOtheritems(aOIG.docId);
        print("delete other items docid=${aOIG.docId}");
      });

      lOIM.clear();

      jOQM.initialOthersPrice = 0;
      jOQMNoChange.initialOthersPrice = 0;

      ///need to update the fb to requery the data, not the same with global variables
      if (colRef == "JobsOnQueue") {
        updateJOQMVar(jOQM.docId, jOQMNoChange, lOIM);
      }
      if (colRef == "JobsOnGoing") {
        updateJOGMVar(jOQM.docId, jOQMNoChange, lOIM);
      }
      if (colRef == "JobsDone") {
        updateJDMVar(jOQM.docId, jOQMNoChange, lOIM);
      }

      jOQMNoChange.others = false;

      resetJOQMToNoChange(jOQM, jOQMNoChange);

      setState(
        () {
          //jOQM.others = false;
          bViewMoreOptions = false;
          bViewAddOnDtlOnGoing = false;
          jOQM;
        },
      );
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context); //need to relogin
    },
    color: cButtons,
    child: const Text("Delete"),
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

void showMessageSuppliseSaveJobs(BuildContext context, Function setState,
    String title, String message, SuppliesModelHist sMH) {
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
            cancelButtonVar(context),
            createNewSuppVar(context, sMH),
          ],
        );
      });
    },
  );
}
