import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/glassCounterCard.dart';

Widget visSako(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "Sako",
    count: jobRepo.selectedSako,
    highlight: jobRepo.selectedSako > 0,
    onIncrement: () {
      jobRepo.selectedSako++;
      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.selectedSako > 0) jobRepo.selectedSako--;
      dialogSetState();
    },
  );
}
