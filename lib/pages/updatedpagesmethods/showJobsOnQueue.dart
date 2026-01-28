import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
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

            // 🔹 Input Field (disabled if employee is checked)
            // TextFormField(
            //   controller: visCustomerNameVar,
            //   focusNode: nameFocusNode,
            //   textCapitalization: TextCapitalization.words,
            //   decoration: const InputDecoration(
            //     hintText: 'Enter Name',
            //     prefixIcon: SizedBox(width: _fieldIndentWidth),
            //     border: OutlineInputBorder(),
            //   ),
            // ),
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
            ToggleButtons(
              isSelected: List.generate(
                listRiderPickup.length,
                (i) => selectedRiderPickup == listRiderPickup[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedRiderPickup = listRiderPickup[index];
                  SuppliesHistRepository.instance
                      .setItemId(menuOthCashInOutFunds);
                  SuppliesHistRepository.instance
                      .setItemUniqueId(selectedRiderPickup!);
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
                                  SuppliesHistRepository.instance
                                      .setItemId(menuOthCashInOutFunds);
                                  SuppliesHistRepository.instance
                                      .setItemUniqueId(selectedPackage!);
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
                      SuppliesHistRepository.instance
                          .setItemId(menuOthCashInOutFunds);
                      SuppliesHistRepository.instance
                          .setItemUniqueId(selectedPackage!);
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
    final int tier1Increase = 35;
    final int tier2Increase = 105;

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

    String formatPriceExpression(int total) {
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

    // 🧠 UI rules

    final bool showPointOne = quantityKg >= 8 && (quantityKg % 8) < maxPartial;

    totalPriceRegSS = computeTotalPrice(quantityKg) + totalPriceRegSSShortCut;

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

    // 🔘 Reusable button
    Widget boxButton({
      required String label,
      required VoidCallback? onTap,
      bool disabled = false,
    }) {
      final color = disabled ? Colors.grey.shade400 : Colors.black54;

      return InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 42,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
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
                          formatPriceExpression(computeTotalPrice(quantityKg)),
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
                        formatPriceExpression(computeTotalPrice(quantityKg)),
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
                        boxButton2label(
                          label: 'kg ',
                          label2: 'load',
                          boldLabel2: false,
                          onTap: () {
                            setState(() {
                              isPerKg = false;
                            });
                          },
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

    totalPriceRegSS = (pricePerSet * quantityLoad) + totalPriceRegSSShortCut;

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

    // 🔘 Reusable button
    Widget boxButton({
      required String label,
      required VoidCallback? onTap,
      bool disabled = false,
    }) {
      final color = disabled ? Colors.grey.shade400 : Colors.black54;

      return InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 42,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
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
                        boxButton2label(
                          label: 'kg ',
                          label2: 'load',
                          boldLabel2: true,
                          onTap: () {
                            setState(() {
                              isPerKg = true;
                            });
                          },
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
                        SuppliesHistRepository.instance
                            .setItemId(menuOthCashInOutFunds);
                        SuppliesHistRepository.instance
                            .setItemUniqueId(selectedOthersShortCut!);
                        if (selectedOthersShortCut == menuOth155) {
                          listAddedOtherItemModel.add(reg155ItemModel);
                          totalPriceOthers += reg155ItemModel.itemPrice;
                        }
                        if (selectedOthersShortCut == menuOth125) {
                          listAddedOtherItemModel.add(reg125ItemModel);
                          totalPriceOthers += reg125ItemModel.itemPrice;
                        }
                        if (selectedOthersShortCut == menuOthXD) {
                          listAddedOtherItemModel.add(xDItemModel);
                          totalPriceOthers += xDItemModel.itemPrice;
                        }
                        if (selectedOthersShortCut == menuFabWKLDValAny8ml) {
                          listAddedOtherItemModel.add(addFabAnyItemModel);
                          totalPriceOthers += addFabAnyItemModel.itemPrice;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.black,
                    fillColor: Colors.greenAccent,
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
                        SuppliesHistRepository.instance
                            .setItemId(menuOthCashInOutFunds);
                        SuppliesHistRepository.instance
                            .setItemUniqueId(selectedOthers!);
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
                    fillColor: Colors.greenAccent,
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
                              listAddedOtherItemModel.add(selectedItemModel);
                              totalPriceOthers += selectedItemModel.itemPrice;
                            });
                          },
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
                      return Padding(
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
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (basketCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: basketCount > 0
                  ? () {
                      setState(() {
                        basketCount--;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: basketCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 🧺 basket : x
            Text(
              'Basket : $basketCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  basketCount++;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visEcoBag(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (ecoBagCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: ecoBagCount > 0
                  ? () {
                      setState(() {
                        ecoBagCount--;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ecoBagCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              'EcoBag : $ecoBagCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  ecoBagCount++;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visSako(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (sakoCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: sakoCount > 0
                  ? () {
                      setState(() {
                        sakoCount--;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sakoCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              'Sako : $sakoCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  sakoCount++;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAddFab(Function setState) {
    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: (addFabCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: addFabCount > 0
                  ? () {
                      setState(() {
                        addFabCount--;
                        totalPriceRegSSShortCut -= addFabAnyItemModel.itemPrice;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: addFabCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '+Fab(₱${addFabAnyItemModel.itemPrice}): $addFabCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  addFabCount++;
                  totalPriceRegSSShortCut += addFabAnyItemModel.itemPrice;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAddDry(Function setState) {
    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (addExtraDryCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: addExtraDryCount > 0
                  ? () {
                      setState(() {
                        addExtraDryCount--;
                        totalPriceRegSSShortCut -= xDItemModel.itemPrice;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          addExtraDryCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '+Dry(₱${xDItemModel.itemPrice}): $addExtraDryCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  addExtraDryCount++;
                  totalPriceRegSSShortCut += xDItemModel.itemPrice;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAddWash(Function setState) {
    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (addExtraWashCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: addExtraWashCount > 0
                  ? () {
                      setState(() {
                        addExtraWashCount--;
                        totalPriceRegSSShortCut -= xWashItemModel.itemPrice;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          addExtraWashCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '+Wash(₱${xWashItemModel.itemPrice}): $addExtraWashCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  addExtraWashCount++;
                  totalPriceRegSSShortCut += xWashItemModel.itemPrice;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visAddSpin(Function setState) {
    return Visibility(
      visible: (selectedPackage == othersPackage ? false : true),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration:
            (addExtraSpinCount > 0 ? decoGreenAccent() : decoLightBlue()),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ➖ -1
            InkWell(
              onTap: addExtraSpinCount > 0
                  ? () {
                      setState(() {
                        addExtraSpinCount--;
                        totalPriceRegSSShortCut -= xSpinItemModel.itemPrice;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Text(
                  '-1',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          addExtraSpinCount > 0 ? Colors.black : Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Text(
              '+Spin(₱${xSpinItemModel.itemPrice}): $addExtraSpinCount pc',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 12),

            // ➕ +1
            InkWell(
              onTap: () {
                setState(() {
                  addExtraSpinCount++;
                  totalPriceRegSSShortCut += xSpinItemModel.itemPrice;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cSalaryOut),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: const Text(
                  '+1',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility visShortCuts(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: decoLightBlue(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isMaxFab = !isMaxFab; // toggle color
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300, // button bg (optional)
              ),
              child: Text(
                'MaxFab',
                style: TextStyle(
                  color: isMaxFab ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveButtonProcessCash() async {
    SuppliesHistRepository.instance
        .setItemName(getItemNameOnly(menuOthCashInOutFunds, selectedFundCode!));
    SuppliesHistRepository.instance.setItemUniqueId(selectedFundCode!);
    SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
    SuppliesHistRepository.instance.setCurrentCounter(
        int.parse(customerAmountVar.text.replaceAll(',', '')));
    await insertToFB(context);
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
                    visAmountRegSSPerKg(setState),
                    visAmountRegSSPerLoad(setState),
                    visAmountOthersOnly(setState),
                    visFold(setState),
                    visMix(setState),
                    visBasket(setState),
                    visEcoBag(setState),
                    visSako(setState),
                    visAddDry(setState),
                    visAddFab(setState),
                    visAddWash(setState),
                    visAddSpin(setState),
                    //visShortCuts(setState),
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
                if (customerAmountVar.text.isEmpty ||
                    int.parse(customerAmountVar.text) <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter amount.')),
                  );
                } else if (ifMenuUniqueIsFundsOut(
                        SuppliesHistRepository.instance.suppliesModelHist!) &&
                    remarksSuppliesVar.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Remarks is required for Funds Out.')),
                  );
                } else if (ifMenuUniqueIsFundsOut(
                        SuppliesHistRepository.instance.suppliesModelHist!) &&
                    !empNameToId.containsKey(autocompleteSelected.name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Name must be a staff for Funds Out.')),
                  );
                } else if (selectedFundCode == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select transaction type.')),
                  );
                } else {
                  await saveButtonProcessCash();
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
