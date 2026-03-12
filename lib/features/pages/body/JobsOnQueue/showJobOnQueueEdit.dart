import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/Visibility%20visPaidUnPaid.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/conRemarks.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAddDry.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAddFab.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAddSpin.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAddWash.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAmountOthersOnly.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAmountRegSSPerKg.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visAmountRegSSPerLoad.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visBasket.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visCustomerNameNoAutoComplete.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visEcoBag.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visFold.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visMix.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visRiderPickup.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visSako.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/visSelectPackage.dart';

void showJobOnQueueEdit(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    //syncSelectedToRepositoryALL(jobRepo);
    jobRepo.currentEmpId = empIdGlobal;
    if (jobRepo.repoVarSelectedIntRiderPickup == intRiderPickup) {
      jobRepo.selectedAllStatus = 0.10;
    } else {
      jobRepo.selectedAllStatus = 0.20;
    }
    jobRepo.syncSelectedToRepoAll(jobRepo);
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
                    visCustomerNameNoAutoComplete(context, jobRepo, true),
                    visRiderPickup(context, () => setState(() {}), jobRepo),
                    visSelectPackage(context, () => setState(() {}), jobRepo),
                    (jobRepo.selectedPerKilo
                        ? visAmountRegSSPerKg(
                            context, () => setState(() {}), jobRepo)
                        : visAmountRegSSPerLoad(
                            context, () => setState(() {}), jobRepo)),
                    visAmountOthersOnly(
                        context, () => setState(() {}), jobRepo),
                    visPaidUnPaid(context, () => setState(() {}), jobRepo),
                    Text(
                      'Other Options',
                      style: TextStyle(fontSize: 11),
                    ),
                    visFold(context, () => setState(() {}), jobRepo),
                    visMix(context, () => setState(() {}), jobRepo),
                    visBasket(context, () => setState(() {}), jobRepo),
                    visEcoBag(context, () => setState(() {}), jobRepo),
                    visSako(context, () => setState(() {}), jobRepo),
                    Text(
                      'Add Ons',
                      style: TextStyle(fontSize: 11),
                    ),
                    visAddDry(context, () => setState(() {}), jobRepo),
                    visAddFab(context, () => setState(() {}), jobRepo),
                    visAddWash(context, () => setState(() {}), jobRepo),
                    visAddSpin(context, () => setState(() {}), jobRepo),
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
