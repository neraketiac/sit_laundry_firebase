//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/autocompletecustomer.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/conRemarks.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/customerAmount.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

void showLaundryPayment(BuildContext context, JobModelRepository jobRepo) {
  // if (selectedFundCode == menuOthSalaryPayment) {
  //   selectedFundCode = menuOthLaundryPayment;
  // }
  selectedFundCode = menuOthLaundryPayment;

  final List<int> fundTypeCodes1stLayer = [
    menuOthLaundryPayment,
    menuOthUniqIdLoad,
  ];

  final List<int> fundTypeCodes2ndLayer = [
    menuOthUniqIdCashIn,
    menuOthUniqIdCashOut,
  ];

  String fundTypeCaptionMulti() {
    switch (selectedFundCode) {
      case menuOthLaundryPayment:
        return 'Bayad sa pina-laundry.\nadd funds';
      case menuOthUniqIdCashIn:
        return 'Bayad sa pa-cash-in.\nadd funds';
      case menuOthUniqIdLoad:
        return 'Bayad sa pina-load.\nadd funds';
      case menuOthUniqIdCashOut:
        return 'Pa-cash-out si customer.\nbawas funds';
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
            Text('For Customer'),
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
                minWidth: 110,
                minHeight: 40,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ['LPayment', 'Load'][index],
                    ),
                  ),
                );
              }),
            ),

            const Divider(height: 1),
            // 🔹 SECOND ROW
            ToggleButtons(
              isSelected: List.generate(
                fundTypeCodes2ndLayer.length,
                (i) => selectedFundCode == fundTypeCodes2ndLayer[i],
              ),
              onPressed: (index) {
                selectedFundCode = fundTypeCodes2ndLayer[index];

                dialogSetState();
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              borderColor: Colors.blue,
              fillColor: Colors.blue,
              color: Colors.black,
              constraints: const BoxConstraints(
                minWidth: 110,
                minHeight: 40,
              ),
              children: const [
                Text('Cash In'),
                Text('Cash Out'),
              ],
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

  Visibility customerName(
    VoidCallback dialogSetState,
  ) {
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
            AutoCompleteCustomer(
              jobRepo: jobRepo,
              dialogSetState: dialogSetState,
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
            "Laundry Payment",
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
                    customerName(() => setState(() {})),
                    customerAmount(context, customerAmountVar),
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
                    if (fundTypeCodes1stLayer.contains(selectedFundCode) ||
                        fundTypeCodes2ndLayer.contains(selectedFundCode)) {
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
