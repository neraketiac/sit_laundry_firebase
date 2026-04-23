import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/glassCounterCard.dart';

Widget visEcoBag(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "EcoBag",
    count: jobRepo.selectedEbag,
    highlight: jobRepo.selectedEbag > 0,
    onIncrement: () {
      jobRepo.selectedEbag++;
      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.selectedEbag > 0) jobRepo.selectedEbag--;
      dialogSetState();
    },
  );
}
