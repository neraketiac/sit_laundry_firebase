import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/glassCounterCard.dart';

Widget visBasket(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "Basket",
    count: jobRepo.selectedBasket,
    highlight: jobRepo.selectedBasket > 0,
    onIncrement: () {
      jobRepo.selectedBasket++;
      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.selectedBasket > 0) jobRepo.selectedBasket--;
      dialogSetState();
    },
  );
}
