import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showJobOnQueue(BuildContext context, JobModelRepository jobRepo) {
  //JobModelRepository jobRepo = JobModelRepository();
  Future<void> saveButtonSetRepository() async {
//dates
    /// 🟣 Dates
    jobRepo.dateQ = Timestamp.now();

    //admin
    jobRepo.createdBy = empIdGlobal;

    syncSelectedToRepositoryALL(jobRepo);

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
            "Laundry Request",
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
                    conRemarks(context, setState, jobRepo.remarksVar),
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
                if (jobRepo.customerId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select customer name.')),
                  );
                  return false;
                } else {
                  await saveButtonSetRepository();
                  if (successInsertFB) jobRepo.reset();
                  return true;
                }
              },
            ),
          ],
        );
      });
    },
  );
}
