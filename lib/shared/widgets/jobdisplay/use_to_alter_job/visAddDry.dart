import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/use_to_display_job/glassCounterCard.dart';

Widget visAddDry(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "+Dry (₱${xDItemModel.itemPrice})",
    count: jobRepo.repoVarAddExtraDryCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddExtraDryCount > 0,
    onIncrement: () {
      jobRepo.repoVarAddExtraDryCount++;
      jobRepo.selectedItems.add(xDItemModel);
      jobRepo.repoVarTotalPriceShortCutRegSS += xDItemModel.itemPrice;

      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.repoVarAddExtraDryCount > 0) {
        jobRepo.repoVarAddExtraDryCount--;
        jobRepo.selectedItems.remove(xDItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS -= xDItemModel.itemPrice;
      }

      dialogSetState();
    },
  );
}
