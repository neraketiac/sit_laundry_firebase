import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassBinaryToggle.dart';

Visibility visFold(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return Visibility(
    visible: (jobRepo.selectedPackage != intOthersPackage),
    child: glassBinaryToggle(
      title: "Fold Option",
      leftLabel: "Fold",
      rightLabel: "No Fold",
      value: jobRepo.selectedFold,
      onChanged: (val) {
        jobRepo.selectedFold = val;
        dialogSetState();
      },
    ),
  );
}
