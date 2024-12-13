import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';

bool showDet = false, showFab = false, showBle = false, showOth = false;

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

//new start
//det
List<OtherItemModel> listDetItems = [];
List<OtherItemModel> listFabItems = [];
List<OtherItemModel> listBleItems = [];
List<OtherItemModel> listOthItems = [];
List<OtherItemModel> listAddOnItems = [];

const String groupDet = "Det",
    groupFab = "Fab",
    groupBle = "Ble",
    groupOth = "Oth";
//new end

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
const int menuOthWash = 401, menuOthDry = 402;

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
Map<int, String> mapPaymentStat = {};
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

final List<String> finListNumbering = [
  "#1",
  "#2",
  "#3",
  "#4",
  "#5",
  "#6",
  "#7",
  "#8",
  "#9",
  "#10",
  "#11",
  "#12",
  "#13",
  "#14",
  "#15",
  "#16",
  "#17",
  "#18",
  "#19",
  "#20",
  "#21",
  "#22",
  "#23",
  "#24",
  "#25"
];

const mobileWidth = 600;

void putEntries() {
  //detItems
  listDetItems.add(OtherItemModel(
      itemId: menuDetBreezeDVal,
      itemGroup: groupDet,
      itemName: "Breeze",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      itemId: menuDetArielDVal,
      itemGroup: groupDet,
      itemName: "Ariel Twinpack",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      itemId: menuDetTideDVal,
      itemGroup: groupDet,
      itemName: "Tide",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      itemId: menuDetWingsBlueDVal,
      itemGroup: groupDet,
      itemName: "Wings Blue",
      itemPrice: 15));
  listDetItems.add(OtherItemModel(
      itemId: menuDetWingsRedDVal,
      itemGroup: groupDet,
      itemName: "Wings Red",
      itemPrice: 8));
  listDetItems.add(OtherItemModel(
      itemId: menuDetPowerCleanDVal,
      itemGroup: groupDet,
      itemName: "WKL",
      itemPrice: 8));
  listDetItems.add(OtherItemModel(
      itemId: menuDetSurfDVal,
      itemGroup: groupDet,
      itemName: "Surf",
      itemPrice: 10));
  listDetItems.add(OtherItemModel(
      itemId: menuDetKlinDVal,
      itemGroup: groupDet,
      itemName: "Klin Twinpack",
      itemPrice: 15));
  //fab items
  listFabItems.add(OtherItemModel(
      itemId: menuFabSurf24mlDVal,
      itemGroup: groupFab,
      itemName: "Surf 24ml",
      itemPrice: 8));
  listFabItems.add(OtherItemModel(
      itemId: menuFabDowny24mlDVal,
      itemGroup: groupFab,
      itemName: "Downy 24ml",
      itemPrice: 8));
  listFabItems.add(OtherItemModel(
      itemId: menuFabDownyTripidDVal,
      itemGroup: groupFab,
      itemName: "Downy Tripid",
      itemPrice: 17));
  listFabItems.add(OtherItemModel(
      itemId: menuFabDowny36mlDVal,
      itemGroup: groupFab,
      itemName: "Downy 36ml",
      itemPrice: 10));
  listFabItems.add(OtherItemModel(
      itemId: menuFabSurfTripidDVal,
      itemGroup: groupFab,
      itemName: "Surf Tripid",
      itemPrice: 17));
  listFabItems.add(OtherItemModel(
      itemId: menuFabWKL24mlDVal,
      itemGroup: groupFab,
      itemName: "WKL Fabcon 24ml",
      itemPrice: 8));
  //bel items
  listBleItems.add(OtherItemModel(
      itemId: menuBleColorSafeDVal,
      itemGroup: groupBle,
      itemName: "Color Safe",
      itemPrice: 5));
  //oth items
  listOthItems.add(OtherItemModel(
      itemId: menuOthWash,
      itemGroup: groupOth,
      itemName: "Wash",
      itemPrice: 49));

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

  //paymentStat
  mapPaymentStat.addEntries({unpaid: "Unpaid"}.entries);
  mapPaymentStat.addEntries({paidCash: "PaidCash"}.entries);
  mapPaymentStat.addEntries({paidGCash: "PaidGCash"}.entries);
  mapPaymentStat.addEntries({waitGCash: "WaitGCash"}.entries);
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
      return "$x($y)=Php $z";
    }
  }
}

String kiloDisplay(int kilo) {
  if (kilo % 8 == 0) {
    return "$kilo.0";
  } else {
    return "${(kilo - 1)}.1 - $kilo.0";
  }
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

Color borderColor() {
  return Colors.black54;
}

Color? containerQueColor() {
  return Colors.amber[50];
}

BoxDecoration containerQueBoxDecoration() {
  return BoxDecoration(
      color: containerQueColor(),
      border: Border.all(color: borderColor(), width: 2.0));
}

Color? containerSayoSabonColor() {
  return Colors.lightBlue[100];
}

BoxDecoration containerSayoSabonBoxDecoration() {
  return BoxDecoration(
      color: containerSayoSabonColor(),
      border: Border.all(color: borderColor(), width: 2.0));
}

int iPriceDivider(bool bRegularSabon) {
  if (bRegularSabon) {
    return 155;
  } else {
    return 125;
  }
}
