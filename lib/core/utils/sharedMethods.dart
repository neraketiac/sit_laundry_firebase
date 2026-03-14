import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
      jobRepo.repoVarBasePriceAmount + tier1Increase,
      jobRepo.repoVarBasePriceAmount + tier2Increase
    ];

    // Base single
    if (total == jobRepo.repoVarBasePriceAmount) {
      return ' ${jobRepo.repoVarBasePriceAmount}';
    }

    // Extras alone
    if (extras.contains(total)) return ' $total';

    for (final extra in [0, ...extras]) {
      final remaining = total - extra;

      if (remaining <= 0) continue;
      if (remaining % jobRepo.repoVarBasePriceAmount != 0) continue;

      final multiplier = remaining ~/ jobRepo.repoVarBasePriceAmount;

      if (multiplier == 1 && extra == 0) {
        return ' ${jobRepo.repoVarBasePriceAmount}';
      }

      if (multiplier == 1 && extra != 0) {
        return ' ${jobRepo.repoVarBasePriceAmount}\n + $extra';
      }

      if (multiplier > 1 && extra == 0) {
        return ' (${jobRepo.repoVarBasePriceAmount} * $multiplier)';
      }

      if (multiplier > 1 && extra != 0) {
        if (bSeparate) {
          return ' (${jobRepo.repoVarBasePriceAmount} * $multiplier)\n + $extra';
        } else {
          return ' (${jobRepo.repoVarBasePriceAmount} * $multiplier) + $extra';
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
      remainingPrice = jobRepo.repoVarBasePriceAmount;
    }
//    debugPrint('c=$counter rP=$remainingPrice r=$remaining');
  }

  return (counter * jobRepo.repoVarBasePriceAmount) + remainingPrice;
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
  required Color color,
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
          color: color,
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
//                            REPOS                                       //
//                                                                        //
//########################################################################//

String textJobStatus(JobModel jM) {
  if (jM.processStep == '') {
    if (jM.forSorting) {
      return 'For Sorting\n${DateFormat('MMM dd').format(jM.dateQ.toDate())}';
    }
    if (jM.riderPickup) {
      return 'Rider Pickup\n${DateFormat('MMM dd').format(jM.dateQ.toDate())}';
    }
  } else {
    if (jM.processStep == 'done' || jM.processStep == 'completed') {
      if (jM.riderPickup) {
        if (jM.isDeliveredToCustomer) {
          return '${jM.processStep} 🚲 delivered\n${DateFormat('MMM dd').format(jM.riderDeliveryDate.toDate())}/${DateFormat('MMM dd').format(jM.dateD.toDate())}';
        } else {
          return '${jM.processStep} 🚲 for delivery\n${DateFormat('MMM dd').format(jM.dateD.toDate())}';
        }
      } else {
        if (jM.isCustomerPickedUp) {
          return '${jM.processStep} 🛒 pickedup\n${DateFormat('MMM dd').format(jM.customerPickupDate.toDate())}/${DateFormat('MMM dd').format(jM.dateD.toDate())}';
        } else {
          return '${jM.processStep} 🛒 wait customer\n${DateFormat('MMM dd').format(jM.dateD.toDate())}';
        }
      }
    } else {
      return jM.processStep;
    }
  }

  return 'no status';
}

String textPricingSetupRemarksUnpaidRemakrs(JobModel jM) {
  String unpaidDetails = '';
  if (jM.unpaid) {
    if (jM.paidCash && jM.paidGCash) {
      if (jM.paidGCashverified) {
        unpaidDetails = 'Cash+GCash not enough';
      } else {
        unpaidDetails = 'Cash+GCash not verified';
      }
    } else if (jM.paidCash) {
      unpaidDetails = 'Cash not enough';
    } else if (jM.paidGCash) {
      if (jM.paidGCashverified) {
        unpaidDetails = 'GCash not enough';
      } else {
        unpaidDetails = 'GCash pending';
      }
    }
  }
  //return '${jM.pricingSetup} ${jM.remarks} $unpaidDetails';

  return [
    jM.pricingSetup,
    jM.remarks,
    unpaidDetails,
  ].where((e) => e.trim().isNotEmpty).join(' ');
}

String displayCustomerName(String? name) {
  if (name == null || name.isEmpty) return '';
  return name.length > 12 ? name.substring(0, 12) : name;
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

String textDetFabBleExtras(List<OtherItemModel> listItems) {
  final List<String> parts = [];

  /// 🔁 Group item names and count
  // if (jM.items != null && jM.items!.isNotEmpty) {
  final Map<String, int> itemCounts = {};

  // for (final item in jM.items!) {
  for (final item in listItems) {
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
  // }

  return parts.join(' ');
}

//reset payment
void resetPaymentStatus(JobModelRepository jobRepo) {
  jobRepo.selectedUnpaid = true;
  jobRepo.selectedPaidCash = false;
  jobRepo.selectedPaidGCash = false;
  jobRepo.repoVarCashAmountVar.text = '';
  jobRepo.repoVarCashAmountVar.text = '';
}

// //only all edit should call this
// void syncRepoToSelectedALL(JobModelRepository jobRepo) {
//   //1 admin
//   jobRepo.currentEmpId = empIdGlobal;

//   //2 customer
//   jobRepo.selectedCustomerNameVar.text = jobRepo.customerName;

//   //3 queue status
//   if (jobRepo.riderPickup) {
//     jobRepo.repoVarSelectedIntRiderPickup = intRiderPickup;
//   }
//   if (jobRepo.forSorting) jobRepo.repoVarSelectedIntRiderPickup = intForSorting;

//   //4 package status
//   if (jobRepo.regular) jobRepo.selectedPackage = intRegularPackage;
//   if (jobRepo.sayosabon) jobRepo.selectedPackage = intSayoSabonPackage;
//   if (jobRepo.addOn) {
//     jobRepo.selectedPackage = intOthersPackage;
//     jobRepo.selectedPackagePrev = intOthersPackage;
//   }

//   //5 prices
//   if (jobRepo.addOn) {
//     jobRepo.repoVarTotalPriceOthers = jobRepo.finalPrice;
//     jobRepo.repoVarTotalPriceRegSS = 0;
//   } else {
//     jobRepo.repoVarTotalPriceRegSS = jobRepo.finalPrice;
//     jobRepo.repoVarTotalPriceOthers = 0;
//   }

//   //6 payment status
//   // jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;

//   //6 payment status
//   jobRepo.repoVarCashAmountVar.text = jobRepo.paidCashAmount.toString();
//   jobRepo.repoVarGCashAmountVar.text = jobRepo.paidGCashAmount.toString();

//   //7 weight status
//   if (jobRepo.perKilo) jobRepo.selectedPerKilo = true;
//   if (jobRepo.perLoad) jobRepo.selectedPerKilo = false;

//   jobRepo.selectedFinalKilo = jobRepo.finalKilo;
//   jobRepo.selectedFinalLoad = jobRepo.finalLoad;

//   //8 list other items
//   jobRepo.selectedItems = List.from(jobRepo.items);
//   jobRepo.repoVarTotalPriceShortCutRegSS = jobRepo.items.fold(
//     0,
//     (sum, item) => sum + item.itemPrice,
//   );

//   //10 extras
//   if (jobRepo.selectedPackage != intOthersPackage) {
//     jobRepo.repoVarAddFabCount = jobRepo.items
//         .where((e) => e.itemUniqueId == addFabAnyItemModel.itemUniqueId)
//         .length;
//     jobRepo.repoVarAddExtraDryCount = jobRepo.items
//         .where((e) => e.itemUniqueId == xDItemModel.itemUniqueId)
//         .length;
//     jobRepo.repoVarAddExtraWashCount = jobRepo.items
//         .where((e) => e.itemUniqueId == xWashItemModel.itemUniqueId)
//         .length;
//     jobRepo.repoVarAddExtraSpinCount = jobRepo.items
//         .where((e) => e.itemUniqueId == xSpinItemModel.itemUniqueId)
//         .length;
//   } else {
//     jobRepo.repoVarAddFabCount = 0;
//     jobRepo.repoVarAddExtraDryCount = 0;
//     jobRepo.repoVarAddExtraWashCount = 0;
//     jobRepo.repoVarAddExtraSpinCount = 0;
//   }

//   //12 Remarks
//   jobRepo.selectedRemarksVar.text = jobRepo.remarks;
// }

// void syncRepoToSelectedSmall(JobModelRepository jobRepo) {
//   //2 customer
//   jobRepo.selectedCustomerNameVar.text = jobRepo.customerName;

//   //3 queue status
//   if (jobRepo.riderPickup) {
//     jobRepo.repoVarSelectedIntRiderPickup = intRiderPickup;
//   }
//   if (jobRepo.forSorting) jobRepo.repoVarSelectedIntRiderPickup = intForSorting;

//   //6 payment status
//   jobRepo.repoVarCashAmountVar.text = jobRepo.paidCashAmount.toString();
//   jobRepo.repoVarGCashAmountVar.text = jobRepo.paidGCashAmount.toString();

//   //8 list other items
//   jobRepo.selectedItems = List.from(jobRepo.items);
//   jobRepo.repoVarTotalPriceShortCutRegSS = jobRepo.items.fold(
//     0,
//     (sum, item) => sum + item.itemPrice,
//   );

//   jobRepo.selectedRemarksVar.text = jobRepo.remarks;
// }

//set selected to repository
//only all edit should call this
// void syncSelectedToRepositoryALL(JobModelRepository jobRepo) {
//   int computePromoCounter = 0;
//   int computeLoadForKg(double kg) {
//     double remainder = kg % 8;
//     int wholeEight = kg ~/ 8;
//     int lastCounter = 0;
//     if (remainder < 1) {
//       lastCounter = 0;
//     } else {
//       lastCounter = 1;
//     }
//     if (remainder >= 3) {
//       computePromoCounter = wholeEight + 1;
//     } else {
//       computePromoCounter = wholeEight;
//     }

//     return wholeEight + lastCounter;
//   }

//   //1 admin
//   //jobRepo.selectedCurrentEmpId = empIdGlobal;

//   //2 customer
//   //set by autocomplete

//   //3 queue status
//   jobRepo.forSorting = intForSorting == jobRepo.repoVarSelectedIntRiderPickup;
//   //only true if still false
//   //once true, should always true
//   if ((intRiderPickup == jobRepo.repoVarSelectedIntRiderPickup)) {
//     jobRepo.riderPickup =
//         intRiderPickup == jobRepo.repoVarSelectedIntRiderPickup;
//   }

//   //4 package status
//   jobRepo.regular = intRegularPackage == jobRepo.selectedPackage;
//   jobRepo.sayosabon = intSayoSabonPackage == jobRepo.selectedPackage;
//   jobRepo.addOn = intOthersPackage == jobRepo.selectedPackage;

//   //5 prices
//   if (jobRepo.selectedPackage == intOthersPackage) {
//     jobRepo.finalPrice = jobRepo.repoVarTotalPriceOthers;
//   } else {
//     jobRepo.finalPrice = jobRepo.repoVarTotalPriceRegSS;
//   }

//   //6 payment status
//   jobRepo.unpaid = true;
//   jobRepo.paidCashAmount = int.tryParse(jobRepo.repoVarCashAmountVar.text) ?? 0;
//   jobRepo.paidGCashAmount =
//       int.tryParse(jobRepo.repoVarGCashAmountVar.text) ?? 0;
//   //check if paidCash is enough vs bill
//   if (jobRepo.paidCash) {
//     //received by
//     jobRepo.paymentReceivedBy = empIdGlobal;
//     if (jobRepo.paidCashAmount >= jobRepo.finalPrice) {
//       //paid
//       jobRepo.unpaid = false;
//     }
//   }

//   //7 weight status
//   jobRepo.perKilo = false;
//   jobRepo.perLoad = false;
//   if (jobRepo.selectedPerKilo) {
//     jobRepo.perKilo = true;
//     jobRepo.finalKilo = jobRepo.selectedFinalKilo;
//     jobRepo.finalLoad = computeLoadForKg(jobRepo.selectedFinalKilo);
//     debugPrint('jobRepo.finalLoad=${jobRepo.finalLoad}');
//     jobRepo.promoCounter = computePromoCounter;
//     jobRepo.pricingSetup = showHowMany155or125Set(
//         computeTotalPrice(jobRepo.selectedFinalKilo, jobRepo), false, jobRepo);
//   } else {
//     jobRepo.perLoad = true;
//     jobRepo.finalLoad = jobRepo.selectedFinalLoad;
//     jobRepo.promoCounter = jobRepo.selectedFinalLoad;
//     jobRepo.pricingSetup = 'Load(s): ${jobRepo.selectedFinalLoad}';
//   }

//   //8 list other items
//   if (jobRepo.selectedItems.isNotEmpty) {
//     jobRepo.items = List.from(jobRepo.selectedItems);
//   }

//   //12
//   jobRepo.remarks = jobRepo.selectedRemarksVar.text;
// }

// void syncSelectedToRepositorySmall(JobModelRepository jobRepo) {
//   //3 queue status
//   jobRepo.forSorting = intForSorting == jobRepo.repoVarSelectedIntRiderPickup;
//   //only true if still false
//   //once true, should always true
//   if (jobRepo.riderPickup ||
//       intRiderPickup == jobRepo.repoVarSelectedIntRiderPickup) {
//     jobRepo.riderPickup =
//         intRiderPickup == jobRepo.repoVarSelectedIntRiderPickup;
//   }

//   //6 payment status
//   jobRepo.unpaid = true;
//   // jobRepo.paidCash;
//   // jobRepo.paidGCash;
//   jobRepo.paidCashAmount = int.tryParse(jobRepo.repoVarCashAmountVar.text) ?? 0;
//   jobRepo.paidGCashAmount =
//       int.tryParse(jobRepo.repoVarGCashAmountVar.text) ?? 0;
//   //check if paidCash is enough vs bill
//   if (jobRepo.paidCash) {
//     //received by
//     jobRepo.paymentReceivedBy = empIdGlobal;
//     if (jobRepo.paidCashAmount >= jobRepo.finalPrice) {
//       //paid
//       jobRepo.unpaid = false;
//     }
//   }
// }

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

  if (await callDatabaseSuppliesCurrentAdd(
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

void addOtherItem(JobModelRepository jobRepo, OtherItemModel item) {
  jobRepo.selectedItems.add(item);
  jobRepo.repoVarTotalPriceOthers += item.itemPrice;
  debugPrint(
      'addOtherItem jobRepo.repoVarTotalPriceOthers=${jobRepo.repoVarTotalPriceOthers}');
}

void removeOtherItem(JobModelRepository jobRepo, OtherItemModel item) {
  jobRepo.selectedItems.remove(item);
  jobRepo.repoVarTotalPriceOthers -= item.itemPrice;
  debugPrint(
      'removeOtherItem jobRepo.repoVarTotalPriceOthers=${jobRepo.repoVarTotalPriceOthers}');
}
