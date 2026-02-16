import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_fab.dart';
import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

void showPaidUnpaid(BuildContext context, JobModelRepository jobRepo) {
  void syncRepoToSelected() {
    //admin
    jobRepo.currentEmpId = empIdGlobal;

    jobRepo.customerNameVar.text = jobRepo.customerName;

    //initial status
    //riderpickup can be true and forsorting is true, but always display the forSorting. meaning pickup is done.
    //if pickup is false, it went to forsorting but never in pickup.
    if (jobRepo.riderPickup) jobRepo.selectedRiderPickup = riderPickup;
    if (jobRepo.forSorting) jobRepo.selectedRiderPickup = forSorting;

    //package status
    if (jobRepo.regular) jobRepo.selectedPackage = regularPackage;
    if (jobRepo.sayosabon) jobRepo.selectedPackage = sayoSabonPackage;
    if (jobRepo.addOn) {
      jobRepo.selectedPackage = othersPackage;
      jobRepo.selectedPackagePrev = othersPackage;
    }

    //prices
    if (jobRepo.addOn) {
      jobRepo.totalPriceOthers = jobRepo.finalPrice;
      jobRepo.totalPriceRegSS = 0;
    } else {
      jobRepo.totalPriceRegSS = jobRepo.finalPrice;
      jobRepo.totalPriceOthers = 0;
    }

    //payment status
    jobRepo.selectedPaidPartialCash = jobRepo.partialPaidCash;
    jobRepo.selectedPaidPartialGCash = jobRepo.partialPaidGCash;
    jobRepo.partialCashAmountVar.text =
        jobRepo.partialPaidCashAmount.toString();
    jobRepo.partialGCashAmountVar.text =
        jobRepo.partialPaidGCashAmount.toString();
    jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;

    jobRepo.remarksVar.text = jobRepo.remarks;

    //weight status
    if (jobRepo.perKilo) jobRepo.isPerKg = true;
    if (jobRepo.perLoad) jobRepo.isPerKg = false;

    jobRepo.quantityKg = jobRepo.finalKilo;
    jobRepo.quantityLoad = jobRepo.finalLoad;
    jobRepo.remarksVar.text = jobRepo.remarks;

    //list other items
    if (jobRepo.selectedPackage == othersPackage) {
      jobRepo.listSelectedItemModel = List.from(jobRepo.items);
    }

    //other options
    jobRepo.selectedFold = jobRepo.fold;
    jobRepo.selectedMix = jobRepo.mix;
    jobRepo.basketCount = jobRepo.basket;
    jobRepo.ecoBagCount = jobRepo.ebag;
    jobRepo.sakoCount = jobRepo.sako;

    if (jobRepo.selectedPackage != othersPackage) {
      jobRepo.addFabCount = jobRepo.items
          .where((e) => e.itemUniqueId == addFabAnyItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraDryCount = jobRepo.items
          .where((e) => e.itemUniqueId == xDItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraWashCount = jobRepo.items
          .where((e) => e.itemUniqueId == xWashItemModel.itemUniqueId)
          .length;
      jobRepo.addExtraSpinCount = jobRepo.items
          .where((e) => e.itemUniqueId == xSpinItemModel.itemUniqueId)
          .length;
    } else {
      jobRepo.addFabCount = 0;
      jobRepo.addExtraDryCount = 0;
      jobRepo.addExtraWashCount = 0;
      jobRepo.addExtraSpinCount = 0;
    }
  }

  Future<void> saveButtonSetRepository() async {
//dates
    /// 🟣 Dates
    jobRepo.dateQ = Timestamp.now();

    //admin
    jobRepo.createdBy = empIdGlobal;

    setSelectedToRepository(jobRepo);

    await callDatabaseJobQueueUpdate(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  syncRepoToSelected();
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
                    visCustomerNameNoAutoComplete(context, setState, jobRepo),
                    visPaidUnPaid(context, setState, jobRepo),
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
                setState(() {
                  syncRepoToSelected();
                });

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
