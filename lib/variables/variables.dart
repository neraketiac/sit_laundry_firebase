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
const int menuFabSurf24mlDVal = 201, menuFabDowny24mlDVal = 202, menuFabDownyTripidDVal = 203, menuFabDowny36mlDVal = 204, menuFabSurfTripidDVal = 205, menuFabWKL24mlDVal = 206;

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
  mapFabNames.addEntries({menuFabDownyTripidDVal: "Downy Tripid(17php)"}.entries);
  mapFabNames.addEntries({menuFabDowny36mlDVal: "Downy 36ml(10php)"}.entries);
  mapFabNames.addEntries({menuFabSurfTripidDVal: "Surf Tripid(17php)"}.entries);
  mapFabNames.addEntries({menuFabWKL24mlDVal: "WKL Fabcon 24ml (8php)"}.entries);

  //det names
  mapBleNames.addEntries({menuBleOriginalDVal: "Bleach Original"}.entries);
  mapBleNames.addEntries({menuBleColorSafeDVal: "Color Safe"}.entries);

  //oth names
  mapOthNames.addEntries({menuOthPlasticDVal: "Plastic"}.entries);
  mapOthNames.addEntries({menuOthScatchTapeDVal: "Scatch Tape"}.entries);

}
