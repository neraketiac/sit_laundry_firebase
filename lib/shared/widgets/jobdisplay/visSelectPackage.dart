import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/showCoolConfirmDialog.dart';

Widget visSelectPackage(
  BuildContext context,
  VoidCallback dialogSetState,
  JobModelRepository jobRepo,
) {
  return Container(
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Label
        Text(
          "     Package Type",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.75),
          ),
        ),

        const SizedBox(height: 2),

        /// 🔥 Segmented Control
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: List.generate(
              listPackage.length,
              (index) {
                final value = listPackage[index];
                final isSelected = jobRepo.selectedPackage == value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // 🔥 Confirmation logic
                      if (jobRepo.selectedPackagePrev == intOthersPackage &&
                          jobRepo.selectedItems.isNotEmpty) {
                        final confirm = await showCoolConfirmDialog(
                          context: context,
                          title: "Change Package?",
                          message: "Items in All Services will be removed.",
                          confirmText: "Yes",
                        );

                        if (!confirm) return;

                        jobRepo.selectedItems.clear();
                        jobRepo.repoVarTotalPriceOthers = 0;
                        usePromoFree = false;

                        //dialogSetState();
                      }

                      jobRepo.selectedPackage = value;
                      jobRepo.selectedPackagePrev = value;

                      if (value == intOthersPackage) {
                        jobRepo.repoVarSelectedItem = listOthItems[0];
                      }

                      resetPaymentStatus(jobRepo);

                      dialogSetState();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.purpleAccent,
                                ],
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        index == 0
                            ? "Regular"
                            : index == 1
                                ? "Sayo Sabon"
                                : "All Services",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
