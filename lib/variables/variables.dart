import 'package:flutter/material.dart';

bool showDet = false, showFab = false, showBle = false, showOth = false;

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

//det
Map<int, String> mapDetNames = {};
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
const int menuOthPlasticDVal = 401, menuOthScatchTapeDVal = 402;

class OthItems {
  int menuDVal;
  String menuName;
  OthItems({
    required this.menuDVal,
    required this.menuName,
  });
  static OthItems fromJson(json) => OthItems(
        menuDVal: json['menuDVal'],
        menuName: json['menuName'],
      );
}

List<OthItems> othItems = [];

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
  //det names
  mapDetNames.addEntries({menuDetBreezeDVal: "Breeze(15php)"}.entries);
  mapDetNames.addEntries({menuDetArielDVal: "Ariel Twinpack(15php)"}.entries);
  mapDetNames.addEntries({menuDetTideDVal: "Tide(15php)"}.entries);
  mapDetNames.addEntries({menuDetWingsBlueDVal: "Wings Blue(8php)"}.entries);
  mapDetNames.addEntries({menuDetWingsRedDVal: "Wings Red(8php)"}.entries);
  mapDetNames.addEntries({menuDetPowerCleanDVal: "Power CLean"}.entries);
  mapDetNames.addEntries({menuDetSurfDVal: "Surf(10php)"}.entries);
  mapDetNames.addEntries({menuDetKlinDVal: "Klin Twinpack(15php)"}.entries);

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
  mapBleNames.addEntries({menuBleOriginalDVal: "Bleach Original"}.entries);
  mapBleNames.addEntries({menuBleColorSafeDVal: "Color Safe"}.entries);

  //oth names
  mapOthNames.addEntries({menuOthPlasticDVal: "Plastic"}.entries);
  mapOthNames.addEntries({menuOthScatchTapeDVal: "Scatch Tape"}.entries);
}

//var mapEmpId = {"0550", "Jeng", "0808", "Abi", "0413", "Ket", "0316", "DonP"};

Map<String, String> mapEmpId = {
  '0550': 'Jeng',
  '0808': 'Abi',
  '1313': 'Ket',
  '1616': 'DonP'
};

String autoPriceDisplay(int price) {
  int x = 0, y = 0, z = 0;
  if (price % 155 == 0) {
    return "Php $price";
  } else {
    if (price ~/ 155 == 1) {
      return "Php $price";
    } else {
      x = price ~/ 155;
      x--;
      x = x * 155;
      y = price % 155;
      y = y + 155;
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
