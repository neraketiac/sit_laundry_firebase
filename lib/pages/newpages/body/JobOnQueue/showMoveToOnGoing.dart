import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedVisibility.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

void showMoveToOnGoing(BuildContext context, JobModelRepository jobRepo) {
  syncRepoToSelectedSmall(jobRepo);
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
            "Move to On-Going\n"
            "as #${jobRepo.jobId}",
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
                  ],
                ),
              ),
            ),
          ),
          // 👇 Bottom buttons
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Action'),
                      content: Text(
                          'Delete ${jobRepo.customerName} (${jobRepo.finalLoad})?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
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
                  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();
                  await databaseJobsQueue.delete(jobRepo.docId);
                  Navigator.pop(context, false);
                }
              },
              child: const Text('Delete?'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  syncRepoToSelectedSmall(jobRepo);
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

                //final nextJobId = await getNextJobId();

                if (jobRepo.jobId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jobs OnGoing is full, please clean jobs first',
                      ),
                    ),
                  );
                  return false; // ❌ keep dialog open
                }

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Action'),
                      content: Text(
                          'Move ${jobRepo.customerName} (${jobRepo.finalLoad}) to #${jobRepo.jobId} On-Going?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
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

                if (confirm == false) return false;

                if (confirm == true) {
                  await moveQueueToOngoing(jobRepo.docId, jobRepo.jobId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${jobRepo.customerName} ₱ ${jobRepo.finalPrice} added to #${jobRepo.jobId}.',
                      ),
                    ),
                  );
                }

                return true; // ✅ close dialog
              },
            ),
          ],
        );
      });
    },
  );
}
