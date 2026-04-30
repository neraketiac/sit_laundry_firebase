//floating salary  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/autocompletecustomer.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerAmount.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

void showSalaryMaintenance(BuildContext context) async {
  // Load latest customer data before opening dialog
  await CustomerRepository.instance.loadOnce();

  //selectedFundCode = menuOthSalaryPayment;
  JobModelRepository jobRepo = JobModelRepository();

  final List<int> fundTypeCodesEmployeeLayer = [
    menuOthSalaryPayment,
    menuOthUniqIdCashIn
  ];

  String fundTypeCaption() {
    if (selectedFundCode == fundTypeCodesEmployeeLayer[0]) {
      return '(+) Dagdagan ang current balance.\nRemarks sample:\nKumita sa petsa ito\nMali ang naibawas\n ';
    } else if (selectedFundCode == fundTypeCodesEmployeeLayer[1]) {
      return '(-) Bawasan ang current balance.\nRemarks sample:\nvia GCash ang current balance\nMali ang naidagdag\nFor real money, sa funds out.';
    }
    return '';
  }

  Visibility fundTypeToggle(
    VoidCallback dialogSetState,
  ) {
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
                selectedFundCode = fundTypeCodesEmployeeLayer[index];

                dialogSetState();
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
                Row(
                  children: [
                    Text('('),
                    Text(
                      '+',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(')Salary'),
                  ],
                ),
                Row(
                  children: [
                    Text('('),
                    Text(
                      '−',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(')Salary'),
                  ],
                ),
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
              padding: const EdgeInsets.only(left: 2, bottom: 1),
              child: Row(
                children: [],
              ),
            ),

            AutoCompleteCustomer(
              jobRepo: jobRepo,
              dialogSetState: dialogSetState,
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
                    customerName(() => setState(() {})),
                    fundTypeToggle(() => setState(() {})),
                    customerAmount(context, customerAmountVar),
                    conRemarksSuppliesVar(),
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
            boxButtonElevated(
                context: context,
                label: 'Save',
                onPressed: () async {
                  if (empNameToId.containsKey(autocompleteSelected.name)) {
                    if (fundTypeCodesEmployeeLayer.contains(selectedFundCode)) {
                      isGcashCredit = true;
                      await saveButtonSetRepository();
                      return true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select transaction type.')),
                      );
                      return false;
                    }
                  } else if (selectedFundCode == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select transaction type.')),
                    );
                    return false;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Name must be a staff for Salary Payment.')),
                    );
                    return false;
                  }
                }),
          ],
        );
      });
    },
  );
}
