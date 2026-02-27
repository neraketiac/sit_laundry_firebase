import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showPaidUnpaid(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;
    if (jobRepo.paidCash || jobRepo.paidGCash) {
      jobRepo.paidD = Timestamp.now();
    }
    jobRepo.paymentReceivedBy = empIdGlobal;

    //syncSelectedToRepositorySmall(jobRepo);
    jobRepo.syncSelectedToRepoMin(jobRepo);

    await callDatabaseUpdateJob(context, jobRepo.jobModelData);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  jobRepo.syncRepoToSelectedMin(jobRepo);
  // syncRepoToSelectedSmall(jobRepo);
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
                    visCustomerNameNoAutoComplete(
                        context, setState, jobRepo, false),
                    visPaidUnPaid(context, setState, jobRepo),
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
                  // syncRepoToSelectedSmall(jobRepo);
                  //jobRepo.syncRepoToSelectedMin(jobRepo);
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
