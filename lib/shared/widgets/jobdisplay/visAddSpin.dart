import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/glassCounterCard.dart';

Widget visAddSpin(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "+Spin (₱${xSpinItemModel.itemPrice})",
    count: jobRepo.repoVarAddExtraSpinCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraSpinCount > 0,
    onIncrement: () {
      jobRepo.repoVarAddExtraSpinCount++;
      jobRepo.selectedItems.add(xSpinItemModel);
      jobRepo.repoVarTotalPriceShortCutRegSS += xSpinItemModel.itemPrice;

      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.repoVarAddExtraSpinCount > 0) {
        jobRepo.repoVarAddExtraSpinCount--;
        jobRepo.selectedItems.remove(xSpinItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS -= xSpinItemModel.itemPrice;
      }
      dialogSetState();
    },
  );
}
