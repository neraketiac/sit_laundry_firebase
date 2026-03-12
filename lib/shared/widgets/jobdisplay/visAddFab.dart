import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/glassCounterCard.dart';

Widget visAddFab(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "+Fab (₱${addFabAnyItemModel.itemPrice})",
    count: jobRepo.repoVarAddFabCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddFabCount > 0,
    onIncrement: () {
      jobRepo.repoVarAddFabCount++;
      jobRepo.selectedItems.add(addFabAnyItemModel);
      jobRepo.repoVarTotalPriceShortCutRegSS += addFabAnyItemModel.itemPrice;

      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.repoVarAddFabCount > 0) {
        jobRepo.repoVarAddFabCount--;
        jobRepo.selectedItems.remove(addFabAnyItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS -= addFabAnyItemModel.itemPrice;
      }
      dialogSetState();
    },
  );
}
