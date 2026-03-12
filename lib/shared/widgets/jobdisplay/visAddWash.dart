import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/glassCounterCard.dart';

Widget visAddWash(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "+Wash (₱${xWashItemModel.itemPrice})",
    count: jobRepo.repoVarAddExtraWashCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraWashCount > 0,
    onIncrement: () {
      jobRepo.repoVarAddExtraWashCount++;
      jobRepo.selectedItems.add(xWashItemModel);
      jobRepo.repoVarTotalPriceShortCutRegSS += xWashItemModel.itemPrice;

      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.repoVarAddExtraWashCount > 0) {
        jobRepo.repoVarAddExtraWashCount--;
        jobRepo.selectedItems.remove(xWashItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS -= xWashItemModel.itemPrice;
      }
      dialogSetState();
    },
  );
}
