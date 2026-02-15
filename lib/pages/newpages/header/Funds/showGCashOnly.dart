//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

void showGCashOnly(BuildContext context, JobModelRepository jobRepo) {
  final List<int> fundTypeCodes1stLayer = [
    menuOthUniqIdCashIn,
    menuOthUniqIdLoad,
    menuOthUniqIdCashOut,
  ];

  if (fundTypeCodes1stLayer.contains(selectedFundCode)) {
  } else {
    selectedFundCode = menuOthUniqIdCashIn;
  }

  String fundTypeCaptionMulti() {
    switch (selectedFundCode) {
      case menuOthLaundryPayment:
        return 'Bayad sa pina-laundry.\nadd funds';
      case menuOthUniqIdCashIn:
        return 'Bayad sa pa-cash-in.\nadd funds\nuse funds-in for employee';
      case menuOthUniqIdLoad:
        return 'Bayad sa pina-load.\nadd funds\n';
      case menuOthUniqIdCashOut:
        return 'Pa-cash-out si customer.\nbawas funds\nuse funds-out for employee';
      default:
        return '';
    }
  }

  Visibility fundTypeToggle(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For Customer Only'),
            // 🔹 FIRST ROW
            ToggleButtons(
              isSelected: List.generate(
                fundTypeCodes1stLayer.length,
                (i) => selectedFundCode == fundTypeCodes1stLayer[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedFundCode = fundTypeCodes1stLayer[index];
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              borderColor: Colors.blue,
              fillColor: Colors.blue,
              color: Colors.black,
              constraints: const BoxConstraints(
                minWidth: 70,
                minHeight: 30,
              ),
              children: List.generate(fundTypeCodes1stLayer.length, (index) {
                return GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      if (fundTypeCodes1stLayer[index] ==
                          menuOthLaundryPayment) {
                        customerAmountVar.text =
                            (int.parse(customerAmountVar.text) + 155)
                                .toString();
                      }
                    });

                    // You can add any double-tap specific logic here
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
                      ['Cash-in', 'Load', 'Cash-Out'][index],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 1),
            // 🔹 CAPTION
            Text(
              fundTypeCaptionMulti(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
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

  Future<void> saveButtonSetRepository() async {
    SuppliesHistRepository.instance
        .setItemName(getItemNameOnly(menuOthCashInOutFunds, selectedFundCode!));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setItemUniqueId(selectedFundCode!);
    SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
    SuppliesHistRepository.instance.setCurrentCounter(
        int.parse(customerAmountVar.text.replaceAll(',', '')));
    await setSuppliesRepository(context);
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
            "GCash",
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
                    customerAmount(setState),
                    fundTypeToggle(setState),
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
                  if (fundTypeCodes1stLayer.contains(selectedFundCode)) {
                    await saveButtonSetRepository();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select transaction type.')),
                    );
                  }
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
