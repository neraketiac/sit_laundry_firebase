import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassBinaryToggle.dart';

Visibility visMix(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return Visibility(
    visible: (jobRepo.selectedPackage != intOthersPackage),
    child: glassBinaryToggle(
      title: "Mix Option",
      leftLabel: "Mix",
      rightLabel: "Don't Mix",
      value: jobRepo.selectedMix,
      onChanged: (val) {
        jobRepo.selectedMix = val;

        dialogSetState();
      },
    ),
  );
}
