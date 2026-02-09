import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/models/jobsmodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/database_employee_current.dart';
import 'package:laundry_firebase/services/database_jobs.dart';
import 'package:laundry_firebase/services/database_supplies_current.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsmodel_repository.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

//
double quantityKg = 8;
int quantityLoad = 1;
bool isGcashCredit = false;
const double fieldIndentWidth = 40;
TextEditingController customerNameVar = TextEditingController();
TextEditingController customerNumberVar = TextEditingController();
TextEditingController customerAmountVar = TextEditingController();
TextEditingController partialCashAmountVar = TextEditingController();
TextEditingController partialGCashAmountVar = TextEditingController();
int selectedRiderPickup = forSorting;
int selectedPackage = regularPackage;
int selectedPackagePrev = regularPackage;
int selectedOthers = menuOthDVal;
int totalPriceRegSS = 155;
int totalPriceShortCutRegSS = 0;
OtherItemModel selectedItemModel = reg125ItemModel;
int selectedOthersShortCut = menuOth155;
int selectedPaidUnpaid = unpaid;
bool selectedPaidPartialCash = false;
bool selectedPaidPartialGCash = false;
bool selectedPaidGCashVerified = false;
bool selectedFold = true;
bool selectedMix = true;
int basketCount = 0;
int ecoBagCount = 0;
int sakoCount = 0;
int addFabCount = 0;
int addExtraDryCount = 0;
int addExtraWashCount = 0;
int addExtraSpinCount = 0;
bool isMaxFab = false;
int totalPriceOthers = 0;
bool isPerKg = true;
final int tier1Increase = 35;
final int tier2Increase = 105;
int pricePerSet = 0;
int maxPartial = 0;
bool successInsertFB = false;

final NumberFormat pesoFormat = NumberFormat('#,##0', 'en_PH');

//end of day
final List<int> denominations = [1000, 500, 200, 100, 50, 20, 10, 5, 1];

final Map<int, int> qtyMap = {
  for (final d in [1000, 500, 200, 100, 50, 20, 10, 5, 1]) d: 0,
};

// 🔢 Price formatter
final formatter = NumberFormat.currency(
  locale: 'en_PH',
  symbol: '₱ ',
  decimalDigits: 2,
);

int? selectedFundCode; // = menuOthLaundryPayment;

//SHARED METHODS ###########################################################

// 🔘 Reusable button
Widget boxButton({
  required String label,
  required VoidCallback? onTap,
  bool disabled = false,
}) {
  final color = disabled ? Colors.grey.shade400 : Colors.black54;
  final decoColor = disabled ? Colors.transparent : Colors.greenAccent;

  return InkWell(
    onTap: disabled ? null : onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 42,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: decoColor,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
  );
}

Widget boxButtonOtherItems({
  required String label,
  required VoidCallback? onTap,
  bool disabled = false,
}) {
  final color = disabled ? Colors.grey.shade400 : Colors.black54;
  final decoColor = disabled ? Colors.transparent : Colors.pinkAccent[100];

  return InkWell(
    onTap: disabled ? null : onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 42,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: decoColor,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ),
  );
}

// 🔘 Reusable button
Widget boxButton2label({
  required String label,
  required String label2,
  required bool boldLabel2,
  required VoidCallback? onTap,
  bool disabled = false,
}) {
  final color = disabled ? Colors.grey.shade400 : Colors.black54;
  final decoColor = disabled ? Colors.transparent : Colors.greenAccent;

  return InkWell(
    onTap: disabled ? null : onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 52,
      height: 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: decoColor,
        border: Border.all(
          color: color,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                fontSize: (boldLabel2 ? 10 : 12),
                fontWeight: (boldLabel2 ? FontWeight.normal : FontWeight.bold),
              ),
            ),
            TextSpan(
              text: label2,
              style: TextStyle(
                  fontSize: (boldLabel2 ? 12 : 10),
                  fontWeight:
                      (boldLabel2 ? FontWeight.bold : FontWeight.normal)),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

int get grandTotal {
  int total = 0;
  qtyMap.forEach((denom, qty) {
    total += denom * qty;
  });
  return total;
}

String showHowMany155or125Set(int total, bool bSeparate) {
  //int base = pricePerSet;
  List<int> extras = [pricePerSet + tier1Increase, pricePerSet + tier2Increase];

  // Base single
  if (total == pricePerSet) return ' $pricePerSet';

  // Extras alone
  if (extras.contains(total)) return ' $total';

  for (final extra in [0, ...extras]) {
    final remaining = total - extra;

    if (remaining <= 0) continue;
    if (remaining % pricePerSet != 0) continue;

    final multiplier = remaining ~/ pricePerSet;

    if (multiplier == 1 && extra == 0) {
      return ' $pricePerSet';
    }

    if (multiplier == 1 && extra != 0) {
      return ' $pricePerSet\n + $extra';
    }

    if (multiplier > 1 && extra == 0) {
      return ' ($pricePerSet * $multiplier)';
    }

    if (multiplier > 1 && extra != 0) {
      if (bSeparate) {
        return ' ($pricePerSet * $multiplier)\n + $extra';
      } else {
        return ' ($pricePerSet * $multiplier) + $extra';
      }
    }
  }

  // Fallback if it doesn't match the pattern
  return ' $total';
}

// 💰 Tiered price computation
int computeTotalPrice(double q) {
  int counter = (q / 8).floor(); // how many full 8s
  counter = (counter == 0 ? 1 : counter);

  int remainingPrice = 0;

  if (q > 8) {
    double remaining = double.parse((q % 8).toStringAsFixed(1));
    if (remaining <= 0) {
      remainingPrice = 0;
    } else if (remaining > 0 && remaining <= 0.9) {
      remainingPrice = tier1Increase;
    } else if (remaining < maxPartial) {
      remainingPrice = tier2Increase;
    } else if (remaining >= maxPartial) {
      remainingPrice = pricePerSet;
    }
    debugPrint('c=$counter rP=$remainingPrice r=$remaining');
  }

  return (counter * pricePerSet) + remainingPrice;
}

void resetAfterInsert() {
  SuppliesHistRepository.instance.reset();
  autocompleteSelected = CustomerModel(
      customerId: 0,
      name: '',
      address: '',
      contact: '',
      remarks: '',
      loyaltyCount: 0);
  customerAmountVar.text = "";
  // customerNameVar.text = "";
  remarksSuppliesVar.text = "";
  selectedFundCode = null;
}

Future<void> setSuppliesRepository(BuildContext context) async {
  //insert to database
  //save to repository

  SuppliesHistRepository.instance.setCustomerId(123); //dummy
  SuppliesHistRepository.instance
      .setLogDate(Timestamp.fromDate(DateTime.now()));

  if (await _callDatabaseSuppliesCurrentAdd(
      SuppliesHistRepository.instance.suppliesModelHist!)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Success')),
    );
    print("Sucess");
    resetAfterInsert();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cannot Save')),
    );
    print("Failed");
  }
}

//insert new Supplies
Future<bool> _callDatabaseSuppliesCurrentAdd(SuppliesModelHist sMH) async {
  //if cashout or funds out, make current counter negative
  if (ifMenuUniqueIsCashOut(sMH) ||
      ifMenuUniqueIsFundsOut(sMH) ||
      (isGcashCredit && sMH.itemUniqueId == menuOthUniqIdCashIn)) {
    sMH.currentCounter = sMH.currentCounter * -1;
  }

  // add funds in name to regular staff
  // funds in is called paluwal, i-add sa sahod

  // ##### insert to Employee Current if Funds Out and name exists in nameMap ######
  // checking
  // 1. name exists in nameMap
  //    * itemUniqueId is Funds Out
  //    * exclude Ket and DonF employee record for admin
  //    * isGcashCredit and itemUniqueId is Cash In
  //    * isAdmin and itemUniqueId is Salary Payment
  if (sMH.customerName != "") {
    if (nameMap[sMH.customerName.toLowerCase()] !=
                null //check if employee exists
            &&
            (sMH.itemUniqueId == menuOthUniqIdFundsOut //funds out employee
                ||
                (isGcashCredit &&
                    sMH.itemUniqueId == menuOthUniqIdCashIn) //gcash credit
                ||
                ((isAdmin || allowPayment) &&
                    sMH.itemUniqueId ==
                        menuOthSalaryPayment) //salary payment access by admin only, or allowPayment
                ||
                (sMH.itemUniqueId == menuOthUniqIdFundsIn) //paluwal
            ) &&
            (sMH.customerName != 'Ket' &&
                sMH.customerName !=
                    'DonF') //funds out admin, no need to record in employee table
        ) {
      //############### start insert to Employee Current #################
      //get empId from nameMap
      final tempEmpId = empNameToId[sMH.customerName];

      DatabaseEmployeeCurrent databaseEmployeeCurrent =
          DatabaseEmployeeCurrent();

      //insert to Employee Current
      if (await databaseEmployeeCurrent.addEmployeeCurr(EmployeeModel(
        empId: tempEmpId!,
        docId: "",
        countId: 0,
        currentCounter: sMH.currentCounter,
        currentStocks: 0,
        itemId: sMH.itemId,
        itemUniqueId: sMH.itemUniqueId,
        itemName: sMH.itemName,
        logDate: sMH.logDate,
        logBy: empIdGlobal,
        empName: sMH.customerName,
        remarks: sMH.remarks,
      ))) {
        debugPrint("Employee Current updated...");
        //prevent generating another record in Supplies Current
        if (isGcashCredit ||
            ((isAdmin || allowPayment) &&
                sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          return true;
        }
      } else {
        debugPrint("Employee Current failed to update...");
        //prevent generating another record in Supplies Current
        if (isGcashCredit ||
            ((isAdmin || allowPayment) &&
                sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          return false;
        }
      }
      //############### end insert to Employee Current #################
    }
  }

  //this will insert to Supplies History first then Supplies Current
  //if exists in Supplies Current, it will update
  //if not exists, it will add new record in Supplies Current
  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
  return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  // return false;
}

Future<void> callDatabaseJobsQueueAdd(BuildContext context) async {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();

  if (await databaseJobsQueue
      .add(JobsModelRepository.instance.getJobsModel()!)) {
    successInsertFB = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insert on Queue done.')),
    );
  } else {
    successInsertFB = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error insert Jobs On Queue.')),
    );
  }
}

//laundry payment
Future<void> setRepositoryLaundryPayment(
    BuildContext context, String viaJobs) async {
  //generate only when funds received ( paidCash, partialPaidCash )
  //only PaidCash or PartialPaidCash
  if (JobsModelRepository.instance.getPaidCash() ||
      JobsModelRepository.instance.getPartialPaidCash()) {
    //auto generated for Laundry payment, once user tag job to paid.
    SuppliesHistRepository.instance.setItemName(getItemNameOnly(
        menuOthCashInOutFunds, menuOthLaundryPayment)); //cash laundry payment
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance
        .setItemUniqueId(menuOthLaundryPayment); //cash laundry payment
    SuppliesHistRepository.instance.setRemarks('auto via $viaJobs paid');

    if (JobsModelRepository.instance.getPartialPaidCash()) {
      SuppliesHistRepository.instance.setCurrentCounter(
          JobsModelRepository.instance.getPartialPaidCashAmount());
    } else {
      SuppliesHistRepository.instance
          .setCurrentCounter(JobsModelRepository.instance.getFinalPrice());
    }

    await setSuppliesRepository(context);
  }
}

//revert laundry payment
Future<void> revertLaundryPaymentSuppliesHistory(
    BuildContext context, String viaJobs) async {
  //generate only when funds received and needs to revert ( paidCash, partialPaidCash )
  //only PaidCash or PartialPaidCash
  if (JobsModelRepository.instance.getUnpaid()) {
    //auto generated for Laundry payment, once user tag job to paid, reverted as funds out
    SuppliesHistRepository.instance.setItemName(getItemNameOnly(
        menuOthCashInOutFunds, menuOthUniqIdFundsOut)); //funds out
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance
        .setItemUniqueId(menuOthUniqIdFundsOut); //funds out
    SuppliesHistRepository.instance.setRemarks('auto via $viaJobs unpaid');

    if (JobsModelRepository.instance.getPartialPaidCashAmount() > 0) {
      SuppliesHistRepository.instance.setCurrentCounter(
          JobsModelRepository.instance.getPartialPaidCashAmount());
    } else {
      SuppliesHistRepository.instance
          .setCurrentCounter(JobsModelRepository.instance.getFinalPrice());
    }

    await setSuppliesRepository(context);
  }
}

Future<void> callDatabaseJobsQueueUpdate(
    BuildContext context, JobsModel jM) async {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();

  if (await databaseJobsQueue.update(jM)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update on Queue done.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error update Jobs On Queue.')),
    );
  }
}
