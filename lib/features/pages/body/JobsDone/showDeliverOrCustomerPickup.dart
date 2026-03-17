import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';

import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visCustomerNameNoAutoComplete.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visRiderPickup.dart';

void showDeliverOrCustomerPickup(
    BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;

    // //ALLSTATUS = 1
    // /// 🟣 Dates
    // if (jobRepo.selectedIsCustomerPickedUp) {
    //   jobRepo.customerPickupDate = Timestamp.now();
    //   if (!jobRepo.selectedUnpaid) {
    //     if (jobRepo.selectedPaidCash ||
    //         (jobRepo.selectedPaidGCash && jobRepo.selectedPaidGCashVerified)) {
    //       jobRepo.selectedAllStatus = 1;
    //     }
    //   }
    // }

    // if (jobRepo.selectedIsDeliveredToCustomer) {
    //   jobRepo.riderDeliveryDate = Timestamp.now();
    //   if (!jobRepo.selectedUnpaid) {
    //     if (jobRepo.selectedPaidCash ||
    //         (jobRepo.selectedPaidGCash && jobRepo.selectedPaidGCashVerified)) {
    //       jobRepo.selectedAllStatus = 1;
    //     }
    //   }
    // }

    //syncSelectedToRepositorySmall(jobRepo);
    jobRepo.syncSelectedToRepoMin(jobRepo);
    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  // syncRepoToSelectedSmall(jobRepo);
  jobRepo.syncRepoToSelectedMin(jobRepo);
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
            "Change Delivery",
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
                    visCustomerNameNoAutoComplete(context, jobRepo, false),
                    visRiderPickup(context, () => setState(() {}), jobRepo),
                    conRemarks(context, () => setState(() {}),
                        jobRepo.selectedRemarksVar),
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
