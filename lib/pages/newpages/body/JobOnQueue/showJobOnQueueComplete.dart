import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_ble.dart';
import 'package:laundry_firebase/variables/newvariables/variables_det.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

void showJobOnQueue(BuildContext context, JobModelRepository jobRepo) {
  void syncThisShowToSelected() {
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
    if (jobRepo.addOn) jobRepo.selectedPackage = othersPackage;

    //prices
    if (jobRepo.addOn) {
      jobRepo.totalPriceOthers = jobRepo.finalPrice;
      jobRepo.totalPriceRegSS = 0;
    } else {
      jobRepo.totalPriceRegSS = jobRepo.finalPrice;
      jobRepo.totalPriceOthers = 0;
    }

    //payment status
    if (jobRepo.unpaid) jobRepo.selectedPaidUnpaid = unpaid;
    if (jobRepo.paidCash) jobRepo.selectedPaidUnpaid = paidCash;
    if (jobRepo.paidGCash) jobRepo.selectedPaidUnpaid = paidGCash;
    jobRepo.selectedPaidPartialCash = jobRepo.partialPaidCash;
    jobRepo.selectedPaidPartialGCash = jobRepo.partialPaidGCash;
    jobRepo.partialCashAmountVar.text =
        jobRepo.partialPaidCashAmount.toString();
    jobRepo.partialGCashAmountVar.text =
        jobRepo.partialPaidGCashAmount.toString();

    //verified gcash
    jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;

    //weight status
    if (jobRepo.perKilo) jobRepo.isPerKg = true;
    if (jobRepo.perLoad) jobRepo.isPerKg = false;

    jobRepo.quantityKg = jobRepo.finalKilo;
    jobRepo.quantityLoad = jobRepo.finalLoad;
    jobRepo.remarksVar.text = jobRepo.remarks;

    //list other items
    jobRepo.listSelectedItemModel = jobRepo.items;

    //other options
    jobRepo.selectedFold = jobRepo.fold;
    jobRepo.selectedMix = jobRepo.mix;
    jobRepo.basketCount = jobRepo.basket;
    jobRepo.ecoBagCount = jobRepo.ebag;
    jobRepo.sakoCount = jobRepo.sako;

    if (jobRepo.selectedPackage != othersPackage) {
      jobRepo.addFabCount = jobRepo.listSelectedItemModel
          .where((e) => e.itemUniqueId == addFabAnyItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraDryCount = jobRepo.listSelectedItemModel
          .where((e) => e.itemUniqueId == xDItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraWashCount = jobRepo.listSelectedItemModel
          .where((e) => e.itemUniqueId == xWashItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraSpinCount = jobRepo.listSelectedItemModel
          .where((e) => e.itemUniqueId == xSpinItemModel.itemUniqueId)
          .length;
    } else {
      jobRepo.addFabCount = 0;
      jobRepo.addExtraDryCount = 0;
      jobRepo.addExtraWashCount = 0;
      jobRepo.addExtraSpinCount = 0;
    }
  }

  Visibility visCustomerName(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: decoAmber(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Label + Checkbox on same row
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                children: [],
              ),
            ),
            AutoCompleteCustomer(
              jobRepo: jobRepo,
            ),
            SizedBox(
              height: 5,
            ),
            MaterialButton(
              color: cButtons,
              onPressed: () {
                Navigator.pop(context);
                allCardsVar(context);
              },
              child: Text("New Account"),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  Visibility visRiderPickup(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Initial Status',
              style: TextStyle(fontSize: 11),
            ),
            ToggleButtons(
              isSelected: List.generate(
                listRiderPickup.length,
                (i) => jobRepo.selectedRiderPickup == listRiderPickup[i],
              ),
              onPressed: (index) {
                setState(() {
                  jobRepo.selectedRiderPickup = listRiderPickup[index];
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 80,
                minHeight: 25,
              ),
              children: const [
                Text('For Sorting'),
                Text('Rider Pickup'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility visSelectPackage(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Package Status',
              style: TextStyle(fontSize: 11),
            ),
            ToggleButtons(
              isSelected: List.generate(
                listPackage.length,
                (i) => jobRepo.selectedPackage == listPackage[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (jobRepo.selectedPackagePrev == othersPackage &&
                      jobRepo.listSelectedItemModel.isNotEmpty) {
                    showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text(
                            'Added items in All Services\nwill be delete?',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  jobRepo.selectedPackage = othersPackage;
                                });

                                Navigator.pop(context, false);
                              },
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  jobRepo.selectedPackage = listPackage[index];
                                  jobRepo.selectedPackagePrev =
                                      listPackage[index];
                                  jobRepo.listSelectedItemModel.clear();
                                  jobRepo.totalPriceOthers = 0;
                                });

                                Navigator.pop(context, true);
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      jobRepo.selectedPackage = listPackage[index];
                      jobRepo.selectedPackagePrev = listPackage[index];
                      if (jobRepo.selectedPackage == othersPackage) {
                        jobRepo.selectedItemModel = listOthItems[0];
                      }
                    });
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 75,
                minHeight: 25,
              ),
              children: const [
                Text('Regular'),
                Text('Sayo Sabon', style: TextStyle(fontSize: 12)),
                Text(
                  'All Services',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAmountRegSSPerKg(Function setState) {
    jobRepo.pricePerSet = prices[jobRepo.selectedPackage] ?? 155;
    jobRepo.maxPartial = maxPartialOptions[jobRepo.selectedPackage] ?? 3;
    // 🧠 UI rules

    final bool showPointOne = jobRepo.quantityKg >= 8 &&
        (jobRepo.quantityKg % 8) < jobRepo.maxPartial;

    jobRepo.totalPriceRegSS = computeTotalPrice(jobRepo.quantityKg, jobRepo) +
        jobRepo.totalPriceShortCutRegSS;

    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.quantityKg += 1;
        jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      });
    }

    void incrementPointOne() {
      setState(() {
        jobRepo.quantityKg =
            double.parse((jobRepo.quantityKg + 0.1).toStringAsFixed(1));
        //if (quantityKg > 11.0) quantityKg = 11.0;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.quantityKg -= 1;
        if (jobRepo.quantityKg < 1) jobRepo.quantityKg = 1;
        jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      });
    }

    return Visibility(
      visible:
          (jobRepo.selectedPackage == othersPackage ? false : jobRepo.isPerKg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔷 Accent header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // 💰 Price (read-only display)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Text(
                          showHowMany155or125Set(
                              computeTotalPrice(jobRepo.quantityKg, jobRepo),
                              true,
                              jobRepo),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              formatter.format(jobRepo.totalPriceRegSS),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3), // 👈 distance from text
                            Container(
                              height: 2, // underline thickness
                              width: 80, // underline length
                              color: Colors.black,
                            ),
                            const SizedBox(height: 1),
                            Container(
                              height: 2, // underline thickness
                              width: 80, // underline length
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        showHowMany155or125Set(
                            computeTotalPrice(jobRepo.quantityKg, jobRepo),
                            true,
                            jobRepo),
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 📦 Quantity (read-only display)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${jobRepo.quantityKg.toStringAsFixed(
                            jobRepo.quantityKg % 1 == 0 ? 0 : 1,
                          )} kg',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 2, // underline thickness
                          width: 80, // underline length
                          color: Colors.black,
                        ),
                        Container(
                          decoration: decoGreenAccentNoBorder(),
                          child: boxButton2label(
                            label: 'kg ',
                            label2: 'load',
                            boldLabel2: false,
                            onTap: () {
                              setState(() {
                                jobRepo.isPerKg = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ➖➕ Unit-based controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  boxButton(
                    label: '−1',
                    disabled: jobRepo.quantityKg <= 1,
                    onTap: decrementOne,
                  ),

                  // Visibility(
                  //   visible: showPointOne,
                  //   child: Row(
                  //     children: [
                  //       const SizedBox(width: 6),
                  //       boxButton(
                  //         label: '+0.1',
                  //         onTap: incrementPointOne,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(width: 6),
                  boxButton(
                    label: '+1',
                    onTap: incrementOne,
                  ),
                  const SizedBox(width: 6),
                  Visibility(
                    visible: showPointOne,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: boxButton(
                      label: '+0.1',
                      onTap: incrementPointOne,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAmountRegSSPerLoad(Function setState) {
    const prices = {
      regularPackage: 155,
      sayoSabonPackage: 125,
      othersPackage: 0,
    };

    jobRepo.pricePerSet = prices[jobRepo.selectedPackage] ?? 155;
    // 🧠 UI rules

    jobRepo.totalPriceRegSS = (jobRepo.pricePerSet * jobRepo.quantityLoad) +
        jobRepo.totalPriceShortCutRegSS;

    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.quantityLoad += 1;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.quantityLoad -= 1;
      });
    }

    return Visibility(
      visible:
          (jobRepo.selectedPackage == othersPackage ? false : !jobRepo.isPerKg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔷 Accent header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // 💰 Price (read-only display)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              formatter.format(jobRepo.totalPriceRegSS),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3), // 👈 distance from text
                            Container(
                              height: 2, // underline thickness
                              width: 80, // underline length
                              color: Colors.black,
                            ),
                            const SizedBox(height: 1),
                            Container(
                              height: 2, // underline thickness
                              width: 80, // underline length
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      // Visibility(
                      //   visible: false,
                      //   maintainSize: true,
                      //   maintainAnimation: true,
                      //   maintainState: true,
                      //   child: boxButton(
                      //     label: '−1',
                      //     disabled: quantityLoad <= 1,
                      //     onTap: decrementOne,
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 📦 Quantity (read-only display)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${jobRepo.quantityLoad} load',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 2, // underline thickness
                          width: 80, // underline length
                          color: Colors.black,
                        ),
                        Container(
                          decoration: decoGreenAccentNoBorder(),
                          child: boxButton2label(
                            label: 'kg ',
                            label2: 'load',
                            boldLabel2: true,
                            onTap: () {
                              setState(() {
                                jobRepo.isPerKg = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ➖➕ Unit-based controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  boxButton(
                    label: '−1',
                    disabled: jobRepo.quantityLoad <= 1,
                    onTap: decrementOne,
                  ),
                  const SizedBox(width: 6),
                  boxButton(
                    label: '+1',
                    onTap: incrementOne,
                  ),
                  const SizedBox(width: 6),
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: boxButton(
                      label: '+0.1',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAmountOthersOnly(Function setState) {
    void addOtherItem(OtherItemModel item) {
      jobRepo.listSelectedItemModel.add(item);
      jobRepo.totalPriceOthers += item.itemPrice;
    }

    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6), // 👈 distance from text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Text(
                    formatter.format(jobRepo.totalPriceOthers),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3), // 👈 distance from text
                  Container(
                    height: 2, // underline thickness
                    width: 80, // underline length
                    color: Colors.black,
                  ),
                  const SizedBox(height: 1),
                  Container(
                    height: 2, // underline thickness
                    width: 80, // underline length
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),
            Text('Shortcuts',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),

            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(1.0),
              //decoration: decoDarkBlue(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                    isSelected: List.generate(
                      listOthersDropDownShortCuts.length,
                      (i) =>
                          jobRepo.selectedOthersShortCut ==
                          listOthersDropDownShortCuts[i],
                    ),
                    onPressed: (index) {
                      setState(() {
                        jobRepo.selectedOthersShortCut =
                            listOthersDropDownShortCuts[index];
                        if (jobRepo.selectedOthersShortCut == menuOth155) {
                          addOtherItem(reg155ItemModel);
                        }
                        if (jobRepo.selectedOthersShortCut == menuOth125) {
                          addOtherItem(reg125ItemModel);
                        }
                        if (jobRepo.selectedOthersShortCut == menuOthXD) {
                          addOtherItem(xDItemModel);
                        }
                        if (jobRepo.selectedOthersShortCut ==
                            menuFabWKLDValAny8ml) {
                          addOtherItem(addFabAnyItemModel);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.black,
                    fillColor: Colors.pinkAccent[100],
                    color: Colors.black,
                    borderColor: cSalaryOut,
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 25,
                    ),
                    children: const [
                      Text('155'),
                      Text('125'),
                      Text('+Dry'),
                      Text('+Fab'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6), // 👈 distance from text
            Text('All Items',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(1.0),
              decoration: decoDarkBlue(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                    isSelected: List.generate(
                      listOthersDropDown.length,
                      (i) => jobRepo.selectedOthers == listOthersDropDown[i],
                    ),
                    onPressed: (index) {
                      setState(() {
                        jobRepo.selectedOthers = listOthersDropDown[index];
                        (jobRepo.selectedOthers == menuOthDVal
                            ? jobRepo.selectedItemModel = listOthItems[0]
                            : jobRepo.selectedOthers == menuDetDVal
                                ? jobRepo.selectedItemModel = listDetItems[0]
                                : jobRepo.selectedOthers == menuFabDVal
                                    ? jobRepo.selectedItemModel =
                                        listFabItems[0]
                                    : jobRepo.selectedItemModel =
                                        listBleItems[0]);
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.black,
                    fillColor: Colors.pinkAccent[100],
                    color: Colors.black,
                    borderColor: cSalaryOut,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 25,
                    ),
                    children: const [
                      Text('Oth'),
                      Text('Det'),
                      Text('Fab'),
                      Text('Ble'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40, // compact height
                          child: DropdownButtonFormField<OtherItemModel>(
                            isDense: true,
                            iconSize: 18,
                            dropdownColor:
                                const Color.fromARGB(255, 252, 162, 192),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                              filled: true, // enables background color
                              fillColor: Color.fromARGB(255, 255, 144, 181),
                            ),
                            hint: const Text(
                              'Select supply',
                              style: TextStyle(fontSize: 12),
                            ),
                            initialValue: (jobRepo.selectedOthers == menuOthDVal
                                ? listOthItems[0]
                                : jobRepo.selectedOthers == menuDetDVal
                                    ? listDetItems[0]
                                    : jobRepo.selectedOthers == menuFabDVal
                                        ? listFabItems[0]
                                        : listBleItems[0]),
                            items: (jobRepo.selectedOthers == menuOthDVal
                                    ? listOthItems
                                    : jobRepo.selectedOthers == menuDetDVal
                                        ? listDetItems
                                        : jobRepo.selectedOthers == menuFabDVal
                                            ? listFabItems
                                            : listBleItems)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      '${e.itemName}  ₱${e.itemPrice}',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() => jobRepo.selectedItemModel = val!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              addOtherItem(jobRepo.selectedItemModel);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent[100]),
                          child: const Text(
                            'Add',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  /// 🧾 Selected Items Preview
                  Column(
                    children: jobRepo.listSelectedItemModel.map((e) {
                      return Container(
                        decoration: decoPinkAccent(),
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Row(
                          children: [
                            // Remove button
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  jobRepo.totalPriceOthers -= e.itemPrice;
                                  jobRepo.listSelectedItemModel.remove(e);
                                });
                              },
                            ),

                            // LEFT TEXT (can move right)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  e.itemName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),

                            // RIGHT PRICE (can move left)
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                '₱${e.itemPrice}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Visibility visPaidUnPaid(Function setState) {
    final List<int> listPaidUnpaid = [
      unpaid,
      paidCash,
      paidGCash,
    ];

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 0,
          children: [
            Text(
              'Payment Status',
              style: TextStyle(fontSize: 11),
            ),
            ToggleButtons(
              isSelected: List.generate(
                listPaidUnpaid.length,
                (i) => jobRepo.selectedPaidUnpaid == listPaidUnpaid[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (jobRepo.selectedPaidUnpaid == listPaidUnpaid[index]) {
                    jobRepo.selectedPaidUnpaid = 0;
                  } else {
                    jobRepo.selectedPaidUnpaid = listPaidUnpaid[index];
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 60,
                minHeight: 25,
              ),
              children: const [
                Text('Unpaid', style: TextStyle(fontSize: 11)),
                Text('Paid Cash', style: TextStyle(fontSize: 11)),
                Text('Paid GCash', style: TextStyle(fontSize: 10)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Partial\ncash?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: jobRepo.selectedPaidPartialCash,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidPartialCash = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Partial\nGCash?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: jobRepo.selectedPaidPartialGCash,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidPartialGCash = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 2,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GCash\nverified?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: jobRepo.selectedPaidGCashVerified,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidGCashVerified = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 4,
            ),
            //Partial Cash Amount
            Visibility(
              visible: jobRepo.selectedPaidPartialCash,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label (not indented)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Partial Cash Amount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: jobRepo.partialCashAmountVar,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'\d+(\.\d{0,2})?')),
                    ],
                    style: const TextStyle(fontSize: 12), // shrink text size
                    decoration: InputDecoration(
                      isDense: true, // 🔹 makes the field more compact
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: '0.00',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: const OutlineInputBorder(),
                      filled: true, // 🔹 enable background fill
                      fillColor: Colors.white, // 🔹 set background to white
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 24, // 🔹 narrower prefix space
                        minHeight: 24,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          '₱',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 2,
            ),
            //Partial GCash Amount
            Visibility(
              visible: jobRepo.selectedPaidPartialGCash,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label (not indented)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Partial GCash Amount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: jobRepo.partialGCashAmountVar,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'\d+(\.\d{0,2})?')),
                    ],
                    style: const TextStyle(fontSize: 12), // shrink text size
                    decoration: InputDecoration(
                      isDense: true, // 🔹 makes the field more compact
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: '0.00',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: const OutlineInputBorder(),
                      filled: true, // 🔹 enable background fill
                      fillColor: Colors.white, // 🔹 set background to white
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 24, // 🔹 narrower prefix space
                        minHeight: 24,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          '₱',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visFold(Function setState) {
    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected: [
                jobRepo.selectedFold, // Fold
                !jobRepo.selectedFold, // No Fold
              ],
              onPressed: (index) {
                setState(() {
                  // single source of truth
                  jobRepo.selectedFold = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 80,
                minHeight: 25,
              ),
              children: const [
                Text('Fold'),
                Text('No Fold'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility visMix(Function setState) {
    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected: [
                jobRepo.selectedMix, // Fold
                !jobRepo.selectedMix, // No Fold
              ],
              onPressed: (index) {
                setState(() {
                  // single source of truth
                  jobRepo.selectedMix = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 80,
                minHeight: 25,
              ),
              children: const [
                Text('Mix'),
                Text('Dont Mix'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility visBasket(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.basketCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.basketCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (jobRepo.basketCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1',
                disabled: jobRepo.basketCount <= 0,
                onTap: decrementOne),
            const SizedBox(width: 12),

            // 🧺 basket : x
            Text(
              'Basket : ${jobRepo.basketCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),
            boxButton(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visEcoBag(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.ecoBagCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.ecoBagCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (jobRepo.ecoBagCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1',
                disabled: jobRepo.ecoBagCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              'EcoBag : ${jobRepo.ecoBagCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButton(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visSako(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.sakoCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.sakoCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (jobRepo.sakoCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1',
                disabled: jobRepo.sakoCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              'Sako : ${jobRepo.sakoCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButton(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visAddFab(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.addFabCount += 1;
        jobRepo.listSelectedItemModel.add(addFabAnyItemModel);
        jobRepo.totalPriceShortCutRegSS += addFabAnyItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.addFabCount -= 1;
        jobRepo.listSelectedItemModel.remove(addFabAnyItemModel);
        jobRepo.totalPriceShortCutRegSS -= addFabAnyItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (jobRepo.addFabCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: jobRepo.addFabCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Fab(₱${addFabAnyItemModel.itemPrice}): ${jobRepo.addFabCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButtonOtherItems(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visAddDry(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.addExtraDryCount += 1;
        jobRepo.listSelectedItemModel.add(xDItemModel);
        jobRepo.totalPriceShortCutRegSS += xDItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.addExtraDryCount -= 1;
        jobRepo.listSelectedItemModel.remove(xDItemModel);
        jobRepo.totalPriceShortCutRegSS -= xDItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (jobRepo.addExtraDryCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: jobRepo.addExtraDryCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Dry(₱${xDItemModel.itemPrice}): ${jobRepo.addExtraDryCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButtonOtherItems(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visAddWash(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.addExtraWashCount += 1;
        jobRepo.listSelectedItemModel.add(xWashItemModel);
        jobRepo.totalPriceShortCutRegSS += xWashItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.addExtraWashCount -= 1;
        jobRepo.listSelectedItemModel.remove(xWashItemModel);
        jobRepo.totalPriceShortCutRegSS -= xWashItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (jobRepo.addExtraWashCount > 0
            ? decoOtherItems()
            : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: jobRepo.addExtraWashCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Wash(₱${xWashItemModel.itemPrice}): ${jobRepo.addExtraWashCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButtonOtherItems(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Visibility visAddSpin(Function setState) {
    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        jobRepo.addExtraSpinCount += 1;
        jobRepo.listSelectedItemModel.add(xSpinItemModel);
        jobRepo.totalPriceShortCutRegSS += xSpinItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        jobRepo.addExtraSpinCount -= 1;
        jobRepo.listSelectedItemModel.remove(xSpinItemModel);
        jobRepo.totalPriceShortCutRegSS -= xSpinItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (jobRepo.selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (jobRepo.addExtraSpinCount > 0
            ? decoOtherItems()
            : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: jobRepo.addExtraSpinCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Spin(₱${xSpinItemModel.itemPrice}): ${jobRepo.addExtraSpinCount} pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            boxButtonOtherItems(label: '+1', onTap: incrementOne),
          ],
        ),
      ),
    );
  }

  Container conRemarks(Function setState) {
    return Container(
      padding: EdgeInsets.all(1.0),
      decoration: decoAmber(),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.start,
        controller: jobRepo.remarksVar,
        decoration: InputDecoration(labelText: 'Remarks', hintText: 'Notes'),
        validator: (val) {
          jobRepo.remarksVar.text = val!;
        },
      ),
    );
  }

  Future<void> saveButtonSetRepository() async {
//dates
    /// 🟣 Dates
    jobRepo.dateQ = Timestamp.now();

    setSelectedToRepository(jobRepo);

    await callDatabaseJobQueueUpdate(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  syncThisShowToSelected();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          contentPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.only(
            top: 0,
            left: 5,
            right: 5,
            bottom: 0,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          title: Text(
            "Enter Laundry",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    visCustomerName(setState),
                    visRiderPickup(setState),
                    visSelectPackage(setState),
                    (jobRepo.isPerKg
                        ? visAmountRegSSPerKg(setState)
                        : visAmountRegSSPerLoad(setState)),
                    visAmountOthersOnly(setState),
                    visPaidUnPaid(setState),
                    Text(
                      'Other Options',
                      style: TextStyle(fontSize: 11),
                    ),
                    visFold(setState),
                    visMix(setState),
                    visBasket(setState),
                    visEcoBag(setState),
                    visSako(setState),
                    Text(
                      'Add Ons',
                      style: TextStyle(fontSize: 11),
                    ),
                    visAddDry(setState),
                    visAddFab(setState),
                    visAddWash(setState),
                    visAddSpin(setState),
                    conRemarks(setState),
                  ],
                ),
              ),
            ),
          ),
          // 👇 Bottom buttons
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close popup
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await saveButtonSetRepository();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
