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

Visibility visCustomerName(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visRiderPickup(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visSelectPackage(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
                  jobRepo.selectedPackage = listPackage[index];
                  jobRepo.selectedPackagePrev = listPackage[index];
                  if (jobRepo.selectedPackage == othersPackage) {
                    jobRepo.selectedItemModel = listOthItems[0];
                  }
                }
                resetPaymentStatus(jobRepo);
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

Visibility visAmountRegSSPerKg(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  jobRepo.pricePerSet = prices[jobRepo.selectedPackage] ?? 155;
  jobRepo.maxPartial = maxPartialOptions[jobRepo.selectedPackage] ?? 3;
  // 🧠 UI rules

  final bool showPointOne =
      jobRepo.quantityKg >= 8 && (jobRepo.quantityKg % 8) < jobRepo.maxPartial;

  jobRepo.totalPriceRegSS = computeTotalPrice(jobRepo.quantityKg, jobRepo) +
      jobRepo.totalPriceShortCutRegSS;

  // ➕➖ handlers
  void incrementOne() {
    setState(() {
      jobRepo.quantityKg += 1;
      jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      resetPaymentStatus(jobRepo);
    });
  }

  void incrementPointOne() {
    setState(() {
      jobRepo.quantityKg =
          double.parse((jobRepo.quantityKg + 0.1).toStringAsFixed(1));
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.quantityKg -= 1;
      if (jobRepo.quantityKg < 1) jobRepo.quantityKg = 1;
      jobRepo.quantityKg = jobRepo.quantityKg.floorToDouble();
      resetPaymentStatus(jobRepo);
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
                              resetPaymentStatus(jobRepo);
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}

Visibility visAmountRegSSPerLoad(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
      resetPaymentStatus(jobRepo);
    });
  }

  void decrementOne() {
    setState(() {
      jobRepo.quantityLoad -= 1;
      resetPaymentStatus(jobRepo);
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
                              resetPaymentStatus(jobRepo);
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}

Visibility visAmountOthersOnly(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
                                  ? jobRepo.selectedItemModel = listFabItems[0]
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

Visibility visPaidUnPaid(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
  // final List<int> listPaidUnpaid = [
  //   paidCash,
  //   paidGCash,
  // ];

  String returnPaymentStatusDuringToggle(bool paidCash, bool paidGCash) {
    if (paidCash && paidGCash) {
      jobRepo.partialCashAmountVar.text = '';
      jobRepo.partialGCashAmountVar.text = '';
      return 'Split payment';
    }
    if (paidCash) {
      jobRepo.partialGCashAmountVar.text = '';
      if (jobRepo.selectedPackage == othersPackage) {
        jobRepo.partialCashAmountVar.text = jobRepo.totalPriceOthers.toString();
      } else {
        jobRepo.partialCashAmountVar.text = jobRepo.totalPriceRegSS.toString();
      }
      //since this is auto match price, only on this case it will unpaid false.
      //true(unpaid) again once someone change the amount paid.
      jobRepo.unpaid = false;
      return 'Paid Cash';
    }
    if (paidGCash) {
      jobRepo.partialCashAmountVar.text = '';
      if (jobRepo.selectedPackage == othersPackage) {
        jobRepo.partialGCashAmountVar.text =
            jobRepo.totalPriceOthers.toString();
      } else {
        jobRepo.partialGCashAmountVar.text = jobRepo.totalPriceRegSS.toString();
      }
      return 'Paid GCash';
    }
    jobRepo.partialCashAmountVar.text = '';
    jobRepo.partialGCashAmountVar.text = '';
    jobRepo.unpaid = true;
    return 'Unpaid';
  }

  void validatePaymentWhenVarChange() {
    jobRepo.unpaid = true;
    if (jobRepo.paidCash &&
        jobRepo.paidGCash &&
        jobRepo.finalPrice <
            (int.parse(jobRepo.partialCashAmountVar.text) +
                int.parse(jobRepo.partialCashAmountVar.text))) {
      actualPaymentStatus = 'Unpaid(Kulang)';
    } else if (jobRepo.paidCash &&
        jobRepo.finalPrice < int.parse(jobRepo.partialCashAmountVar.text)) {
      actualPaymentStatus = 'Unpaid(Kulang)';
    } else if (jobRepo.paidGCash &&
        jobRepo.finalPrice < int.parse(jobRepo.partialGCashAmountVar.text)) {
      actualPaymentStatus = 'Unpaid(Kulang)';
    } else {
      jobRepo.unpaid = false;
    }
  }

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
            actualPaymentStatus,
            style: TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),

          //toggle checkbox
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paid(Cash)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2), // tiny gap
                  Transform.scale(
                    scale: 0.7, // shrink the checkbox itself
                    child: Checkbox(
                      value: jobRepo.paidCash,
                      onChanged: (bool? value) {
                        setState(() {
                          jobRepo.paidCash = value ?? false;
                          actualPaymentStatus = returnPaymentStatusDuringToggle(
                              jobRepo.paidCash, jobRepo.paidGCash);
                        });
                      },
                      visualDensity: VisualDensity(
                          horizontal: -4, vertical: -4), // tighter
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // no extra padding
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paid(GCash)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2), // tiny gap
                  Transform.scale(
                    scale: 0.7, // shrink the checkbox itself
                    child: Checkbox(
                      value: jobRepo.paidGCash,
                      onChanged: (bool? value) {
                        setState(() {
                          jobRepo.paidGCash = value ?? false;
                          actualPaymentStatus = returnPaymentStatusDuringToggle(
                              jobRepo.paidCash, jobRepo.paidGCash);
                        });
                      },
                      visualDensity: VisualDensity(
                          horizontal: -4, vertical: -4), // tighter
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // no extra padding
                    ),
                  ),
                ],
              ),
            ],
          ),
          //amountVar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// CASH FIELD (slides from LEFT)

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(-1, 0), // from left
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: jobRepo.paidCash
                      ? Padding(
                          key: const ValueKey('cash'),
                          padding: const EdgeInsets.only(right: 4),
                          child: TextFormField(
                            onEditingComplete: (() {
                              setState(() {
                                validatePaymentWhenVarChange();
                              });
                            }),
                            controller: jobRepo.partialCashAmountVar,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'Cash Amount',
                              isDense: true,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              /// GCASH FIELD (slides from RIGHT)

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0), // from right
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: jobRepo.paidGCash
                      ? Padding(
                          key: const ValueKey('gcash'),
                          padding: const EdgeInsets.only(left: 4),
                          child: TextFormField(
                            onEditingComplete: (() {
                              setState(() {
                                validatePaymentWhenVarChange();
                              });
                            }),
                            controller: jobRepo.partialGCashAmountVar,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              labelText: 'GCash Amount',
                              isDense: true,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),

          //GCash verified
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GCash verified?',
                style: const TextStyle(
                  fontSize: 10,
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
                  visualDensity:
                      VisualDensity(horizontal: -4, vertical: -4), // tighter
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // no extra padding
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Visibility visFold(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visMix(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visBasket(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visEcoBag(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visSako(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visAddFab(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visAddDry(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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

Visibility visAddWash(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
      decoration:
          (jobRepo.addExtraWashCount > 0 ? decoOtherItems() : decoLightBlue()),
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

Visibility visAddSpin(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
      decoration:
          (jobRepo.addExtraSpinCount > 0 ? decoOtherItems() : decoLightBlue()),
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

Container conRemarks(
    BuildContext context, Function setState, JobModelRepository jobRepo) {
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
