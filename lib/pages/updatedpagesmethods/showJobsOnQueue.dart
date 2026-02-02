import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsmodel_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_ble.dart';
import 'package:laundry_firebase/variables/variables_det.dart';
import 'package:laundry_firebase/variables/variables_fab.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

void showJobsOnQueue(BuildContext context) {
  final List<int> listOthersDropDown = [
    menuOthDVal,
    menuDetDVal,
    menuFabDVal,
    menuBleDVal,
  ];
  final List<int> listOthersDropDownShortCuts = [
    menuOth155,
    menuOth125,
    menuOthXD,
    menuFabWKLDValAny8ml,
  ];
  final List<int> listPackage = [
    regularPackage,
    sayoSabonPackage,
    othersPackage,
  ];

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
            AutoCompleteCustomer(),
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
    final List<int> listRiderPickup = [
      forSorting,
      riderPickup,
    ];
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
                (i) => selectedRiderPickup == listRiderPickup[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedRiderPickup = listRiderPickup[index];
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
                (i) => selectedPackage == listPackage[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (selectedPackagePrev == othersPackage &&
                      listAddedOtherItemModel.isNotEmpty) {
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
                                  selectedPackage = othersPackage;
                                });

                                Navigator.pop(context, false);
                              },
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPackage = listPackage[index];
                                  selectedPackagePrev = listPackage[index];
                                  listAddedOtherItemModel.clear();
                                  totalPriceOthers = 0;
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
                      selectedPackage = listPackage[index];
                      selectedPackagePrev = listPackage[index];
                      if (selectedPackage == othersPackage) {
                        selectedItemModel = listOthItems[0];
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
    const maxPartialOptions = {
      regularPackage: 3,
      sayoSabonPackage: 2,
      othersPackage: 2,
    };

    const prices = {
      regularPackage: 155,
      sayoSabonPackage: 125,
      othersPackage: 0,
    };

    final int pricePerSet = prices[selectedPackage] ?? 155;
    final int maxPartial = maxPartialOptions[selectedPackage] ?? 3;
    // 🧠 UI rules

    final bool showPointOne = quantityKg >= 8 && (quantityKg % 8) < maxPartial;

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

    totalPriceRegSS = computeTotalPrice(quantityKg) + totalPriceShortCutRegSS;

    String showHowMany155or125Set(int total) {
      //int base = pricePerSet;
      List<int> extras = [
        pricePerSet + tier1Increase,
        pricePerSet + tier2Increase
      ];

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
          return ' ($pricePerSet * $multiplier)\n + $extra';
        }
      }

      // Fallback if it doesn't match the pattern
      return ' $total';
    }

    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        quantityKg += 1;
        quantityKg = quantityKg.floorToDouble();
      });
    }

    void incrementPointOne() {
      setState(() {
        quantityKg = double.parse((quantityKg + 0.1).toStringAsFixed(1));
        //if (quantityKg > 11.0) quantityKg = 11.0;
      });
    }

    void decrementOne() {
      setState(() {
        quantityKg -= 1;
        if (quantityKg < 1) quantityKg = 1;
        quantityKg = quantityKg.floorToDouble();
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : isPerKg),
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
                          showHowMany155or125Set(computeTotalPrice(quantityKg)),
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
                              formatter.format(totalPriceRegSS),
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
                        showHowMany155or125Set(computeTotalPrice(quantityKg)),
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
                          '${quantityKg.toStringAsFixed(
                            quantityKg % 1 == 0 ? 0 : 1,
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
                                isPerKg = false;
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
                    disabled: quantityKg <= 1,
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

    final int pricePerSet = prices[selectedPackage] ?? 155;
    // 🧠 UI rules

    totalPriceRegSS = (pricePerSet * quantityLoad) + totalPriceShortCutRegSS;

    // ➕➖ handlers
    void incrementOne() {
      setState(() {
        quantityLoad += 1;
      });
    }

    void decrementOne() {
      setState(() {
        quantityLoad -= 1;
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : !isPerKg),
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
                              formatter.format(totalPriceRegSS),
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
                          '$quantityLoad load',
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
                                isPerKg = true;
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
                    disabled: quantityLoad <= 1,
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
      listAddedOtherItemModel.add(item);
      totalPriceOthers += item.itemPrice;
    }

    return Visibility(
      visible: (selectedPackage == othersPackage),
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
                    formatter.format(totalPriceOthers),
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
                          selectedOthersShortCut ==
                          listOthersDropDownShortCuts[i],
                    ),
                    onPressed: (index) {
                      setState(() {
                        selectedOthersShortCut =
                            listOthersDropDownShortCuts[index];
                        if (selectedOthersShortCut == menuOth155) {
                          addOtherItem(reg155ItemModel);
                        }
                        if (selectedOthersShortCut == menuOth125) {
                          addOtherItem(reg125ItemModel);
                        }
                        if (selectedOthersShortCut == menuOthXD) {
                          addOtherItem(xDItemModel);
                        }
                        if (selectedOthersShortCut == menuFabWKLDValAny8ml) {
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
                      (i) => selectedOthers == listOthersDropDown[i],
                    ),
                    onPressed: (index) {
                      setState(() {
                        selectedOthers = listOthersDropDown[index];
                        (selectedOthers == menuOthDVal
                            ? selectedItemModel = listOthItems[0]
                            : selectedOthers == menuDetDVal
                                ? selectedItemModel = listDetItems[0]
                                : selectedOthers == menuFabDVal
                                    ? selectedItemModel = listFabItems[0]
                                    : selectedItemModel = listBleItems[0]);
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
                            initialValue: (selectedOthers == menuOthDVal
                                ? listOthItems[0]
                                : selectedOthers == menuDetDVal
                                    ? listDetItems[0]
                                    : selectedOthers == menuFabDVal
                                        ? listFabItems[0]
                                        : listBleItems[0]),
                            items: (selectedOthers == menuOthDVal
                                    ? listOthItems
                                    : selectedOthers == menuDetDVal
                                        ? listDetItems
                                        : selectedOthers == menuFabDVal
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
                              setState(() => selectedItemModel = val!);
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
                              addOtherItem(selectedItemModel);
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
                    children: listAddedOtherItemModel.map((e) {
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
                                  totalPriceOthers -= e.itemPrice;
                                  listAddedOtherItemModel.remove(e);
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
      // partialPaidCash,
      // partialPaidGCash,
    ];
    // final List<int> listPaidUnpaid2 = [
    //   partialPaidCash,
    //   partialPaidGCash,
    // ];
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
                (i) => selectedPaidUnpaid == listPaidUnpaid[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (selectedPaidUnpaid == listPaidUnpaid[index]) {
                    selectedPaidUnpaid = 0;
                  } else {
                    selectedPaidUnpaid = listPaidUnpaid[index];
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
                // ToggleButtons(
                //   isSelected: List.generate(
                //     listPaidUnpaid2.length,
                //     (i) => selectedPaidUnpaid == listPaidUnpaid2[i],
                //   ),
                //   onPressed: (index) {
                //     setState(() {
                //       selectedPaidUnpaid = listPaidUnpaid2[index];
                //     });
                //   },
                //   borderRadius: BorderRadius.circular(8),
                //   selectedColor: Colors.black,
                //   fillColor: Colors.greenAccent,
                //   color: Colors.black,
                //   borderColor: cSalaryOut,
                //   constraints: const BoxConstraints(
                //     minWidth: 60,
                //     minHeight: 25,
                //   ),
                //   children: const [
                //     Text('Partial Cash', style: TextStyle(fontSize: 10)),
                //     Text('Partial GCash', style: TextStyle(fontSize: 10)),
                //   ],
                // ),
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
                        value: selectedPaidPartialCash,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidPartialCash = value ?? false;
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
                        value: selectedPaidPartialGCash,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidPartialGCash = value ?? false;
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
                        value: selectedPaidGCashVerified,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidGCashVerified = value ?? false;
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
              visible: selectedPaidPartialCash,
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
                    controller: partialCashAmountVar,
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
              visible: selectedPaidPartialGCash,
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
                    controller: partialCashAmountVar,
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
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected: [
                selectedFold, // Fold
                !selectedFold, // No Fold
              ],
              onPressed: (index) {
                setState(() {
                  // single source of truth
                  selectedFold = index == 0;
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
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected: [
                selectedMix, // Fold
                !selectedMix, // No Fold
              ],
              onPressed: (index) {
                setState(() {
                  // single source of truth
                  selectedMix = index == 0;
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
        basketCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        basketCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (basketCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1', disabled: basketCount <= 0, onTap: decrementOne),
            const SizedBox(width: 12),

            // 🧺 basket : x
            Text(
              'Basket : $basketCount pc',
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
        ecoBagCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        ecoBagCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (ecoBagCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1', disabled: ecoBagCount <= 0, onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              'EcoBag : $ecoBagCount pc',
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
        sakoCount += 1;
      });
    }

    void decrementOne() {
      setState(() {
        sakoCount -= 1;
      });
    }

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (sakoCount > 0 ? decoGreenAccent2() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButton(
                label: '-1', disabled: sakoCount <= 0, onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              'Sako : $sakoCount pc',
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
        addFabCount += 1;
        listAddedOtherItemModel.add(addFabAnyItemModel);
        totalPriceShortCutRegSS += addFabAnyItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        addFabCount -= 1;
        listAddedOtherItemModel.remove(addFabAnyItemModel);
        totalPriceShortCutRegSS -= addFabAnyItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (addFabCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1', disabled: addFabCount <= 0, onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Fab(₱${addFabAnyItemModel.itemPrice}): $addFabCount pc',
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
        addExtraDryCount += 1;
        listAddedOtherItemModel.add(xDItemModel);
        totalPriceShortCutRegSS += xDItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        addExtraDryCount -= 1;
        listAddedOtherItemModel.remove(xDItemModel);
        totalPriceShortCutRegSS -= xDItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (addExtraDryCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: addExtraDryCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Dry(₱${xDItemModel.itemPrice}): $addExtraDryCount pc',
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
        addExtraWashCount += 1;
        listAddedOtherItemModel.add(xWashItemModel);
        totalPriceShortCutRegSS += xWashItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        addExtraWashCount -= 1;
        listAddedOtherItemModel.remove(xWashItemModel);
        totalPriceShortCutRegSS -= xWashItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (addExtraWashCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: addExtraWashCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Wash(₱${xWashItemModel.itemPrice}): $addExtraWashCount pc',
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
        addExtraSpinCount += 1;
        listAddedOtherItemModel.add(xSpinItemModel);
        totalPriceShortCutRegSS += xSpinItemModel.itemPrice;
      });
    }

    void decrementOne() {
      setState(() {
        addExtraSpinCount -= 1;
        listAddedOtherItemModel.remove(xSpinItemModel);
        totalPriceShortCutRegSS -= xSpinItemModel.itemPrice;
      });
    }

    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (addExtraSpinCount > 0 ? decoOtherItems() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            boxButtonOtherItems(
                label: '-1',
                disabled: addExtraSpinCount <= 0,
                onTap: decrementOne),

            const SizedBox(width: 12),

            Text(
              '+Spin(₱${xSpinItemModel.itemPrice}): $addExtraSpinCount pc',
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

  Future<void> saveButtonSetRepository() async {
    int computeLoadForKg(double kg) {
      double remainder = kg % 8;
      int wholeEight = kg ~/ 8;
      int lastCounter = 0;
      if (remainder <= 0.9) {
        lastCounter = 0;
      } else {
        lastCounter = 1;
      }

      return wholeEight + lastCounter;
    }

    //dates
    /// 🟣 Dates
    JobsModelRepository.instance.setDateQ = Timestamp.now();

    //admin
    JobsModelRepository.instance.setCreatedBy = empIdGlobal;
    JobsModelRepository.instance.setCurrentEmpId = empIdGlobal;

    //initial status
    JobsModelRepository.instance.setForSorting =
        forSorting == selectedRiderPickup;
    JobsModelRepository.instance.setRiderPickup =
        riderPickup == selectedRiderPickup;

    //package status
    JobsModelRepository.instance.setRegular = regularPackage == selectedPackage;
    JobsModelRepository.instance.setSayosabon =
        sayoSabonPackage == selectedPackage;
    JobsModelRepository.instance.setAddOn = othersPackage == selectedPackage;

    //prices
    if (selectedPackage == othersPackage) {
      JobsModelRepository.instance.setFinalPrice = totalPriceOthers;
    } else {
      JobsModelRepository.instance.setFinalPrice = totalPriceRegSS;
    }

    //payment status
    JobsModelRepository.instance.setUnpaid = unpaid == selectedPaidUnpaid;
    JobsModelRepository.instance.setPaidCash = paidCash == selectedPaidUnpaid;
    JobsModelRepository.instance.setPaidGCash = paidGCash == selectedPaidUnpaid;
    JobsModelRepository.instance.setPartialPaidCash = selectedPaidPartialCash;
    JobsModelRepository.instance.setPartialPaidGCash = selectedPaidPartialGCash;
    JobsModelRepository.instance.setPartialPaidCashAmount =
        int.tryParse(partialCashAmountVar.text) ?? 0;
    JobsModelRepository.instance.setPartialPaidGCashAmount =
        int.tryParse(partialGCashAmountVar.text) ?? 0;

    if (unpaid != selectedPaidUnpaid) {
      JobsModelRepository.instance.setPaymentReceivedBy = empIdGlobal;
    }

    //verified gcash
    JobsModelRepository.instance.setPaidGCashVerified =
        selectedPaidGCashVerified;

    //weight status
    JobsModelRepository.instance.setPerKilo = false;
    JobsModelRepository.instance.setPerLoad = false;
    if (isPerKg) {
      JobsModelRepository.instance.setPerKilo = true;
      JobsModelRepository.instance.setFinalKilo = quantityKg;
      JobsModelRepository.instance.setFinalLoad = computeLoadForKg(quantityKg);
    } else {
      JobsModelRepository.instance.setPerLoad = true;
      JobsModelRepository.instance.setFinalLoad = quantityLoad;
    }

    //list other items
    if (listAddedOtherItemModel.isNotEmpty) {
      JobsModelRepository.instance.setItems = listAddedOtherItemModel;
    }

    //other options
    JobsModelRepository.instance.setFold = selectedFold;
    JobsModelRepository.instance.setMix = selectedMix;
    JobsModelRepository.instance.setBasket = basketCount;
    JobsModelRepository.instance.setEbag = ecoBagCount;
    JobsModelRepository.instance.setSako = sakoCount;
    JobsModelRepository.instance.setRemarks = remarksSuppliesVar.text;

    await insertToFBJobsOnQueuelRepository(context);
  }

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
                    (isPerKg
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
                    conRemarksSuppliesVar(setState),
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
                if (JobsModelRepository.instance.getCustomerId() == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select customer name.')),
                  );
                } else {
                  await saveButtonSetRepository();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
