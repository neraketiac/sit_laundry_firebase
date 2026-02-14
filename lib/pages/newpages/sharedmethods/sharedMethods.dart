import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/oldmodels/customermodel.dart';
import 'package:laundry_firebase/models/newmodels/employeemodel.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/services/newservices/database_employee_current.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/services/newservices/database_supplies_current.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

//SHARED METHODS ###########################################################

// 🔢 Price formatter
final formatter = NumberFormat.currency(
  locale: 'en_PH',
  symbol: '₱ ',
  decimalDigits: 2,
);

int get grandTotal {
  int total = 0;
  qtyMap.forEach((denom, qty) {
    total += denom * qty;
  });
  return total;
}

String showHowMany155or125Set(
    int total, bool bSeparate, JobModelRepository jobRepo) {
  if (jobRepo.addOn) {
    return '';
  } else {
//int base = pricePerSet;
    List<int> extras = [
      jobRepo.pricePerSet + tier1Increase,
      jobRepo.pricePerSet + tier2Increase
    ];

    // Base single
    if (total == jobRepo.pricePerSet) return ' ${jobRepo.pricePerSet}}';

    // Extras alone
    if (extras.contains(total)) return ' $total';

    for (final extra in [0, ...extras]) {
      final remaining = total - extra;

      if (remaining <= 0) continue;
      if (remaining % jobRepo.pricePerSet != 0) continue;

      final multiplier = remaining ~/ jobRepo.pricePerSet;

      if (multiplier == 1 && extra == 0) {
        return ' ${jobRepo.pricePerSet}';
      }

      if (multiplier == 1 && extra != 0) {
        return ' ${jobRepo.pricePerSet}\n + $extra';
      }

      if (multiplier > 1 && extra == 0) {
        return ' (${jobRepo.pricePerSet} * $multiplier)';
      }

      if (multiplier > 1 && extra != 0) {
        if (bSeparate) {
          return ' (${jobRepo.pricePerSet} * $multiplier)\n + $extra';
        } else {
          return ' (${jobRepo.pricePerSet} * $multiplier) + $extra';
        }
      }
    }
  }

  // Fallback if it doesn't match the pattern
  return ' $total';
}

// 💰 Tiered price computation
int computeTotalPrice(double q, JobModelRepository jobRepo) {
  int counter = (q / 8).floor(); // how many full 8s
  counter = (counter == 0 ? 1 : counter);

  int remainingPrice = 0;

  if (q > 8) {
    double remaining = double.parse((q % 8).toStringAsFixed(1));
    if (remaining <= 0) {
      remainingPrice = 0;
    } else if (remaining > 0 && remaining <= 0.9) {
      remainingPrice = tier1Increase;
    } else if (remaining < jobRepo.maxPartial) {
      remainingPrice = tier2Increase;
    } else if (remaining >= jobRepo.maxPartial) {
      remainingPrice = jobRepo.pricePerSet;
    }
    debugPrint('c=$counter rP=$remainingPrice r=$remaining');
  }

  return (counter * jobRepo.pricePerSet) + remainingPrice;
}

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

//set selected to repository
void setSelectedToRepository(JobModelRepository jobRepo) {
  int computePromoCounter = 0;
  int computeLoadForKg(double kg) {
    double remainder = kg % 8;
    int wholeEight = kg ~/ 8;
    int lastCounter = 0;
    if (remainder < 1) {
      lastCounter = 0;
    } else {
      lastCounter = 1;
    }
    if (remainder >= 3) {
      computePromoCounter = wholeEight + 1;
    } else {
      computePromoCounter = wholeEight;
    }

    return wholeEight + lastCounter;
  }

  jobRepo.currentEmpId = empIdGlobal;

  //initial status
  jobRepo.forSorting = forSorting == jobRepo.selectedRiderPickup;
  jobRepo.riderPickup = riderPickup == jobRepo.selectedRiderPickup;

  //package status
  jobRepo.regular = regularPackage == jobRepo.selectedPackage;
  jobRepo.sayosabon = sayoSabonPackage == jobRepo.selectedPackage;
  jobRepo.addOn = othersPackage == jobRepo.selectedPackage;

  //prices
  if (jobRepo.selectedPackage == othersPackage) {
    jobRepo.finalPrice = jobRepo.totalPriceOthers;
  } else {
    jobRepo.finalPrice = jobRepo.totalPriceRegSS;
  }

  //payment status
  jobRepo.unpaid = unpaid == jobRepo.selectedPaidUnpaid;
  jobRepo.paidCash = paidCash == jobRepo.selectedPaidUnpaid;
  jobRepo.paidGCash = paidGCash == jobRepo.selectedPaidUnpaid;
  jobRepo.partialPaidCash = jobRepo.selectedPaidPartialCash;
  jobRepo.partialPaidGCash = jobRepo.selectedPaidPartialGCash;
  jobRepo.partialPaidCashAmount =
      int.tryParse(jobRepo.partialCashAmountVar.text) ?? 0;
  jobRepo.partialPaidGCashAmount =
      int.tryParse(jobRepo.partialGCashAmountVar.text) ?? 0;

  if (unpaid != jobRepo.selectedPaidUnpaid) {
    jobRepo.paymentReceivedBy = empIdGlobal;
  }

  //verified gcash
  jobRepo.paidGCashVerified = jobRepo.selectedPaidGCashVerified;

  //weight status
  jobRepo.perKilo = false;
  jobRepo.perLoad = false;

  if (jobRepo.isPerKg) {
    jobRepo.perKilo = true;
    jobRepo.finalKilo = jobRepo.quantityKg;
    jobRepo.finalLoad = computeLoadForKg(jobRepo.quantityKg);
    jobRepo.promoCounter = computePromoCounter;
    jobRepo.pricingSetup = showHowMany155or125Set(
        computeTotalPrice(jobRepo.quantityKg, jobRepo), false, jobRepo);
    jobRepo.remarks = jobRepo.remarksVar.text;
  } else {
    jobRepo.perLoad = true;
    jobRepo.finalLoad = jobRepo.quantityLoad;
    jobRepo.promoCounter = jobRepo.quantityLoad;
    jobRepo.pricingSetup = 'Load(s): ${jobRepo.quantityLoad}';
    jobRepo.remarks = jobRepo.remarksVar.text;
  }

  //list other items
  if (listAddedOtherItemModel.isNotEmpty) {
    jobRepo.items = jobRepo.listSelectedItemModel;
  }

  //other options
  jobRepo.fold = jobRepo.selectedFold;
  jobRepo.mix = jobRepo.selectedMix;
  jobRepo.basket = jobRepo.basketCount;
  jobRepo.ebag = jobRepo.ecoBagCount;
  jobRepo.sako = jobRepo.sakoCount;
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

Future<void> callDatabaseJobsQueueAdd(
    BuildContext context, JobModelRepository jobRepo) async {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();

  if (await databaseJobsQueue.add(jobRepo.jobModel)) {
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
    BuildContext context, String viaJobs, JobModelRepository jobRepo) async {
  //generate only when funds received ( paidCash, partialPaidCash )
  //only PaidCash or PartialPaidCash
  if (jobRepo.paidCash || jobRepo.partialPaidCash) {
    //auto generated for Laundry payment, once user tag job to paid.
    SuppliesHistRepository.instance.setItemName(getItemNameOnly(
        menuOthCashInOutFunds, menuOthLaundryPayment)); //cash laundry payment
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance
        .setItemUniqueId(menuOthLaundryPayment); //cash laundry payment
    SuppliesHistRepository.instance.setRemarks('auto via $viaJobs paid');

    if (jobRepo.partialPaidCash) {
      SuppliesHistRepository.instance
          .setCurrentCounter(jobRepo.partialPaidCashAmount);
    } else {
      SuppliesHistRepository.instance.setCurrentCounter(jobRepo.finalPrice);
    }

    await setSuppliesRepository(context);
  }
}

//revert laundry payment
Future<void> revertLaundryPaymentSuppliesHistory(
    BuildContext context, String viaJobs, JobModelRepository jobRepo) async {
  //generate only when funds received and needs to revert ( paidCash, partialPaidCash )
  //only PaidCash or PartialPaidCash
  if (jobRepo.paidCash) {
    //auto generated for Laundry payment, once user tag job to paid, reverted as funds out
    SuppliesHistRepository.instance.setItemName(getItemNameOnly(
        menuOthCashInOutFunds, menuOthUniqIdFundsOut)); //funds out
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance
        .setItemUniqueId(menuOthUniqIdFundsOut); //funds out
    SuppliesHistRepository.instance.setRemarks('auto via $viaJobs unpaid');

    if (jobRepo.partialPaidCashAmount > 0) {
      SuppliesHistRepository.instance
          .setCurrentCounter(jobRepo.partialPaidCashAmount);
    } else {
      SuppliesHistRepository.instance.setCurrentCounter(jobRepo.finalPrice);
    }

    await setSuppliesRepository(context);
  }
}

Future<void> callDatabaseJobQueueUpdate(
    BuildContext context, JobModel jM) async {
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
