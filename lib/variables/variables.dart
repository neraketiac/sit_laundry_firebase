import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/loyalty_admin.dart';
import 'package:laundry_firebase/pages/queue.dart';
import 'package:laundry_firebase/services/database_jobsdone.dart';
import 'package:laundry_firebase/services/database_jobsongoing.dart';
import 'package:laundry_firebase/services/database_jobsonqueue.dart';
import 'package:laundry_firebase/services/database_other_items_onqueue.dart';
import 'package:laundry_firebase/services/database_other_items.dart';
import 'package:laundry_firebase/services/database_supplies_hist.dart';

late bool bHaveInternet = false;
bool showDet = false, showFab = false, showBle = false, showOth = false;
bool bDelAddOnsVar = true;

late JobsOnQueueModel jobsOnQueueModelGlobal;
late SuppliesModelHist suppliesModelHistGlobal;
late String empIdGlobal = "";
late String selectedNumberVar = "1";

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

//new start
//det
List<OtherItemModel> listDetItems = [];
List<OtherItemModel> listFabItems = [];
List<OtherItemModel> listBleItems = [];
List<OtherItemModel> listOthItems = [];
List<OtherItemModel> listAddOnItemsGlobal = [];

List<OtherItemModel> listSuppItems = [];
// const int suppIdDetWKL = 11001,
//     suppIdDetAriel = 11002,
//     suppIdFabGreenSof = 12001,
//     suppIdFabPurpleSof = 12002,
//     suppIdFabPinkSof = 12003,
//     suppIdSmallPlastic = 13001,
//     suppIdMediumPlastic = 13002,
//     suppIdLargePlastic = 13003,
//     suppIdXLPlastic = 13004;

late OtherItemModel gselectedItemModel;

List<CustomerModel> customerOptionsFromVariable = [];

CustomerModel autocompleteSelected = CustomerModel(
    customerId: 1,
    name: '1',
    address: '1',
    contact: '1',
    remarks: '1',
    loyaltyCount: 1);

const String groupDet = "Det",
    groupFab = "Fab",
    groupBle = "Ble",
    groupOth = "Oth";
//new end

int autoNumber = 0;

//det
Map<int, String> mapDetNames = {};
Map<int, int> mapDetPrice = {};
const int menuDetBreezeDVal = 103,
    menuDetArielDVal = 101,
    menuDetTideDVal = 104,
    menuDetWingsBlueDVal = 105,
    menuDetWingsRedDVal = 107,
    menuDetPowerCleanDVal = 106,
    menuDetSurfDVal = 102,
    menuDetKlinDVal = 108;

//fab
Map<int, String> mapFabNames = {};
const int menuFabSurf24mlDVal = 201,
    menuFabDowny24mlDVal = 202,
    menuFabDownyTripidDVal = 203,
    menuFabDowny36mlDVal = 204,
    menuFabSurfTripidDVal = 205,
    menuFabWKL24mlDVal = 206;

//bleach
Map<int, String> mapBleNames = {};
const int menuBleOriginalDVal = 302, menuBleColorSafeDVal = 301;

//others
Map<int, String> mapOthNames = {};
const int menuOthWash = 401,
    menuOth2W1DR = 402,
    menuOth2W1DSS = 403,
    menuOthDry = 404,
    menuOth195 = 405,
    menuOth165 = 406,
    menuOthXD = 407,
    menuOthXW = 408,
    menuOthXR = 409;

//queuestats
Map<int, String> mapQueueStat = {};
const int forSorting = 501,
    riderPickup = 502,
    waitingStat = 601,
    washingStat = 602,
    dryingStat = 603,
    foldingStat = 604,
    waitCustomerPickup = 701,
    waitRiderDelivery = 702,
    nasaCustomerNa = 703;

//paymentStats
//Map<int, String> mapPaymentStat = {};
const int unpaid = 801, paidCash = 802, paidGCash = 803, waitGCash = 804;

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
    bShowKiloLoadDisplayVar = true;
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
// int iBasketVar = 0, iBagVar = 0;
bool bUnpaidVar = true, bPaidCashVar = false, bPaidGCashVar = false;
// bool bMixVar = true, bFoldVar = true;
TextEditingController remarksControllerVar = TextEditingController();
TextEditingController counterControllerVar = TextEditingController();
DateTime dNeedOnVar = DateTime.now().add(Duration(minutes: 210));
// Timestamp tNeedOnVar = Timestamp.now();

void putEntries() {
  resetJOQMGlobalVar();
  listAddOnItemsGlobal.clear();
  fetchUsers();
  refillJobsList();
  listDetItems.clear();
  listFabItems.clear();
  listBleItems.clear();
  listOthItems.clear();
  listSuppItems.clear();

  //detItems
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetBreezeDVal,
      itemGroup: groupDet,
      itemName: "Breeze",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetArielDVal,
      itemGroup: groupDet,
      itemName: "Ariel Twinpack",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetTideDVal,
      itemGroup: groupDet,
      itemName: "Tide",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetWingsBlueDVal,
      itemGroup: groupDet,
      itemName: "Wings Blue",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetWingsRedDVal,
      itemGroup: groupDet,
      itemName: "Wings Red",
      itemPrice: 8));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetPowerCleanDVal,
      itemGroup: groupDet,
      itemName: "WKL",
      itemPrice: 8));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetSurfDVal,
      itemGroup: groupDet,
      itemName: "Surf",
      itemPrice: 10));
  listDetItems.add(OtherItemModel(
      docId: "",
      itemId: menuDetKlinDVal,
      itemGroup: groupDet,
      itemName: "Klin Twinpack",
      itemPrice: 15));
  //fab items
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabSurf24mlDVal,
      itemGroup: groupFab,
      itemName: "Surf 24ml",
      itemPrice: 8));
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabDowny24mlDVal,
      itemGroup: groupFab,
      itemName: "Downy 24ml",
      itemPrice: 8));
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabDownyTripidDVal,
      itemGroup: groupFab,
      itemName: "Downy Tripid",
      itemPrice: 17));
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabDowny36mlDVal,
      itemGroup: groupFab,
      itemName: "Downy 36ml",
      itemPrice: 10));
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabSurfTripidDVal,
      itemGroup: groupFab,
      itemName: "Surf Tripid",
      itemPrice: 17));
  listFabItems.add(OtherItemModel(
      docId: "",
      itemId: menuFabWKL24mlDVal,
      itemGroup: groupFab,
      itemName: "WKL Fabcon 24ml",
      itemPrice: 8));
  //bel items
  listBleItems.add(OtherItemModel(
      docId: "",
      itemId: menuBleColorSafeDVal,
      itemGroup: groupBle,
      itemName: "Color Safe",
      itemPrice: 5));
  //oth items
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthWash,
      itemGroup: groupOth,
      itemName: "Wash",
      itemPrice: 49));
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthDry,
      itemGroup: groupOth,
      itemName: "Dry",
      itemPrice: 49));
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth2W1DR,
      itemGroup: groupOth,
      itemName: "2Wash 1Dry(Regular)",
      itemPrice: 195));
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOth2W1DSS,
      itemGroup: groupOth,
      itemName: "2Wash 1Dry(SayoSabon)",
      itemPrice: 165));

  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthXD,
      itemGroup: groupOth,
      itemName: "Extra Dry",
      itemPrice: 15));
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthXW,
      itemGroup: groupOth,
      itemName: "Extra Wash",
      itemPrice: 15));
  listOthItems.add(OtherItemModel(
      docId: "",
      itemId: menuOthXR,
      itemGroup: groupOth,
      itemName: "Extra Rinse",
      itemPrice: 15));

  //det names
  mapDetNames.addEntries({menuDetBreezeDVal: "Breeze(15php)"}.entries);
  mapDetNames.addEntries({menuDetArielDVal: "Ariel Twinpack(15php)"}.entries);
  mapDetNames.addEntries({menuDetTideDVal: "Tide(15php)"}.entries);
  mapDetNames.addEntries({menuDetWingsBlueDVal: "Wings Blue(8php)"}.entries);
  mapDetNames.addEntries({menuDetWingsRedDVal: "Wings Red(8php)"}.entries);
  mapDetNames.addEntries({menuDetPowerCleanDVal: "Power CLean"}.entries);
  mapDetNames.addEntries({menuDetSurfDVal: "Surf(10php)"}.entries);
  mapDetNames.addEntries({menuDetKlinDVal: "Klin Twinpack(15php)"}.entries);

  //det price
  mapDetPrice.addEntries({menuDetBreezeDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetArielDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetTideDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetWingsBlueDVal: 8}.entries);
  mapDetPrice.addEntries({menuDetWingsRedDVal: 8}.entries);
  mapDetPrice.addEntries({menuDetPowerCleanDVal: 15}.entries);
  mapDetPrice.addEntries({menuDetSurfDVal: 10}.entries);
  mapDetPrice.addEntries({menuDetKlinDVal: 15}.entries);

  //fab names
  mapFabNames.addEntries({menuFabSurf24mlDVal: "Surf 24ml(8php)"}.entries);
  mapFabNames.addEntries({menuFabDowny24mlDVal: "Downy 24ml(8pp)"}.entries);
  mapFabNames
      .addEntries({menuFabDownyTripidDVal: "Downy Tripid(17php)"}.entries);
  mapFabNames.addEntries({menuFabDowny36mlDVal: "Downy 36ml(10php)"}.entries);
  mapFabNames.addEntries({menuFabSurfTripidDVal: "Surf Tripid(17php)"}.entries);
  mapFabNames
      .addEntries({menuFabWKL24mlDVal: "WKL Fabcon 24ml (8php)"}.entries);

  //det names
  mapBleNames
      .addEntries({menuBleOriginalDVal: "Bleach Original(5php)"}.entries);
  mapBleNames.addEntries({menuBleColorSafeDVal: "Color Safe(5php)"}.entries);

  //oth names
  mapOthNames.addEntries({menuOthWash: "Wash"}.entries);
  mapOthNames.addEntries({menuOthDry: "Dry"}.entries);
  mapOthNames.addEntries({menuOthXD: "Extra Dry"}.entries);
  mapOthNames.addEntries({menuOthXW: "Extra Wash"}.entries);
  mapOthNames.addEntries({menuOthXR: "Extra Rinse"}.entries);

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
  selectedSupVar = listDetItems[0];
  gselectedItemModel = listOthItems[1];
  listSuppItems.addAll(listDetItems);
  listSuppItems.addAll(listFabItems);
  listSuppItems.addAll(listBleItems);

  resetSHGlobalVar();
}

Future<void> checkInternet(BuildContext context) async {
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

//var mapEmpId = {"0550", "Jeng", "0808", "Abi", "0413", "Ket", "0316", "DonP"};

Map<String, String> mapEmpId = {
  '0550': 'Jeng',
  '0808': 'Abi',
  '1313': 'Ket',
  '1616': 'DonP'
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
  String thisCustomerName = "no data";
  customerOptionsFromVariable.forEach((thisData) {
    if (thisData.customerId == int.parse(customerId)) {
      thisCustomerName = thisData.name;
    }
  });

  return thisCustomerName;
}

String getItemName(int itemId) {
  String thisItemName = "no data";
  listSuppItems.forEach((thisData) {
    if (thisData.itemId == itemId) {
      thisItemName = "${thisData.itemGroup} - ${thisData.itemName}";
    }
  });

  return thisItemName;
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
      createdBy: "",
      currentEmpId: "",
      customerId: 0,
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

void resetSHGlobalVar() {
  suppliesModelHistGlobal = SuppliesModelHist(
      docId: selectedSupVar.docId,
      itemId: selectedSupVar.itemId,
      counter: 0,
      currentStocks: 0,
      stocksAlert: 0,
      logDate: Timestamp.now());
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

Widget createNewJOQVar(BuildContext context) {
  return MaterialButton(
    onPressed: () {
      if (autocompleteSelected.customerId == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cannot save, please add name in loyalty records first.')),
        );
        // } else if (_formKey.currentState!.validate()) {
      } else if (true) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data')),
        );

        //pop box
        Navigator.pop(context);
        jobsOnQueueModelGlobal.dateQ = Timestamp.now();
        jobsOnQueueModelGlobal.customerId = autocompleteSelected.customerId;
        jobsOnQueueModelGlobal.finalKilo = 0;
        jobsOnQueueModelGlobal.finalLoad = 0;
        jobsOnQueueModelGlobal.finalPrice = 0;
        jobsOnQueueModelGlobal.finalOthersPrice = 0;
        jobsOnQueueModelGlobal.paymentReceivedBy =
            (jobsOnQueueModelGlobal.unpaid ? "" : empIdGlobal);
        jobsOnQueueModelGlobal.paidD = (jobsOnQueueModelGlobal.unpaid
            ? Timestamp.fromDate(DateTime(2000))
            : Timestamp.now());
        jobsOnQueueModelGlobal.remarks = remarksControllerVar.text;
        jobsOnQueueModelGlobal.needOn = Timestamp.fromDate(dNeedOnVar);

        insertDataJobsOnQueueVar(jobsOnQueueModelGlobal);
      }
    },
    color: cButtons,
    child: const Text("Save Queue"),
  );
}

Widget createNewSuppVar(BuildContext context, SuppliesModelHist sMH) {
  return MaterialButton(
    onPressed: () async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );

      if (await insertDataSuppliesHistVar(sMH)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Success')),
        );
        print("Sucess");
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot Save')),
        );
        print("Failed");
      }
      //pop box
    },
    color: cButtons,
    child: const Text("Save Supplies"),
  );
}

Widget moveToJOGVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () async {
      if (await onGoingFull()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot proceed, on going is full(25).')),
        );
        // } else if (_formKey.currentState!.validate()) {
      } else if (true) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data')),
        );

        //pop box
        Navigator.pop(context);

        jOQM.riderPickup = false;
        jOQM.forSorting = false;
        jOQM.waiting = true;
        insertDataJobsOnGoingVar(jOQM, lOIM);
        //deleteJOQVar(jOQM.docId, lOIM);
        autoNumber = await getNumberAutoVarV2();
        finalNumberAutoVarV2();
        showMessage(context, "Move to OnGoing", "Added to #$autoNumber");
      }
    },
    color: cButtons,
    child: const Text("Move To OnGoing"),
  );
}

Widget moveToJDVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );

      //pop box
      Navigator.pop(context);

      jOQM.riderPickup = false;
      jOQM.forSorting = false;
      jOQM.waiting = false;
      jOQM.washing = false;
      jOQM.drying = false;
      jOQM.folding = false;
      jOQM.waitCustomerPickup = true;
      insertDataJobsDoneVar(jOQM, lOIM);
      //deleteJOQVar(jOQM.docId, lOIM);
      showMessage(context, "Move to Jobs Done", "Done.");
    },
    color: cButtons,
    child: const Text("Move To Jobs Done"),
  );
}

Widget createNewJDVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () {
      if (jOQM.customerId == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cannot save, please add name in loyalty records first.')),
        );
        // } else if (_formKey.currentState!.validate()) {
      } else if (true) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data')),
        );

        //pop box
        Navigator.pop(context);

        // insertDataJobsOnGoingVar(jOQM, lOIM);
        // deleteJOQVar(jOQM.docId, lOIM);
      }
    },
    color: cButtons,
    child: const Text("Jobs Done"),
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
  resetJOQMGlobalVar();
}

//insert new Supplies
// void insertDataSuppliesHistVar() {
Future<bool> insertDataSuppliesHistVar(SuppliesModelHist sMH) async {
  DatabaseSuppliesHist databaseSuppliesHist = DatabaseSuppliesHist();

  sMH.counter = int.parse(counterControllerVar.text);
  sMH.currentStocks = 50;
  sMH.stocksAlert = 10;
  sMH.logDate = Timestamp.now();

  return await databaseSuppliesHist.addSuppliesHist(sMH);

  // if (await databaseSuppliesHist.addSuppliesHist(suppliesModelHistGlobal)) {
  //   return true;
  // } else {
  //   return false;
  // }
}

//insert new OnGoing
void insertDataJobsOnGoingVar(
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  databaseJobsOnGoing.addJobsOnGoing(jOQM, lOIM);
  resetJOQMGlobalVar();
}

//insert new Done
void insertDataJobsDoneVar(JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
  databaseJobsDone.addJobsDone(jOQM, lOIM);
  resetJOQMGlobalVar();
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
        AutoCompleteCustomer(),
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

Container conQueueStatVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sort"),
        Switch.adaptive(
          value: jOQM.riderPickup,
          onChanged: (bool value) {
            setState(() {
              jOQM.riderPickup = value;
              if (jOQM.riderPickup) {
                jOQM.forSorting = false;
              } else {
                jOQM.forSorting = true;
              }
            });
          },
        ),
        Text("RiderPickup"),
      ],
    ),
  );
}

Container conOnGoingStatVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            value: jOQM.waiting,
            onChanged: (val) {
              jOQM.waiting = true;
              jOQM.washing = false;
              jOQM.drying = false;
              jOQM.folding = false;

              setState(
                () {
                  jOQM.waiting;
                  jOQM.washing;
                  jOQM.drying;
                  jOQM.folding;
                },
              );
            }),
        Text("Wait"),
        SizedBox(
          width: 5,
        ),
        Checkbox(
            value: jOQM.washing,
            onChanged: (val) {
              jOQM.waiting = false;
              jOQM.washing = true;
              jOQM.drying = false;
              jOQM.folding = false;

              setState(
                () {
                  jOQM.waiting;
                  jOQM.washing;
                  jOQM.drying;
                  jOQM.folding;
                },
              );
            }),
        Text("Wash"),
        SizedBox(
          width: 5,
        ),
        Checkbox(
            value: jOQM.drying,
            onChanged: (val) {
              jOQM.waiting = false;
              jOQM.washing = false;
              jOQM.drying = true;
              jOQM.folding = false;

              setState(
                () {
                  jOQM.waiting;
                  jOQM.washing;
                  jOQM.drying;
                  jOQM.folding;
                },
              );
            }),
        Text("Dry"),
        SizedBox(
          width: 5,
        ),
        Checkbox(
            value: jOQM.folding,
            onChanged: (val) {
              jOQM.waiting = false;
              jOQM.washing = false;
              jOQM.drying = false;
              jOQM.folding = true;

              setState(
                () {
                  jOQM.waiting;
                  jOQM.washing;
                  jOQM.drying;
                  jOQM.folding;
                },
              );
            }),
        Text("Fold"),
      ],
    ),
  );
}

Container conDoneStatVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            value: jOQM.waitCustomerPickup,
            onChanged: (val) {
              jOQM.waitCustomerPickup = true;
              jOQM.waitRiderDelivery = false;
              jOQM.nasaCustomerNa = false;

              setState(
                () {
                  jOQM.waitCustomerPickup;
                  jOQM.waitRiderDelivery;
                  jOQM.nasaCustomerNa;
                },
              );
            }),
        Text("Customer Pickup"),
        SizedBox(
          width: 5,
        ),
        Checkbox(
            value: jOQM.waitRiderDelivery,
            onChanged: (val) {
              jOQM.waitCustomerPickup = false;
              jOQM.waitRiderDelivery = true;
              jOQM.nasaCustomerNa = false;

              setState(
                () {
                  jOQM.waitCustomerPickup;
                  jOQM.waitRiderDelivery;
                  jOQM.nasaCustomerNa;
                },
              );
            }),
        Text("For Delivery"),
        SizedBox(
          width: 5,
        ),
        Checkbox(
            value: jOQM.nasaCustomerNa,
            onChanged: (val) {
              jOQM.waitCustomerPickup = false;
              jOQM.waitRiderDelivery = false;
              jOQM.nasaCustomerNa = true;

              setState(
                () {
                  jOQM.waitCustomerPickup;
                  jOQM.waitRiderDelivery;
                  jOQM.nasaCustomerNa;
                },
              );
            }),
        Text("Nasa Customer"),
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
                              itemId: menuFabWKL24mlDVal,
                              itemGroup: groupFab,
                              itemName: "WKL Fabcon 24ml",
                              itemPrice: 8));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;

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
                              itemGroup: groupOth,
                              itemName: "Extra Dry",
                              itemPrice: 15));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;

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
                              itemGroup: groupOth,
                              itemName: "Extra Wash",
                              itemPrice: 15));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;

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
                              itemGroup: groupOth,
                              itemName: "Extra Rinse",
                              itemPrice: 15));
                          bViewMoreOptions = true;

                          jOQM.initialOthersPrice =
                              jOQM.initialOthersPrice + 15;

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
                          itemGroup: groupOth,
                          itemName: "Extra Dry",
                          itemPrice: 15));
                      bViewAddOnDtlOnGoing = true;

                      jOQM.initialOthersPrice = jOQM.initialOthersPrice + 15;

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

Container conPaymentVar(Function setState, JobsOnQueueModel jOQM) {
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
                  resetPaymentQueueBool(jOQM);
                  if (val!) {
                    setState(
                      () {
                        jOQM.unpaid = val;
                      },
                    );
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
                  resetPaymentQueueBool(jOQM);
                  if (val!) {
                    setState(
                      () {
                        jOQM.paidcash = val;
                      },
                    );
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
                  resetPaymentQueueBool(jOQM);
                  if (val!) {
                    setState(
                      () {
                        jOQM.paidgcash = val;
                      },
                    );
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
        jOQM.remarks = remarksControllerVar.text;
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
  if (jOQM.riderPickup) {
    return cRiderPickup;
  } else if (jOQM.forSorting) {
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
  } else {
    return cRiderOnDelivery;
  }
  ;
}

//Display Queue Tables
Color getCOlorSuppliesHistoryVar(SuppliesModelHist sMH) {
  if (sMH.currentStocks <= sMH.stocksAlert) {
    return cRiderPickup;
  } else {
    return cWaiting;
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

Future<void> moveUpVar(int jobsId) async {
  bool bOnlyOne = false;

  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();

  if (querySnapshots.size == 1) {
    bOnlyOne = true;
  }
  for (var doc in querySnapshots.docs) {
    if (bOnlyOne && doc['D30_JobsId'] == 0) {
      await doc.reference.update({
        'D30_JobsId': 1,
      });
    } else {
      if (jobsId == 1) {
        //updatePrevOne25(jobsId);
        //break;
        if (doc['D30_JobsId'] == 1) {
          await doc.reference.update({
            'D30_JobsId': 25,
          });
        }
        if (doc['D30_JobsId'] == 25) {
          await doc.reference.update({
            'D30_JobsId': 1,
          });
        }
      } else {
        if ((jobsId - 1) == doc['D30_JobsId']) {
          await doc.reference.update({
            'D30_JobsId': jobsId,
          });
        } else if ((jobsId) == doc['D30_JobsId']) {
          await doc.reference.update({
            'D30_JobsId': jobsId - 1,
          });
        }
      }
    }
  }
}

Future<bool> onGoingFull() async {
  var colAuto = FirebaseFirestore.instance.collection('JobsOnGoing');
  var queryAuto = await colAuto.get();
  if (queryAuto.size == 25) {
    return true;
  }
  return false;
}

Future<int> getNumberAutoVarV2() async {
  var colAuto = FirebaseFirestore.instance
      .collection('JobsOnGoing')
      .orderBy('D30_JobsId');
  var queryAuto = await colAuto.get();
  int nFirstLowest = 0,
      nSecondLowest = 0,
      nPrevJobsIdFetch = 0,
      nCurrJobsIdFetch = 0;
  for (var doc in queryAuto.docs) {
    if (nCurrJobsIdFetch != doc['D30_JobsId']) {
      nPrevJobsIdFetch = nCurrJobsIdFetch;
      nCurrJobsIdFetch = doc['D30_JobsId'];
    }

    if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
        nFirstLowest != 0 &&
        nSecondLowest == 0) {
      nSecondLowest = nPrevJobsIdFetch + 1;
    }

    if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
        nFirstLowest == 0 &&
        nSecondLowest == 0) {
      nFirstLowest = nPrevJobsIdFetch + 1;
    }

    print("nFirstLowest=$nFirstLowest nSecondLowest=$nSecondLowest");

    //final
    if (doc['D30_JobsId'] == 99) {
      if (nSecondLowest == 0 || nSecondLowest > 25) {
        return nFirstLowest;
      } else {
        return nSecondLowest;
      }
    }
  }
  return 99;
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

Future<void> finalNumberAutoVarV2() async {
  var colAuto = FirebaseFirestore.instance
      .collection('JobsOnGoing')
      .orderBy('D30_JobsId', descending: true);
  var queryAuto = await colAuto.get();
  for (var doc in queryAuto.docs) {
    if (doc['D30_JobsId'] == 99) {
      await doc.reference.update({
        'D30_JobsId': autoNumber,
      });
    }
    break;
  }
}

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
                                    : (jOQM.riderPickup
                                        ? "Rider Pickup"
                                        : (jOQM.waitCustomerPickup
                                            ? "Wait Customer"
                                            : (jOQM.waitRiderDelivery
                                                ? "Deliver to Customer"
                                                : (jOQM.nasaCustomerNa
                                                    ? "Nasa Customer Na"
                                                    : "N/A"))))))))),
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

//Display
Container conDisplaySuppliesHistoryVar(
  BuildContext context,
  SuppliesModelHist sMH,
) {
  return Container(
    height: 20,
    color: getCOlorSuppliesHistoryVar(sMH),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2,
              ),
              Text(
                "  ${getItemName(sMH.itemId)} - (${sMH.counter}/${sMH.currentStocks})",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

//alterjobsonqueue
void showAlterJobsOnQueueVar(
  BuildContext context,
  String docId,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) async {
  dNeedOnVar = jOQM.needOn.toDate();
  bViewMoreOptions = false;
  if (lOIM.isNotEmpty) {
    bViewMoreOptions = true;
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "Change Jobs On Queue",
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
                    conCustomerName(context, setState, jOQM),
                    conQueueStatVar(setState, jOQM),
                    conOrderModeVar(setState, jOQM, decoAmber()),
                    conTotalPriceVar(setState, jOQM),
                    conBasketVar(setState, jOQM, decoAmber()),
                    conBagVar(setState, jOQM, decoAmber()),
                    conPaymentVar(setState, jOQM),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsOnQueue",
                        jOQMNoChange),
                    visExtraOnQueueVar(context, setState, jOQM, lOIM),
                    visFoldVar(setState, jOQM),
                    visMixVar(setState, jOQM),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //move to ongoing
            moveToJOGVar(context, docId, jOQM, lOIM),

            //cancel button
            ///cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJOQVar(context, docId, jOQM, lOIM),
          ],
        );
      });
    },
  );
}

//alterjobsongoing
void showAlterJobsOnGoingVar(
  BuildContext context,
  Function setState,
  String docId,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) async {
  bViewMoreOptions = false;
  bViewAddOnDtlOnGoing = false;
  if (lOIM.isNotEmpty) {
    bViewMoreOptions = true;
  }
  dNeedOnVar = jOQM.needOn.toDate();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "New Laundry ${DateTime.now().toString().substring(5, 13)}",
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
                    conCustomerName(context, setState, jOQM),
                    conOnGoingStatVar(setState, jOQM),
                    //conQueueStatVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child:
                            conOrderModeVar(setState, jOQM, decoLightBlue())),
                    conTotalPriceVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBasketVar(setState, jOQM, decoLightBlue())),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBagVar(setState, jOQM, decoLightBlue())),
                    conPaymentVar(setState, jOQM),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsOnGoing",
                        jOQMNoChange),
                    visExtraOnGoingVar(context, setState, jOQM, lOIM),
                    visFoldVar(setState, jOQM),
                    visMixVar(setState, jOQM),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //move to ongoing
            moveToJDVar(context, docId, jOQM, lOIM),

            //cancel button
            //cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJOGVar(context, docId, jOQM, lOIM, jOQMNoChange),

            //move to ongoing
            // moveToJOGVar(
            //     context,
            //     docId,
            //     jOQM,
            //     lOIM),
          ],
        );
      });
    },
  );
}

//alterjobsdone
void showAlterJobsDoneVar(
  BuildContext context,
  Function setState,
  String docId,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) async {
  bViewMoreOptions = false;
  bViewAddOnDtlOnGoing = false;
  if (lOIM.isNotEmpty) {
    bViewMoreOptions = true;
  }
  dNeedOnVar = jOQM.needOn.toDate();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "New Laundry ${DateTime.now().toString().substring(5, 13)}",
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
                    conCustomerName(context, setState, jOQM),
                    conDoneStatVar(setState, jOQM),
                    //conQueueStatVar(setState, jOQM),
                    // Visibility(
                    //     visible: bViewMoreOptions,
                    //     child:
                    //         conOrderModeVar(setState, jOQM, decoLightBlue())),
                    conTotalPriceVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBasketVar(setState, jOQM, decoLightBlue())),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBagVar(setState, jOQM, decoLightBlue())),
                    conPaymentVar(setState, jOQM),
                    Visibility(
                        visible: (jOQM.paidgcash ? true : false),
                        child: conGCashVerified(setState, jOQM)),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsDone",
                        jOQMNoChange),
                    // visExtraOnGoingVar(context, setState, jOQM, lOIM),
                    // visFoldVar(setState, jOQM),
                    // visMixVar(setState, jOQM),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //cancel button
            //cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJDVar(context, docId, jOQM, lOIM, jOQMNoChange),
          ],
        );
      });
    },
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

void showMessageSwapComplete(
    BuildContext context, String title, String message) {
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
            closeButton2popVar(context),
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

void showMessageOptionChangeJobId(
    BuildContext context, String title, String message, JobsOnQueueModel jOQM) {
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
            changeButtonJobsIdVar(context, jOQM),
          ],
        );
      });
    },
  );
}

Widget updateButtonJOQVar(BuildContext context, String docId,
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () {
      if (bDelAddOnsVar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Processing Data, you may need to login again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed delete add ons, please delete again.')),
        );
      }

      bViewMoreOptions = false;

      //pop box
      Navigator.pop(context);
      updateJOQMVar(docId, jOQM, lOIM);

      //listAddOnItemsGlobal.clear();
      resetJOQMGlobalVar();

      if (lOIM.isNotEmpty) {
        bViewMoreOptions = true;
        Navigator.pop(context);
      }

      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => MyQueue(empidGlobal)));
    },
    color: cButtons,
    child: const Text("Update"),
  );
}

Widget updateButtonJOGVar(
    BuildContext context,
    String docId,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    JobsOnQueueModel jOQMNoChange) {
  return MaterialButton(
    onPressed: () {
      if (bDelAddOnsVar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Processing Data, you may need to login again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed delete add ons, please delete again.')),
        );
      }

      bViewMoreOptions = false;
      bViewAddOnDtlOnGoing = false;

      //pop box
      Navigator.pop(context);
      updateJOGMVar(docId, jOQM, lOIM);
      if (lOIM.isNotEmpty) {
        bViewMoreOptions = true;

        Navigator.pop(context);
      }
      //jOQMNoChange = jOQM;
      resetJOQMNoChangeToJOQM(jOQMNoChange, jOQM);

      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => MyQueue(jOQM.empidGlobal)));
    },
    color: cButtons,
    child: const Text("Update"),
  );
}

Widget updateButtonJDVar(
    BuildContext context,
    String docId,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    JobsOnQueueModel jOQMNoChange) {
  return MaterialButton(
    onPressed: () {
      if (bDelAddOnsVar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed delete add ons, please delete again.')),
        );
      }

      bViewMoreOptions = false;
      bViewAddOnDtlOnGoing = false;

      //pop box
      Navigator.pop(context);
      updateJDMVar(docId, jOQM, lOIM);
      if (lOIM.isNotEmpty) {
        bViewMoreOptions = true;

        Navigator.pop(context);
      }
      //jOQMNoChange = jOQM;
      resetJOQMNoChangeToJOQM(jOQMNoChange, jOQM);

      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => MyQueue(jOQM.empidGlobal)));
    },
    color: cButtons,
    child: const Text("Update"),
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
      } else {
        updateJOGMVar(jOQM.docId, jOQMNoChange, lOIM);
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

Widget changeButtonJobsIdVar(
  BuildContext context,
  JobsOnQueueModel jOQM,
) {
  return MaterialButton(
    onPressed: () {
      moveUpVar(jOQM.jobsId);
      Navigator.pop(context); //need to relogin
    },
    color: cButtons,
    child: const Text("Move Up"),
  );
}

void updateJOQMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsOnQueue.updateJobsOnQueue(docId, jOQM, lOIM);
}

void updateJOGMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsOnGoing.updateJobsOnGoing(docId, jOQM, lOIM);
}

void updateJDMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsDone.updateJobsDone(docId, jOQM, lOIM);
}

void deleteJOQVar(String docId, List<OtherItemModel> lOIM) {
  DatabaseOtherItems databaseOtherItems =
      DatabaseOtherItems("JobsOnQueue", docId);
  // DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue =
  //     DatabaseOtherItemsOnQueue(docId);

  lOIM.forEach((aOIG) {
    print("delete for ongoing docid=${aOIG.docId}");
    if (aOIG.docId != "") {
      databaseOtherItems.deleteOtheritems(aOIG.docId);
      // bDelAddOnsVar = true;
    } else {
      //need to relogin to delete
      // bDelAddOnsVar = false;
    }
  });

  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  databaseJobsOnQueue.deleteJobsOnQueue(docId);
}

void deleteJOGVar(String docId, List<OtherItemModel> lOIM) {
  DatabaseOtherItems databaseOtherItems =
      DatabaseOtherItems("JobsOnGoing", docId);
  // DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue =
  //     DatabaseOtherItemsOnQueue(docId);

  lOIM.forEach((aOIG) {
    print("delete for ongoing docid=${aOIG.docId}");
    if (aOIG.docId != "") {
      databaseOtherItems.deleteOtheritems(aOIG.docId);
      // bDelAddOnsVar = true;
    } else {
      //need to relogin to delete
      // bDelAddOnsVar = false;
    }
  });

  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  databaseJobsOnGoing.deleteJobsOnGoing(docId);
}

Future<bool> canSwapVar(String destinationJobsId) async {
  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();
  for (var doc in querySnapshots.docs) {
    if (destinationJobsId == "${doc['D30_JobsId']}") {
      if (!doc['D3_Waiting']) {
        return false;
      }
    }
  }
  //can swap if waiting or no data
  return true;
}

void updateSwapVar(String sourceJobsId, String destinationJobsId) async {
  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();
  for (var doc in querySnapshots.docs) {
    if (destinationJobsId == "${doc['D30_JobsId']}") {
      await doc.reference.update({
        'D30_JobsId': int.parse(sourceJobsId.replaceAll("#", "")),
      }).catchError((error) => print("Failed : $error"));
      ;
    } else if (sourceJobsId == "${doc['D30_JobsId']}") {
      await doc.reference.update({
        'D30_JobsId': int.parse(destinationJobsId.replaceAll("#", "")),
      }).catchError((error) => print("Failed : $error"));
    }
  }
}

void alterNumberMobileVar(BuildContext context, JobsOnQueueModel jOQM) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Swapping no. #${jOQM.jobsId}",
        style: TextStyle(backgroundColor: Colors.green[50]),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 5,
                ),
                DropdownButton<String>(
                  hint: Text("Select"),
                  value: selectedNumberVar,
                  onChanged: (val) {
                    setState(() {
                      selectedNumberVar = val!;
                    });
                  },
                  items: completeListNumbering
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("#$value"),
                    );
                  }).toList(),
                ),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.amberAccent)),
                    onPressed: () async {
                      if (await canSwapVar(selectedNumberVar)) {
                        updateSwapVar("${jOQM.jobsId}", selectedNumberVar);
                        showMessageSwapComplete(
                            context, "Success", "Swap complete.");
                      } else {
                        showMessage(context, "Failed at # $selectedNumberVar",
                            "Cannot swap to Washing/Drying/Folding. Choose other number");
                      }
                    },
                    child: Text(
                        "Click here to swap number #${jOQM.jobsId} to #$selectedNumberVar")),
              ],
            ),
          );
        }),
      ),
      actions: [
        //cancel button
        closeButtonVar(context),

        //swap jobs id
        //_swapJobsId("#$jobsId", _selectedNumber)
      ],
    ),
  );
}
