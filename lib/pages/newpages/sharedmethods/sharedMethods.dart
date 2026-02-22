import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';
import 'package:laundry_firebase/models/oldmodels/customermodel.dart';
import 'package:laundry_firebase/models/newmodels/employeemodel.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/services/newservices/database_employee_current.dart';
import 'package:laundry_firebase/services/newservices/database_gcash.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/services/newservices/database_supplies_current.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:http/http.dart' as http;
import 'dart:convert';

//SHARED METHODS ###########################################################

//########################################################################//
//                                                                        //
//                            FORMULAS                                    //
//                                                                        //
//########################################################################//

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
//    debugPrint('c=$counter rP=$remainingPrice r=$remaining');
  }

  return (counter * jobRepo.pricePerSet) + remainingPrice;
}

void showImagePreview(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget animatedPanel({
  required bool visible,
  required double width,
  required Widget child,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    width: visible ? width : 0,
    child: ClipRect(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: width,
          ),
          color: Colors.blue,
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
  );
}

//########################################################################//
//                                                                        //
//                            BUTTONS                                     //
//                                                                        //
//########################################################################//

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

ElevatedButton boxButtonElevated({
  required BuildContext context,
  required String label,
  required Future<bool> Function()? onPressed,
  bool disabled = false,
}) {
  return ElevatedButton(
    onPressed: disabled || onPressed == null
        ? null
        : () async {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            bool success = false;

            try {
              success = await onPressed();
            } catch (e) {
              print(e);
            }

            // Close loading
            Navigator.of(context, rootNavigator: true).pop();

            // Close confirmation dialog ONLY if success
            if (success) {
              Navigator.of(context).pop(true);
            }
          },
    child: Text(label),
  );
}

//########################################################################//
//                                                                        //
//                            JOBREPOS                                    //
//                                                                        //
//########################################################################//

String textJobStatus(JobModel jM) {
  if (jM.processStep == '') {
    if (jM.forSorting) {
      return 'For Sorting';
    }
    if (jM.riderPickup) {
      return 'Rider Pickup';
    }
  } else {
    return jM.processStep;
  }

  return 'no status';
}

String displayCustomerName(String? name) {
  if (name == null || name.isEmpty) return '';
  return name.length > 7 ? name.substring(0, 7) : name;
}

IconData statusIcon(JobModel jM) {
  if (jM.forSorting) {
    return Icons.sort_by_alpha_outlined;
  }
  if (jM.riderPickup) {
    return Icons.delivery_dining;
  }
  return Icons.pause;
}

Color backGroundStatusColor(JobModel jM) {
  if (jM.forSorting) {
    return Colors.green.shade300;
    ;
  }
  if (jM.riderPickup) {
    return Colors.redAccent;
  }
  return Colors.grey;
}

String textBagDetails(JobModel jM) {
  final List<String> parts = [];

  if (jM.basket > 0) parts.add('${jM.basket}B');
  if (jM.ebag > 0) parts.add('${jM.ebag}E');
  if (jM.sako > 0) parts.add('${jM.sako}S');

  return parts.join(' ');
}

String textExtras(JobModel jM) {
  final List<String> parts = [];

  /// 🔁 Group item names and count
  if (jM.items != null && jM.items!.isNotEmpty) {
    final Map<String, int> itemCounts = {};

    for (final item in jM.items!) {
      late String? name;
      if (item.itemGroup == groupOth) {
        name = itemNameAliases[item.itemUniqueId];
      } else {
        name = item.itemGroup.trim();
      }

      if (name == null || name.isEmpty) continue;

      itemCounts[name] = (itemCounts[name] ?? 0) + 1;
    }

    /// 🧾 Build display string
    itemCounts.forEach((name, count) {
      if (count > 1) {
        parts.add('$count-$name');
      } else {
        parts.add(name);
      }
    });
  }

  return parts.join(' ');
}

//reset payment
void resetPaymentStatus(JobModelRepository jobRepo) {
  jobRepo.unpaid = true;
  jobRepo.paidCash = false;
  jobRepo.paidGCash = false;
  jobRepo.cashAmountVar.text = '';
  jobRepo.cashAmountVar.text = '';
}

void resetSelected(JobModelRepository jobRepo) {
  successInsertFB = false;
  jobRepo.selectedRiderPickup = forSorting;
  //package status
  jobRepo.selectedPackage = regularPackage;

  //prices
  jobRepo.totalPriceRegSS = 155;
  jobRepo.totalPriceOthers = 0;

  //payment status
  jobRepo.unpaid = true;
  jobRepo.paidCash = false;
  jobRepo.paidGCash = false;
  jobRepo.cashAmountVar.text = '';
  jobRepo.gCashAmountVar.text = '';

  //verified gcash
  jobRepo.selectedPaidGCashVerified = false;

  //weight status
  jobRepo.isPerKg = true;

  jobRepo.quantityKg = 8;
  jobRepo.quantityLoad = 1;
  jobRepo.remarksVar.text = '';

  jobRepo.finalPrice = 0;

  //list other items
  jobRepo.clearListSelectedItemModel();
  jobRepo.items.clear();

  //other options
  jobRepo.selectedFold = true;
  jobRepo.selectedMix = true;
  jobRepo.basketCount = 0;
  jobRepo.ecoBagCount = 0;
  jobRepo.sakoCount = 0;
  jobRepo.addFabCount = 0;
  jobRepo.addExtraDryCount = 0;
  jobRepo.addExtraWashCount = 0;
  jobRepo.addExtraSpinCount = 0;
}

void syncRepoToSelectedBeforePopup(JobModelRepository jobRepo) {
  //admin
  jobRepo.currentEmpId = empIdGlobal;

  jobRepo.customerNameVar.text = jobRepo.customerName;

  //initial status
  //riderpickup can be true and forsorting is true, but always display the forSorting. meaning pickup is done.
  //if pickup is false, it went to forsorting but never in pickup.
  if (jobRepo.riderPickup) jobRepo.selectedRiderPickup = riderPickup;
  if (jobRepo.forSorting) jobRepo.selectedRiderPickup = forSorting;

  //package status
  if (jobRepo.regular) jobRepo.selectedPackage = regularPackage;
  if (jobRepo.sayosabon) jobRepo.selectedPackage = sayoSabonPackage;
  if (jobRepo.addOn) {
    jobRepo.selectedPackage = othersPackage;
    jobRepo.selectedPackagePrev = othersPackage;
  }

  //prices
  if (jobRepo.addOn) {
    jobRepo.totalPriceOthers = jobRepo.finalPrice;
    jobRepo.totalPriceRegSS = 0;
  } else {
    jobRepo.totalPriceRegSS = jobRepo.finalPrice;
    jobRepo.totalPriceOthers = 0;
  }

  //payment status
  jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;
  jobRepo.remarksVar.text = jobRepo.remarks;

  //weight status
  if (jobRepo.perKilo) jobRepo.isPerKg = true;
  if (jobRepo.perLoad) jobRepo.isPerKg = false;

  jobRepo.quantityKg = jobRepo.finalKilo;
  jobRepo.quantityLoad = jobRepo.finalLoad;
  jobRepo.remarksVar.text = jobRepo.remarks;

  //list other items
  //if (jobRepo.selectedPackage == othersPackage) {
  jobRepo.listSelectedItemModel = List.from(jobRepo.items);
  jobRepo.totalPriceShortCutRegSS = jobRepo.items.fold(
    0,
    (sum, item) => sum + item.itemPrice,
  );
  //}

  //other options
  jobRepo.selectedFold = jobRepo.fold;
  jobRepo.selectedMix = jobRepo.mix;
  jobRepo.basketCount = jobRepo.basket;
  jobRepo.ecoBagCount = jobRepo.ebag;
  jobRepo.sakoCount = jobRepo.sako;

  if (jobRepo.selectedPackage != othersPackage) {
    jobRepo.addFabCount = jobRepo.items
        .where((e) => e.itemUniqueId == addFabAnyItemModel.itemUniqueId)
        .length;
    jobRepo.addExtraDryCount = jobRepo.items
        .where((e) => e.itemUniqueId == xDItemModel.itemUniqueId)
        .length;
    jobRepo.addExtraWashCount = jobRepo.items
        .where((e) => e.itemUniqueId == xWashItemModel.itemUniqueId)
        .length;
    jobRepo.addExtraSpinCount = jobRepo.items
        .where((e) => e.itemUniqueId == xSpinItemModel.itemUniqueId)
        .length;
  } else {
    jobRepo.addFabCount = 0;
    jobRepo.addExtraDryCount = 0;
    jobRepo.addExtraWashCount = 0;
    jobRepo.addExtraSpinCount = 0;
  }

  jobRepo.selectedOnGoingStatus = jobRepo.processStep;

  // if (jobRepo.processStep == 'waiting') {
  //   jobRepo.selectedOnGoingStatus = processWaiting;
  // }
  // if (jobRepo.processStep == 'washing') {
  //   jobRepo.selectedOnGoingStatus = processWashing;
  // }
  // if (jobRepo.processStep == 'drying') {
  //   jobRepo.selectedOnGoingStatus = processDrying;
  // }
  // if (jobRepo.processStep == 'folding') {
  //   jobRepo.selectedOnGoingStatus = processFolding;
  // }
}

//set selected to repository
void setSelectedToRepositoryBeforeSave(JobModelRepository jobRepo) {
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
  //

  //payment status
  if (jobRepo.paidCash) {
    if ((int.tryParse(jobRepo.cashAmountVar.text) ?? 0) >= jobRepo.finalPrice) {
      jobRepo.unpaid = false;
    }
  }

  if (jobRepo.paidCash) {
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
  if (jobRepo.listSelectedItemModel.isNotEmpty) {
    jobRepo.items = List.from(jobRepo.listSelectedItemModel);
  }

  //other options
  jobRepo.fold = jobRepo.selectedFold;
  jobRepo.mix = jobRepo.selectedMix;
  jobRepo.basket = jobRepo.basketCount;
  jobRepo.ebag = jobRepo.ecoBagCount;
  jobRepo.sako = jobRepo.sakoCount;

  // if (jobRepo.selectedOnGoingStatus == processWaiting) {
  //   jobRepo.processStep = 'waiting';
  // }
  // if (jobRepo.selectedOnGoingStatus == processWashing) {
  //   jobRepo.processStep = 'washing';
  // }
  // if (jobRepo.selectedOnGoingStatus == processDrying) {
  //   jobRepo.processStep = 'drying';
  // }
  // if (jobRepo.selectedOnGoingStatus == processFolding) {
  //   jobRepo.processStep = 'folding';
  // }

  jobRepo.processStep = jobRepo.selectedOnGoingStatus;
}

//########################################################################//
//                                                                        //
//                            CALL DATABASE                               //
//                                                                        //
//########################################################################//

Future<void> setSuppliesRepository(BuildContext context) async {
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

Future<void> callDatabaseGCashPendingAdd(
    BuildContext context, GCashModel gM) async {
  DatabaseGCashPending databaseGCashPending = DatabaseGCashPending();

  if (await databaseGCashPending.addBool(gM)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insert on GCash Pending done.')),
    );

    notifyAllUsers(
      title: gM.itemName,
      body: "${gM.customerName} ₱${gM.customerAmount}",
      url: "https://wash-ko-lang-sit.web.app/#/scan?empId=${gM.logBy}",
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error insert GCash Pending.')),
    );
  }
}

//laundry payment
Future<void> setRepositoryLaundryPayment(
    BuildContext context, String viaJobs, JobModelRepository jobRepo) async {
  //generate only when funds received ( paidCash, partialPaidCash )
  //only PaidCash or PartialPaidCash
  if (jobRepo.paidCash) {
    //auto generated for Laundry payment, once user tag job to paid.
    SuppliesHistRepository.instance.setItemName(getItemNameOnly(
        menuOthCashInOutFunds, menuOthLaundryPayment)); //cash laundry payment
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance
        .setItemUniqueId(menuOthLaundryPayment); //cash laundry payment
    SuppliesHistRepository.instance.setRemarks('auto via $viaJobs paid');

    // if (jobRepo.partialPaidCash) {
    //   SuppliesHistRepository.instance
    //       .setCurrentCounter(jobRepo.partialPaidCashAmount);
    // } else {
    //   SuppliesHistRepository.instance.setCurrentCounter(jobRepo.finalPrice);
    // }

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

    // if (jobRepo.partialPaidCashAmount > 0) {
    //   SuppliesHistRepository.instance
    //       .setCurrentCounter(jobRepo.partialPaidCashAmount);
    // } else {
    //   SuppliesHistRepository.instance.setCurrentCounter(jobRepo.finalPrice);
    // }

    await setSuppliesRepository(context);
  }
}

Future<void> callDatabaseUpdateJob(BuildContext context, JobModel jM) async {
  if (jM.processStep == 'done') {
    DatabaseJobsDone dbJ = DatabaseJobsDone();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on job done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs Done.')),
      );
    }
  } else if (jM.processStep == 'waiting' ||
      jM.processStep == 'washing' ||
      jM.processStep == 'drying' ||
      jM.processStep == 'folding') {
    DatabaseJobsOngoing dbJ = DatabaseJobsOngoing();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on-going done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On-Going.')),
      );
    }
  } else {
    DatabaseJobsQueue dbJ = DatabaseJobsQueue();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on Queue done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On Queue.')),
      );
    }
  }
}

Future<Uint8List?> pickImageUniversal() async {
  if (kIsWeb) {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;

    final file = uploadInput.files?.first;
    if (file == null) return null;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    return reader.result as Uint8List;
  } else {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;

    return await picked.readAsBytes();
  }
}

Future<Uint8List> compressImage(Uint8List bytes) async {
  final compressed = await FlutterImageCompress.compressWithList(
    bytes,
    minWidth: 900, // resize width
    quality: 65, // 0–100 (65 is good balance)
    format: CompressFormat.jpeg,
  );

  return compressed;
}

Future<void> callPickImageUniversal(
    BuildContext context, GCashModel gM, bool bCashIn) async {
  final bytes = await pickImageUniversal();

  if (bytes == null) return;

  DatabaseGCashPending databaseGCashPending = DatabaseGCashPending();
  await databaseGCashPending.saveImageUrl(gM, bytes);
}

Future<String?> uploadToCloudinaryBytes(Uint8List bytes) async {
  const cloudName = 'dxdskr55w';
  const uploadPreset = 'gcash_unsigned';

  final dio = Dio();

  final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  FormData formData = FormData.fromMap({
    "file": MultipartFile.fromBytes(
      bytes,
      filename: "upload.jpg",
    ),
    "upload_preset": uploadPreset,
  });

  final response = await dio.post(url, data: formData);

  if (response.statusCode == 200) {
    return response.data['secure_url'];
  }

  return null;
}

// TOKENS //

Future<void> registerWebToken(String empId) async {
  try {
    if (!kIsWeb) return; // Only needed for Web

    // Ask permission
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("Notification permission not granted");
      return;
    }

    print("Notification permission granted");

    // Get token
    final token = await messaging.getToken(
      vapidKey:
          "BA9ojQB79PiK84UardJeRfsk_okHsBHG763k_TgqbdF7cMkh_qnxKwrv84byD2XjU3sGLF4PHgaR-yjb_gfn4Zs",
    );

    if (token == null) return;

    // Prevent duplicate saves
    if (cachedToken == token) {
      print("Token unchanged. Skipping update.");
      return;
    }

    cachedToken = token;

    print("FCM TOKEN: $token");

    saveTokenToFirestore(empId, token);
  } catch (e) {
    print("FCM INIT ERROR: $e");
  }
}

Future<void> saveTokenToFirestore(String empId, String token) async {
  await FirebaseFirestore.instance.collection("users").doc(empId).set({
    "fcmToken": token,
    "updatedAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  print("Token saved to Firestore");
}

// NOTIFICATIONS //
Future<void> notifyAllUsers({
  required String title,
  required String body,
  required String url,
}) async {
  final snap = await FirebaseFirestore.instance.collection('users').get();

  List<String> tokens = [];

  for (var user in snap.docs) {
    final data = user.data();
    final token = data['fcmToken'];

    if (token != null && token is String) {
      tokens.add(token);
    }
  }

  if (tokens.isEmpty) {
    print("No tokens found. Skipping notification.");
    return;
  }

  final response = await http.post(
    Uri.parse("https://laundry-push-server.onrender.com/send"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tokens': tokens,
      'title': title,
      'body': body,
      'url': url,
    }),
  );

  if (response.statusCode == 200) {
    print("Push sent successfully");
  } else {
    print("Push failed: ${response.body}");
  }
}
