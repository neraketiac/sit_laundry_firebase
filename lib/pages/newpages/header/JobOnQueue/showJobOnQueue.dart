import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showJobOnQueue(BuildContext context, JobModelRepository jobRepo) {
  void resetSelected() {
    successInsertFB = false;
    jobRepo.selectedRiderPickup = forSorting;
    //package status
    jobRepo.selectedPackage = regularPackage;

    //prices
    jobRepo.totalPriceRegSS = 155;
    jobRepo.totalPriceOthers = 0;

    //payment status
    jobRepo.selectedPaidUnpaid = unpaid;

    jobRepo.selectedPaidPartialCash = false;
    jobRepo.selectedPaidPartialGCash = false;
    jobRepo.partialCashAmountVar.text = '';
    jobRepo.partialGCashAmountVar.text = '';

    //verified gcash
    jobRepo.selectedPaidGCashVerified = false;

    //weight status
    jobRepo.isPerKg = true;

    jobRepo.quantityKg = 8;
    jobRepo.quantityLoad = 1;
    jobRepo.remarksVar.text = '';

    //list other items
    jobRepo.clearListSelectedItemModel();

    //other options
    jobRepo.selectedFold = true;
    jobRepo.selectedMix = true;
    jobRepo.basketCount = 0;
    jobRepo.ecoBagCount = 0;
    jobRepo.sakoCount = 0;
    jobRepo.addFabCount = 0;
    jobRepo.addExtraDryCount = 0;
    jobRepo.addExtraWashCount = 0;
    jobRepo.addExtraSpinCount = 0;
  }

  Future<void> saveButtonSetRepository() async {
//dates
    /// 🟣 Dates
    jobRepo.dateQ = Timestamp.now();

    //admin
    jobRepo.createdBy = empIdGlobal;

    setSelectedToRepository(jobRepo);

    await callDatabaseJobsQueueAdd(context, jobRepo);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  //reset only when submit, so that when user opens the popup again, their previous selections are still there until they decide to save or cancel. This is more user-friendly as it prevents accidental loss of input if they open the popup multiple times.
  //resetSelected();
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
                    visCustomerName(context, setState, jobRepo),
                    visRiderPickup(context, setState, jobRepo),
                    visSelectPackage(context, setState, jobRepo),
                    (jobRepo.isPerKg
                        ? visAmountRegSSPerKg(context, setState, jobRepo)
                        : visAmountRegSSPerLoad(context, setState, jobRepo)),
                    visAmountOthersOnly(context, setState, jobRepo),
                    visPaidUnPaid(context, setState, jobRepo),
                    Text(
                      'Other Options',
                      style: TextStyle(fontSize: 11),
                    ),
                    visFold(context, setState, jobRepo),
                    visMix(context, setState, jobRepo),
                    visBasket(context, setState, jobRepo),
                    visEcoBag(context, setState, jobRepo),
                    visSako(context, setState, jobRepo),
                    Text(
                      'Add Ons',
                      style: TextStyle(fontSize: 11),
                    ),
                    visAddDry(context, setState, jobRepo),
                    visAddFab(context, setState, jobRepo),
                    visAddWash(context, setState, jobRepo),
                    visAddSpin(context, setState, jobRepo),
                    conRemarks(context, setState, jobRepo),
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
                if (jobRepo.customerId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select customer name.')),
                  );
                } else {
                  await saveButtonSetRepository();
                  if (successInsertFB) resetSelected();
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
