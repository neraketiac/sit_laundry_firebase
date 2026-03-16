//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/conRemarks.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/customerAmount.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

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

  Visibility fundTypeToggle(
    VoidCallback dialogSetState,
  ) {
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
                selectedFundCode = fundTypeCodes1stLayer[index];

                dialogSetState();
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
                    if (fundTypeCodes1stLayer[index] == menuOthLaundryPayment) {
                      customerAmountVar.text =
                          (int.parse(customerAmountVar.text) + 155).toString();
                    }

                    dialogSetState();

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
            "GCash FundsIn/Out",
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
                    customerAmount(context, customerAmountVar),
                    fundTypeToggle(() => setState(() {})),
                    conRemarks(
                        context, () => setState(() {}), remarksSuppliesVar),
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
            boxButtonElevated(
                context: context,
                label: 'Save',
                onPressed: () async {
                  if (customerAmountVar.text.isEmpty ||
                      int.parse(customerAmountVar.text) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter amount.')),
                    );
                    return false;
                  } else if (ifMenuUniqueIsFundsOut(
                          SuppliesHistRepository.instance.suppliesModelHist!) &&
                      remarksSuppliesVar.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Remarks is required for Funds Out.')),
                    );
                    return false;
                  } else if (ifMenuUniqueIsFundsOut(
                          SuppliesHistRepository.instance.suppliesModelHist!) &&
                      !empNameToId.containsKey(autocompleteSelected.name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Name must be a staff for Funds Out.')),
                    );
                    return false;
                  } else if (selectedFundCode == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select transaction type.')),
                    );
                    return false;
                  } else {
                    if (fundTypeCodes1stLayer.contains(selectedFundCode)) {
                      await saveButtonSetRepository();
                      return true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select transaction type.')),
                      );
                      return false;
                    }
                  }
                }),
          ],
        );
      });
    },
  );
}
