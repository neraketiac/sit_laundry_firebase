import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

void showJobsOnQueue(BuildContext context) {
  final List<int> fundTypeCodesSorting = [
    forSorting,
    riderPickup,
  ];
  final List<int> fundTypeCodesPackage = [
    regularPackage,
    sayoSabonPackage,
    othersPackage,
  ];

  Visibility fundTypeSorting(Function setState) {
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
                fundTypeCodesSorting.length,
                (i) => selectedfundTypeCodesSorting == fundTypeCodesSorting[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedfundTypeCodesSorting = fundTypeCodesSorting[index];
                  SuppliesHistRepository.instance
                      .setItemId(menuOthCashInOutFunds);
                  SuppliesHistRepository.instance
                      .setItemUniqueId(selectedfundTypeCodesSorting!);
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

  Visibility fundTypePackage(Function setState) {
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
                fundTypeCodesPackage.length,
                (i) => selectedfundTypeCodesPackage == fundTypeCodesPackage[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedfundTypeCodesPackage = fundTypeCodesPackage[index];
                  SuppliesHistRepository.instance
                      .setItemId(menuOthCashInOutFunds);
                  SuppliesHistRepository.instance
                      .setItemUniqueId(selectedfundTypeCodesPackage!);
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
                Text('SayoSabon'),
                Text('Others'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility fundTypeAfterPackage(Function setState) {
    final int tier1Increase = 35;
    final int tier2Increase = 105;

    const maxPartialOptions = {
      regularPackage: 3,
      sayoSabonPackage: 2,
    };

    const prices = {
      regularPackage: 155,
      sayoSabonPackage: 125,
    };

    final int pricePerSet = prices[selectedfundTypeCodesPackage] ?? 155;
    final int maxPartial = maxPartialOptions[selectedfundTypeCodesPackage] ?? 3;

    // 🔢 Price formatter
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱ ',
      decimalDigits: 0,
    );

    String formatPriceExpression(int total) {
      const int base = 155;
      const List<int> extras = [190, 260];

      // Base single
      if (total == base) return '155';

      // Extras alone
      if (extras.contains(total)) return total.toString();

      for (final extra in [0, ...extras]) {
        final remaining = total - extra;

        if (remaining <= 0) continue;
        if (remaining % base != 0) continue;

        final multiplier = remaining ~/ base;

        if (multiplier == 1 && extra == 0) {
          return ' 155';
        }

        if (multiplier == 1 && extra != 0) {
          return ' 155 + $extra';
        }

        if (multiplier > 1 && extra == 0) {
          return ' (155 * $multiplier)';
        }

        if (multiplier > 1 && extra != 0) {
          return ' (155 * $multiplier) + $extra';
        }
      }

      // Fallback if it doesn't match the pattern
      return total.toString();
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

    final totalPrice = formatter.format(computeTotalPrice(quantityKg));

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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }

    return Visibility(
      visible: true,
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
                          child: Text('155')),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          totalPrice,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                          formatPriceExpression(computeTotalPrice(quantityKg))),
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
                    child: Text(
                      '${quantityKg.toStringAsFixed(
                        quantityKg % 1 == 0 ? 0 : 1,
                      )} kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
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
                      label: '+0.01',
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

  Visibility customerAmount(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: decoAmber(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (not indented)
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Amount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Amount field
            TextFormField(
              controller: customerAmountVar,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'\d+(\.\d{0,2})?'),
                ),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                border: const OutlineInputBorder(),
                prefixIcon: SizedBox(
                  width: fieldIndentWidth,
                  child: const Center(
                    child: Text(
                      '₱',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Visibility customerName(Function setState) {
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
            //   controller: customerNameVar,
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
            "Cash Funds",
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
                    customerName(setState),
                    fundTypeSorting(setState),
                    fundTypePackage(setState),
                    fundTypeAfterPackage(setState),
                    customerAmount(setState),
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
