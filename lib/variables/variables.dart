import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/loyalty_admin.dart';
import 'package:laundry_firebase/services/database_jobsonqueue.dart';

bool showDet = false, showFab = false, showBle = false, showOth = false;

late JobsOnQueueModel jobsOnQueueModelGlobal;

//general
const int menuDetDVal = 1, menuFabDVal = 2, menuBleDVal = 3, menuOthDVal = 4;

//new start
//det
List<OtherItemModel> listDetItems = [];
List<OtherItemModel> listFabItems = [];
List<OtherItemModel> listBleItems = [];
List<OtherItemModel> listOthItems = [];
List<OtherItemModel> listAddOnItems = [];

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

bool bViewMoreOptions = false;

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
    selectedOthVar;
// int iBasketVar = 0, iBagVar = 0;
bool bUnpaidVar = true, bPaidCashVar = false, bPaidGCashVar = false;
// bool bMixVar = true, bFoldVar = true;
TextEditingController remarksControllerVar = TextEditingController();
DateTime dNeedOnVar = DateTime.now().add(Duration(minutes: 210));
// Timestamp tNeedOnVar = Timestamp.now();

void putEntries() {
  resetJobsOnQueueModelVar();
  fetchUsers();

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
  listOthItems.add(OtherItemModel(
      itemId: menuOthWash,
      itemGroup: groupOth,
      itemName: "2Wash 1Dry(Regular)",
      itemPrice: 195));
  listOthItems.add(OtherItemModel(
      itemId: menuOthWash,
      itemGroup: groupOth,
      itemName: "2Wash 1Dry(SayoSabon)",
      itemPrice: 165));

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

  //dropdown first value
  selectedDetVar = listDetItems[0];
  selectedFabVar = listFabItems[0];
  selectedBleVar = listBleItems[0];
  selectedOthVar = listOthItems[0];
  gselectedItemModel = listOthItems[1];
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

//jobsonqueue
void showJobsOnQueueVar(BuildContext context) {
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
                    conEnterCustomer(context, setState),
                    conQueueStat(setState),
                    conOrderMode(setState),
                    visAddOn(setState),
                    conTotalPrice(setState),
                    conBasket(setState),
                    conBag(setState),
                    conPayment(setState),
                    conRemarks(setState),
                    conMoreOptions(setState),
                    visFold(setState),
                    visMix(setState),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //cancel button
            cancelButtonVar(context),

            //save button
            createNewJOQVar(context),
          ],
        );
      });
    },
  );
}

void allCardsVar(BuildContext context) {
  Navigator.pop(context);
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const LoyaltyAdmin()));
}

void resetJobsOnQueueModelVar() {
  jobsOnQueueModelGlobal = JobsOnQueueModel(
      dateQ: Timestamp.now(),
      forSorting: true,
      riderPickup: false,
      createdBy: "",
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
      paymentReceivedBy: "",
      dateO: Timestamp.fromDate(DateTime(2000)),
      paidD: Timestamp.fromDate(DateTime(2000)),
      jobsId: 0,
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
            (jobsOnQueueModelGlobal.unpaid
                ? ""
                : jobsOnQueueModelGlobal.createdBy);
        jobsOnQueueModelGlobal.paidD = (jobsOnQueueModelGlobal.unpaid
            ? Timestamp.fromDate(DateTime(2000))
            : Timestamp.now());
        jobsOnQueueModelGlobal.remarks = remarksControllerVar.text;
        jobsOnQueueModelGlobal.needOn = Timestamp.fromDate(dNeedOnVar);

        insertDataJobsOnQueueVar(jobsOnQueueModelGlobal);
      }
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

//insert new
void insertDataJobsOnQueueVar(JobsOnQueueModel jOQM) {
  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  databaseJobsOnQueue.addJobsOnQueue(jOQM, listAddOnItems);
  resetJobsOnQueueModelVar();
}

//displays in Popup
Container conEnterCustomer(BuildContext context, Function setState) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
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
    decoration: containerQueBoxDecoration(),
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

Container conQueueStat(Function setState) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sort"),
        Switch.adaptive(
          value: jobsOnQueueModelGlobal.riderPickup,
          onChanged: (bool value) {
            setState(() {
              jobsOnQueueModelGlobal.riderPickup = value;
              if (jobsOnQueueModelGlobal.riderPickup) {
                jobsOnQueueModelGlobal.forSorting = false;
              } else {
                jobsOnQueueModelGlobal.forSorting = true;
              }
            });
          },
        ),
        Text("RiderPickup"),
      ],
    ),
  );
}

Container conOrderMode(Function setState) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
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
                    value: jobsOnQueueModelGlobal.regular,
                    onChanged: (val) {
                      jobsOnQueueModelGlobal =
                          resetRegular(jobsOnQueueModelGlobal);

                      if (val!) {
                        setState(
                          () {
                            jobsOnQueueModelGlobal.regular = val;
                          },
                        );
                      }

                      jobsOnQueueModelGlobal.initialKilo = 8;
                      jobsOnQueueModelGlobal.initialPrice =
                          (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                              iPriceDivider(jobsOnQueueModelGlobal.regular);
                      jobsOnQueueModelGlobal.initialLoad =
                          (jobsOnQueueModelGlobal.initialKilo ~/ 8);
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
                    value: jobsOnQueueModelGlobal.sayosabon,
                    onChanged: (val) {
                      jobsOnQueueModelGlobal =
                          resetRegular(jobsOnQueueModelGlobal);

                      if (val!) {
                        setState(
                          () {
                            jobsOnQueueModelGlobal.sayosabon = val;
                          },
                        );
                      }

                      jobsOnQueueModelGlobal.initialKilo = 8;
                      jobsOnQueueModelGlobal.initialPrice =
                          (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                              iPriceDivider(jobsOnQueueModelGlobal.regular);
                      jobsOnQueueModelGlobal.initialLoad =
                          (jobsOnQueueModelGlobal.initialKilo ~/ 8);
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
                    value: jobsOnQueueModelGlobal.others,
                    onChanged: (val) {
                      jobsOnQueueModelGlobal =
                          resetRegular(jobsOnQueueModelGlobal);
                      bShowKiloLoadDisplayVar = false;

                      if (val!) {
                        setState(
                          () {
                            jobsOnQueueModelGlobal.others = val;
                          },
                        );
                      }

                      jobsOnQueueModelGlobal.initialKilo = 0;
                      jobsOnQueueModelGlobal.initialPrice = 0;
                      jobsOnQueueModelGlobal.initialLoad = 0;
                    })
              ],
            ),
          ],
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
                      color: Colors.amber[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (jobsOnQueueModelGlobal.initialKilo < 8) {
                            jobsOnQueueModelGlobal.initialKilo = 8;
                            jobsOnQueueModelGlobal.initialPrice =
                                (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                    iPriceDivider(
                                        jobsOnQueueModelGlobal.regular);
                            jobsOnQueueModelGlobal.initialLoad =
                                (jobsOnQueueModelGlobal.initialKilo ~/ 8);
                          } else {
                            if (jobsOnQueueModelGlobal.initialKilo % 8 != 0) {
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo -
                                      (jobsOnQueueModelGlobal.initialKilo % 8);
                            } else {
                              jobsOnQueueModelGlobal.initialKilo =
                                  jobsOnQueueModelGlobal.initialKilo - 8;
                            }

                            jobsOnQueueModelGlobal.initialPrice =
                                (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                    iPriceDivider(
                                        jobsOnQueueModelGlobal.regular);

                            jobsOnQueueModelGlobal.initialLoad =
                                (jobsOnQueueModelGlobal.initialKilo ~/ 8);
                          }
                          setState(() {
                            jobsOnQueueModelGlobal.initialKilo;
                            jobsOnQueueModelGlobal.initialLoad;
                            jobsOnQueueModelGlobal.initialPrice;
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
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("+8 kg"),
                      IconButton(
                        onPressed: () {
                          if (jobsOnQueueModelGlobal.initialKilo % 8 != 0) {
                            jobsOnQueueModelGlobal.initialKilo =
                                jobsOnQueueModelGlobal.initialKilo +
                                    8 -
                                    (jobsOnQueueModelGlobal.initialKilo % 8);
                          } else {
                            jobsOnQueueModelGlobal.initialKilo =
                                jobsOnQueueModelGlobal.initialKilo + 8;
                          }

                          jobsOnQueueModelGlobal.initialPrice =
                              (jobsOnQueueModelGlobal.initialKilo ~/ 8) *
                                  (iPriceDivider(
                                      jobsOnQueueModelGlobal.regular));
                          jobsOnQueueModelGlobal.initialLoad =
                              jobsOnQueueModelGlobal.initialKilo ~/ 8;
                          setState(() {
                            jobsOnQueueModelGlobal.initialKilo;
                            jobsOnQueueModelGlobal.initialLoad;
                            jobsOnQueueModelGlobal.initialPrice;
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
                      Text(
                          "${kiloDisplay(jobsOnQueueModelGlobal.initialKilo)} kilo"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Load:"),
                      Text("${jobsOnQueueModelGlobal.initialKilo}"),
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
                          "${autoPriceDisplay(jobsOnQueueModelGlobal.initialPrice, jobsOnQueueModelGlobal.regular)}.00"),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                          if (jobsOnQueueModelGlobal.initialKilo > 8) {
                            if (jobsOnQueueModelGlobal.initialKilo % 8 == 1) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //8-9kilo 25

                              jobsOnQueueModelGlobal.initialLoad =
                                  jobsOnQueueModelGlobal.initialLoad - 1;
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                2) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 45
                                          : 50); //9-10kilo 45
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                3) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //10-11kilo 25
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                4) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 25); //11-12kilo
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                5) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 25
                                          : 0); //12-13kilo
                            } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                                6) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice -
                                      (jobsOnQueueModelGlobal.regular
                                          ? 10
                                          : 0); //13-16kilo
                            }

                            jobsOnQueueModelGlobal.initialKilo =
                                jobsOnQueueModelGlobal.initialKilo - 1;
                          }
                          setState(() {
                            jobsOnQueueModelGlobal.initialKilo;
                            jobsOnQueueModelGlobal.initialLoad;
                            jobsOnQueueModelGlobal.initialPrice;
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
                          if (jobsOnQueueModelGlobal.initialKilo >= 8) {
                            jobsOnQueueModelGlobal.initialKilo =
                                jobsOnQueueModelGlobal.initialKilo + 1;
                          }

                          if (jobsOnQueueModelGlobal.initialKilo % 8 == 1) {
                            jobsOnQueueModelGlobal.initialPrice =
                                jobsOnQueueModelGlobal.initialPrice +
                                    (jobsOnQueueModelGlobal.regular
                                        ? 25
                                        : 25); //8-9kilo
                          } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                              2) {
                            jobsOnQueueModelGlobal.initialPrice =
                                jobsOnQueueModelGlobal.initialPrice +
                                    (jobsOnQueueModelGlobal.regular
                                        ? 45
                                        : 50); //9-10kilo
                            setState(() => jobsOnQueueModelGlobal.initialLoad =
                                jobsOnQueueModelGlobal.initialLoad + 1);
                          } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                              3) {
                            jobsOnQueueModelGlobal.initialPrice =
                                jobsOnQueueModelGlobal.initialPrice +
                                    (jobsOnQueueModelGlobal.regular
                                        ? 25
                                        : 25); //10-11kilo
                          } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                              4) {
                            jobsOnQueueModelGlobal.initialPrice =
                                jobsOnQueueModelGlobal.initialPrice +
                                    (jobsOnQueueModelGlobal.regular
                                        ? 25
                                        : 25); //11-12kilo
                          } else if (jobsOnQueueModelGlobal.initialKilo % 8 ==
                              5) {
                            jobsOnQueueModelGlobal.initialPrice =
                                jobsOnQueueModelGlobal.initialPrice +
                                    (jobsOnQueueModelGlobal.regular
                                        ? 25
                                        : 0); //12-13kilo
                          } else {
                            if (jobsOnQueueModelGlobal.initialPrice %
                                    (iPriceDivider(
                                        jobsOnQueueModelGlobal.regular)) !=
                                0) {
                              jobsOnQueueModelGlobal.initialPrice =
                                  jobsOnQueueModelGlobal.initialPrice +
                                      (jobsOnQueueModelGlobal.regular
                                          ? 10
                                          : 0); //13-16kilo
                            }
                          }

                          setState(() {
                            jobsOnQueueModelGlobal.initialKilo;
                            jobsOnQueueModelGlobal.initialLoad;
                            jobsOnQueueModelGlobal.initialPrice;
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

Visibility visAddOn(Function setState) {
  return Visibility(
    visible: (bViewMoreOptions
        ? true
        : (jobsOnQueueModelGlobal.others ? true : false)),
    child: Container(
      decoration: containerSayoSabonBoxDecoration(),
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
                    listAddOnItems.clear();
                    jobsOnQueueModelGlobal.initialOthersPrice = 0;
                    setState(
                      () {
                        jobsOnQueueModelGlobal.others = false;
                        bViewMoreOptions = false;
                      },
                    );

                    //resetAddOn();
                  },
                  icon: Icon(Icons.delete_outline)),
              //checkboxes add on
              Visibility(
                visible: (bViewMoreOptions
                    ? true
                    : (jobsOnQueueModelGlobal.others ? true : false)),
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
                              listAddOnItems.add(selectedDetVar);
                              jobsOnQueueModelGlobal.initialOthersPrice =
                                  jobsOnQueueModelGlobal.initialOthersPrice +
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
                              listAddOnItems.add(selectedFabVar);
                              jobsOnQueueModelGlobal.initialOthersPrice =
                                  jobsOnQueueModelGlobal.initialOthersPrice +
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
                              listAddOnItems.add(selectedBleVar);
                              jobsOnQueueModelGlobal.initialOthersPrice =
                                  jobsOnQueueModelGlobal.initialOthersPrice +
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
                              listAddOnItems.add(selectedOthVar);
                              jobsOnQueueModelGlobal.initialOthersPrice =
                                  jobsOnQueueModelGlobal.initialOthersPrice +
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
              readAddedDataVar(listAddOnItems),
              //_dtAddedOthers(addOnItems),
              //_addedOn(addOnItems),
            ],
          ),
        ],
      ),
    ),
  );
}

Container conTotalPrice(Function setState) {
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
          "Php ${jobsOnQueueModelGlobal.initialPrice + jobsOnQueueModelGlobal.initialOthersPrice}.00",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Container conBasket(Function setState) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() => jobsOnQueueModelGlobal.basket--);
          },
          icon: const Icon(Icons.remove_circle_outlined),
          color: Colors.blueAccent,
        ),
        Text("Basket: ${jobsOnQueueModelGlobal.basket}"),
        IconButton(
          onPressed: () {
            setState(() => jobsOnQueueModelGlobal.basket++);
          },
          icon: const Icon(Icons.add_circle),
          color: Colors.blueAccent,
        ),
      ],
    ),
  );
}

Container conBag(Function setState) {
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() => jobsOnQueueModelGlobal.bag--);
          },
          icon: const Icon(Icons.remove_circle_outlined),
          color: Colors.blueAccent,
        ),
        Text("Bag: ${jobsOnQueueModelGlobal.bag}"),
        IconButton(
          onPressed: () {
            setState(() => jobsOnQueueModelGlobal.bag++);
          },
          icon: const Icon(Icons.add_circle),
          color: Colors.blueAccent,
        ),
      ],
    ),
  );
}

Container conPayment(Function setState) {
  return Container(
    decoration: containerQueBoxDecoration(),
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
                value: jobsOnQueueModelGlobal.unpaid,
                onChanged: (val) {
                  resetPaymentQueueBool(jobsOnQueueModelGlobal);
                  if (val!) {
                    setState(
                      () {
                        jobsOnQueueModelGlobal.unpaid = val;
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
                value: jobsOnQueueModelGlobal.paidcash,
                onChanged: (val) {
                  resetPaymentQueueBool(jobsOnQueueModelGlobal);
                  if (val!) {
                    setState(
                      () {
                        jobsOnQueueModelGlobal.paidcash = val;
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
                value: jobsOnQueueModelGlobal.paidgcash,
                onChanged: (val) {
                  resetPaymentQueueBool(jobsOnQueueModelGlobal);
                  if (val!) {
                    setState(
                      () {
                        jobsOnQueueModelGlobal.paidgcash = val;
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

Container conRemarks(Function setState) {
  remarksControllerVar.text = jobsOnQueueModelGlobal.remarks;
  return Container(
    padding: EdgeInsets.all(1.0),
    decoration: containerQueBoxDecoration(),
    child: TextFormField(
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.start,
      controller: remarksControllerVar,
      decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
      validator: (val) {},
    ),
  );
}

Container conMoreOptions(Function setState) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: containerSayoSabonBoxDecoration(),
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

Visibility visFold(Function setState) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: containerSayoSabonBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No Fold"),
          Switch.adaptive(
            value: jobsOnQueueModelGlobal.fold,
            onChanged: (bool value) {
              setState(() {
                jobsOnQueueModelGlobal.fold = value;
              });
            },
          ),
          Text("Fold"),
        ],
      ),
    ),
  );
}

Visibility visMix(Function setState) {
  return Visibility(
    visible: bViewMoreOptions,
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(1.0),
      decoration: containerSayoSabonBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Dont Mix"),
          Switch.adaptive(
            value: jobsOnQueueModelGlobal.mix,
            onChanged: (bool value) {
              setState(() {
                jobsOnQueueModelGlobal.mix = value;
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
      decoration: containerSayoSabonBoxDecoration(),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Color.fromARGB(0, 212, 212, 212), width: 0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("-1 day"),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(days: -1)));
                  },
                  icon: const Icon(Icons.remove_circle_outlined),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(days: 1)));
                  },
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blueAccent,
                ),
                Text("+1 day"),
              ],
            ),
          ),
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
                Text("-1 hr"),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(hours: -1)));
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: () {
                    setState(
                        () => dNeedOnVar = dNeedOnVar.add(Duration(hours: 1)));
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blueAccent,
                ),
                Text("+1 hr"),
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
  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();
  for (var doc in querySnapshots.docs) {
    if (jobsId == 1) {
      //updatePrevOne25(jobsId);
      //break;
      if (doc['JobsId'] == 1) {
        await doc.reference.update({
          'JobsId': 25,
        });
      }
      if (doc['JobsId'] == 25) {
        await doc.reference.update({
          'JobsId': 1,
        });
      }
    } else {
      if ((jobsId - 1) == doc['JobsId']) {
        await doc.reference.update({
          'JobsId': jobsId,
        });
      } else if ((jobsId) == doc['JobsId']) {
        await doc.reference.update({
          'JobsId': jobsId - 1,
        });
      }
    }
  }
}

//Display
Container conDisplayVar(
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
        Column(
          children: [
            InkWell(
              onDoubleTap: () {
                /*
                  if (jobsOnQueueModel.queueStat == "Waiting") {
                    alterNumberMobile(buffJobsId);
                  }
                  */
              },
              child: Text(
                //(buffJobsId == 0 ? "" : "#$buffJobsId"),
                (jOQM.jobsId == 0 ? "" : jOQM.jobsId.toString()),
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
                  moveUpVar(jOQM.jobsId);
                },
                icon: const Icon(Icons.arrow_upward),
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
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
                "${jOQM.unpaid ? "Unpaid" : {
                    jOQM.paidcash
                        ? "Paid Cash"
                        : {jOQM.paidgcash ? "Paid GCash" : "Unknown"}
                  }} : Php ${jOQM.initialPrice + jOQM.initialOthersPrice}.00",
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
      ],
    ),
  );
}

//alterjobsonqueue
void showAlterJobsOnQueueVar(
    BuildContext context, String docId, JobsOnQueueModel jOQM) {
  jobsOnQueueModelGlobal = jOQM;
  dNeedOnVar = jobsOnQueueModelGlobal.needOn.toDate();
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
                    conQueueStat(setState),
                    conOrderMode(setState),
                    visAddOn(setState),
                    conTotalPrice(setState),
                    conBasket(setState),
                    conBag(setState),
                    conPayment(setState),
                    conRemarks(setState),
                    conMoreOptions(setState),
                    visFold(setState),
                    visMix(setState),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //cancel button
            cancelButtonVar(context),

            //save button
            updateJOQVar(context, docId, jOQM),
          ],
        );
      });
    },
  );
}

Widget updateJOQVar(BuildContext context, String docId, JobsOnQueueModel jOQM) {
  return MaterialButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );

      //pop box
      Navigator.pop(context);
      udpateJOQMVar(docId, jOQM);
    },
    color: cButtons,
    child: const Text("Update"),
  );
}

void udpateJOQMVar(String docId, JobsOnQueueModel jOQM) {
  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsOnQueue.updateJobsOnQueue(docId, jOQM);
}
