import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

void showOnGoingStatus(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;

    //syncSelectedToRepositorySmall(jobRepo);
    jobRepo.syncSelectedToRepoMin(jobRepo);
    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  //syncRepoToSelectedSmall(jobRepo);
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
            "On-Going Status",
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
                    visOnGoingStatus(context, setState, jobRepo),
                  ],
                ),
              ),
            ),
          ),
          // 👇 Bottom buttons
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (jobRepo.selectedProcessStep != 'waiting')
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Action'),
                              content: Text(
                                  'Move #${jobRepo.selectedJobId} ${jobRepo.selectedCustomerNameVar.text} (${jobRepo.selectedFinalLoad}) to Jobs Done?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await moveOngoingToDone(
                              jobRepo.docId,
                              (jobRepo.repoVarSelectedIntRiderPickup ==
                                      intForSorting
                                  ? false
                                  : true));

                          Navigator.pop(context, false);
                        }
                      },
                      child: const Text('Move to Jobs Done?'),
                    ),
                  ),
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
            ),
          ],
        );
      });
    },
  );
}
