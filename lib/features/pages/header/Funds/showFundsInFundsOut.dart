//floating button new record  ###########################################################
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/autocompletecustomer.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/customerAmount.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

void showFundsInFundsOut(BuildContext context) async {
  // Load latest customer data before opening dialog
  await CustomerRepository.instance.loadOnce();

  JobModelRepository jobRepo = JobModelRepository();

  // Initialize selectedFundCode to Funds In by default
  selectedFundCode = menuOthUniqIdFundsIn;

  final List<int> fundTypeCodes3rdLayer = [
    menuOthUniqIdFundsIn,
    menuOthUniqIdFundsOut,
  ];

  // Funds Out category — local state
  String fundsOutCategory = 'Others';
  final List<String> fundsOutCategories = [
    'Others',
    'Saging',
    'Basura',
    'Palengke'
  ];

  void applyCategory(String category, VoidCallback dialogSetState) {
    fundsOutCategory = category;
    if (category == 'Others') {
      remarksSuppliesVar.text = '';
      autocompleteSelected = CustomerModel(
        customerId: 0,
        name: '',
        address: '',
        contact: '',
        remarks: '',
        loyaltyCount: 0,
      );
      jobRepo.selectedCustomerId = 0;
      jobRepo.selectedCustomerNameVar.text = '';
    } else {
      remarksSuppliesVar.text = category;
      autocompleteSelected = CustomerModel(
        customerId: 1313,
        name: 'Ket',
        address: '',
        contact: '',
        remarks: '',
        loyaltyCount: 0,
      );
      jobRepo.selectedCustomerId = 1313;
      jobRepo.selectedCustomerNameVar.text = '1313# Ket';
    }
    dialogSetState();
  }

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

  Visibility fundTypeToggle(VoidCallback dialogSetState) {
    final isFundsOut = selectedFundCode == menuOthUniqIdFundsOut;
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
            const Text('For Staff only'),
            // 🔹 Funds In / Funds Out
            ToggleButtons(
              isSelected: List.generate(
                fundTypeCodes3rdLayer.length,
                (i) => selectedFundCode == fundTypeCodes3rdLayer[i],
              ),
              onPressed: (index) {
                selectedFundCode = fundTypeCodes3rdLayer[index];
                // reset category when switching
                fundsOutCategory = 'Others';
                remarksSuppliesVar.text = '';
                dialogSetState();
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.yellow.shade200,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(minWidth: 110, minHeight: 40),
              children: const [Text('Funds In'), Text('Funds Out')],
            ),
            // 🔹 Category sub-toggle — only when Funds Out
            if (isFundsOut) ...[
              const SizedBox(height: 6),
              ToggleButtons(
                isSelected: fundsOutCategories
                    .map((c) => fundsOutCategory == c)
                    .toList(),
                onPressed: (index) =>
                    applyCategory(fundsOutCategories[index], dialogSetState),
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: Colors.deepOrange.shade200,
                color: Colors.black,
                constraints: const BoxConstraints(minWidth: 72, minHeight: 34),
                children: fundsOutCategories
                    .map((c) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(c, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 1),
            // 🔹 Caption
            Text(
              fundTypeCaptionMulti(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Visibility customerName(VoidCallback dialogSetState) {
    return Visibility(
      visible: true,
      child: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: decoAmber(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(children: []),
            ),
            // When a category is pre-selected, show the fixed name instead of autocomplete
            if (selectedFundCode == menuOthUniqIdFundsOut &&
                fundsOutCategory != 'Others')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.black54, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      autocompleteSelected.name,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              AutoCompleteCustomer(
                key: ValueKey(fundsOutCategory),
                jobRepo: jobRepo,
                dialogSetState: dialogSetState,
              ),
            const SizedBox(height: 5),
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
          backgroundColor: const Color.fromARGB(255, 255, 243, 194),
          contentPadding: const EdgeInsets.all(0),
          titlePadding:
              const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          title: const Text("Funds In/Out", textAlign: TextAlign.center),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber.shade300, width: 1.5)),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    fundTypeToggle(() => setState(() {})),
                    customerName(() => setState(() {})),
                    customerAmount(context, customerAmountVar),
                    conRemarks(
                        context, () => setState(() {}), remarksSuppliesVar),
                  ],
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
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
                    if (fundTypeCodes3rdLayer.contains(selectedFundCode)) {
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
