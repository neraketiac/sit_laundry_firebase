import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showMoveToOnGoing(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
//dates
    /// 🟣 Dates
    jobRepo.dateQ = Timestamp.now();

    //admin
    jobRepo.createdBy = empIdGlobal;

    setSelectedToRepositoryBeforeSave(jobRepo);

    await callDatabaseJobQueueUpdate(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  syncRepoToSelectedBeforePopup(jobRepo);
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
            "Move to On-Going?",
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
                  syncRepoToSelectedBeforePopup(jobRepo);
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
              label: 'Move to On-Going',
              onPressed: () async {
                if (jobRepo.customerId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select customer name.'),
                    ),
                  );
                  return false; // ❌ do NOT close dialog
                }

                final nextJobId = await getNextJobId();

                if (nextJobId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jobs OnGoing is full, please clean jobs first',
                      ),
                    ),
                  );
                  return false; // ❌ keep dialog open
                }

                await moveQueueToOngoing(jobRepo.docId, nextJobId);

                return true; // ✅ close dialog
              },
            ),
          ],
        );
      });
    },
  );
}
