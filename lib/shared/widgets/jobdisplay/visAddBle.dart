import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/jobdisplay/glassCounterCard.dart';

Widget visAddBle(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return glassCounterCard(
    label: "+Ble (₱${addBleItemModel.itemPrice})",
    count: jobRepo.repoVarAddBleCount,
    visible: jobRepo.selectedPackage != intOthersPackage,
    highlight: jobRepo.repoVarAddBleCount > 0,
    onIncrement: () {
      jobRepo.repoVarAddBleCount++;
      jobRepo.selectedItems.add(addBleItemModel);
      jobRepo.repoVarTotalPriceShortCutRegSS += addBleItemModel.itemPrice;

      dialogSetState();
    },
    onDecrement: () {
      if (jobRepo.repoVarAddBleCount > 0) {
        jobRepo.repoVarAddBleCount--;
        jobRepo.selectedItems.remove(addBleItemModel);
        jobRepo.repoVarTotalPriceShortCutRegSS -= addBleItemModel.itemPrice;
      }
      dialogSetState();
    },
  );
}
