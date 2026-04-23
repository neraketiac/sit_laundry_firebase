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

  // Capture dark mode from the calling context BEFORE showDialog opens
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final isTablet = MediaQuery.of(context).size.width >= 600;

        final dialogBg =
            isDarkMode ? const Color(0xFF0D1117) : Colors.lightBlue.shade600;
        final borderColor =
            isDarkMode ? const Color(0xFF1C2D3F) : Colors.blueAccent;
        final titleColor = isDarkMode ? Colors.white : Colors.black87;
        final labelColor = isDarkMode ? Colors.white60 : Colors.black54;
        final cancelColor = isDarkMode ? Colors.white70 : Colors.black;

        return Dialog(
          backgroundColor: dialogBg,
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
                      color: titleColor,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 2.0)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          visCustomerNameNoAutoComplete(context, jobRepo, true),
                          visRiderPickup(
                              context, () => setState(() {}), jobRepo),
                          visAmountOthersOnly(
                              context, () => setState(() {}), jobRepo),
                          // Payment — locked if already paid (non-admin)
                          if (!jobRepo.unpaid && !isAdmin)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.green.shade700
                                    .withValues(alpha: 0.85),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    jobRepo.paidCash && jobRepo.paidGCash
                                        ? 'Split Payment — Locked'
                                        : jobRepo.paidCash
                                            ? 'Paid Cash — Locked'
                                            : 'Paid GCash — Locked',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          else
                            visPaidUnPaid(
                                context, () => setState(() {}), jobRepo),
                          Text('Other Options',
                              style:
                                  TextStyle(fontSize: 11, color: labelColor)),
                          visFold(context, () => setState(() {}), jobRepo),
                          visMix(context, () => setState(() {}), jobRepo),
                          visBasket(context, () => setState(() {}), jobRepo),
                          visEcoBag(context, () => setState(() {}), jobRepo),
                          visSako(context, () => setState(() {}), jobRepo),
                          Text('Add Ons',
                              style:
                                  TextStyle(fontSize: 11, color: labelColor)),
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
                        child: Text('Cancel',
                            style: TextStyle(color: cancelColor)),
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
