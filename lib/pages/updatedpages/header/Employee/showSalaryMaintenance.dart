//floating salary  ###########################################################
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/pages/autocompletecustomer.dart';
import 'package:laundry_firebase/pages/updatedpages/sharedmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_oth.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

void showSalaryMaintenance(BuildContext context) {
  //selectedFundCode = menuOthSalaryPayment;

  final List<int> fundTypeCodesEmployeeLayer = [
    menuOthSalaryPayment,
    menuOthUniqIdCashIn
  ];

  String fundTypeCaption() {
    if (selectedFundCode == fundTypeCodesEmployeeLayer[0]) {
      return '(+) Ilista ang iyong kinita.';
    } else if (selectedFundCode == fundTypeCodesEmployeeLayer[1]) {
      return '(-) Ilista ang nakuha/kukuning gcash\nibabawas ito sa current balance\n For real money, use "Funds Out".';
    }
    return '';
  }

  Visibility fundTypeToggle(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected: List.generate(
                fundTypeCodesEmployeeLayer.length,
                (i) => selectedFundCode == fundTypeCodesEmployeeLayer[i],
              ),
              onPressed: (index) {
                setState(() {
                  selectedFundCode = fundTypeCodesEmployeeLayer[index];
                  // SuppliesHistRepository.instance
                  //     .setItemId(menuOthCashInOutFunds);
                  // SuppliesHistRepository.instance
                  //     .setItemUniqueId(selectedFundCode!);
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              color: Colors.black,
              constraints: const BoxConstraints(
                minWidth: 110,
                minHeight: 40,
              ),
              children: const [
                Text('Earn Cash'),
                Text('Get GCash'),
              ],
            ),

            const SizedBox(height: 6),

            // 🔹 CAPTION
            Text(
              fundTypeCaption(),
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
              padding: const EdgeInsets.only(left: 2, bottom: 1),
              child: Row(
                children: [],
              ),
            ),

            AutoCompleteCustomer(),
          ],
        ),
      ),
    );
  }

  Future<void> saveButtonProcessCash() async {
    SuppliesHistRepository.instance
        .setItemName(getItemNameOnly(menuOthCashInOutFunds, selectedFundCode!));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
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
          contentPadding: const EdgeInsets.all(2),
          titlePadding: const EdgeInsets.only(
            top: 5,
            left: 5,
            right: 5,
            bottom: 2,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          backgroundColor: cSalaryIn,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Staff Maintenance\n",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Dagdag/bawas sa current balance.",
                  style: TextStyle(
                    fontSize: 10, // 👈 smaller
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customerName(setState),
                    fundTypeToggle(setState),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (empNameToId.containsKey(autocompleteSelected.name)) {
                  isGcashCredit = true;
                  await saveButtonProcessCash();
                  Navigator.pop(context);
                } else if (selectedFundCode == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select transaction type.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Name must be a staff for Salary Payment.')),
                  );
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
