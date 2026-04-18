import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visAddBle.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visPaidUnPaid.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/conRemarks.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visAddDry.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visAddFab.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visAddSpin.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visAddWash.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visAmountOthersOnly.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visBasket.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/visCustomerNameNoAutoComplete.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visEcoBag.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visFold.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visMix.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visRiderPickup.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_alter_job/visSako.dart';

void showJobOnQueueEdit(BuildContext context, JobModelRepository jobRepo) {
  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;
    if (jobRepo.repoVarSelectedIntRiderPickup == intRiderPickup) {
      jobRepo.selectedAllStatus = 0.10;
    } else {
      jobRepo.selectedAllStatus = 0.20;
    }
    jobRepo.syncSelectedToRepoAll(jobRepo);
    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
  }

  jobRepo.syncRepoToSelectedAll(jobRepo);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final isTablet = MediaQuery.of(context).size.width >= 600;
        return Dialog(
          backgroundColor: Colors.lightBlue.shade600,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 40,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 680 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Enter Laundry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blueAccent, width: 2.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          visCustomerNameNoAutoComplete(context, jobRepo, true),
                          visRiderPickup(
                              context, () => setState(() {}), jobRepo),
                          visAmountOthersOnly(
                              context, () => setState(() {}), jobRepo),
                          visPaidUnPaid(
                              context, () => setState(() {}), jobRepo),
                          const Text('Other Options',
                              style: TextStyle(fontSize: 11)),
                          visFold(context, () => setState(() {}), jobRepo),
                          visMix(context, () => setState(() {}), jobRepo),
                          visBasket(context, () => setState(() {}), jobRepo),
                          visEcoBag(context, () => setState(() {}), jobRepo),
                          visSako(context, () => setState(() {}), jobRepo),
                          const Text('Add Ons', style: TextStyle(fontSize: 11)),
                          visAddDry(context, () => setState(() {}), jobRepo),
                          visAddFab(context, () => setState(() {}), jobRepo),
                          visAddBle(context, () => setState(() {}), jobRepo),
                          visAddWash(context, () => setState(() {}), jobRepo),
                          visAddSpin(context, () => setState(() {}), jobRepo),
                          conRemarks(context, () => setState(() {}),
                              jobRepo.selectedRemarksVar),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          jobRepo.syncRepoToSelectedAll(jobRepo);
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black)),
                      ),
                      boxButtonElevated(
                        context: context,
                        label: 'Save',
                        onPressed: () async {
                          if (jobRepo.selectedCustomerId == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select customer name.')),
                            );
                            return false;
                          } else {
                            await saveButtonSetRepository();
                            return true;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
