//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

void showFundsInFundsOut(BuildContext context, JobModelRepository jobRepo) {
  // if (selectedFundCode == menuOthSalaryPayment) {
  //   selectedFundCode = menuOthLaundryPayment;
  // }

  final List<int> fundTypeCodes3rdLayer = [
    menuOthUniqIdFundsIn,
    menuOthUniqIdFundsOut,
  ];

  String fundTypeCaptionMulti() {
    switch (selectedFundCode) {
      case menuOthUniqIdFundsIn:
        return 'Add funds\nName kanino galing\n ';
      case menuOthUniqIdFundsOut:
        return 'Bawas funds.\nName kanino ibabawas\nRemarks sample: Para saan?';
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
            const SizedBox(height: 1),
            Text('For Staff'),
            // 🔹 THIRD ROW
            ToggleButtons(
              isSelected: List.generate(
                fundTypeCodes3rdLayer.length,
                (i) => selectedFundCode == fundTypeCodes3rdLayer[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedFundCode = fundTypeCodes3rdLayer[index];
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.yellowAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 110,
                minHeight: 40,
              ),
              children: const [
                Text('Funds In'),
                Text('Funds Out'),
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
            AutoCompleteCustomer(jobRepo: jobRepo),
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
          backgroundColor: cFundsInFundsOut,
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
            "Funds In/Out",
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
