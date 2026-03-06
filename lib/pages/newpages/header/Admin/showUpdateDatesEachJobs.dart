import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showUpdateDatesEachJobs(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    //jobRepo.dateO = adminTimestampDateD;
    //jobRepo.dateC = adminTimestampDateD;
    //jobRepo.customerPickupDate = adminTimestampDateD;
    //jobRepo.riderDeliveryDate = adminTimestampDateD;
    jobRepo.syncSelectedToRepoAll(jobRepo);
    if (!useAdminTimestampDateD) {
      adminTimestampDateD = Timestamp.now();
    }
    jobRepo.dateD = adminTimestampDateD;

    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  syncRepoToSelectedALL(jobRepo);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue.shade600,
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
                    visCustomerNameNoAutoComplete(
                        context, setState, jobRepo, true),
                    visRiderPickup(context, setState, jobRepo),
                    visSelectPackage(context, setState, jobRepo),
                    (jobRepo.selectedPerKilo
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
                    conRemarks(context, setState, jobRepo.selectedRemarksVar),
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
                  syncRepoToSelectedALL(jobRepo);
                });

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
                  if (jobRepo.selectedCustomerId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select customer name.')),
                    );
                    return false;
                  } else {
                    await saveButtonSetRepository();
                    return true;
                  }
                }),
          ],
        );
      });
    },
  );
}
