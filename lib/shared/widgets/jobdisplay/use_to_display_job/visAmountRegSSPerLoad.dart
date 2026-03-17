import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassActionButton.dart';

Visibility visAmountRegSSPerLoad(BuildContext context,
    VoidCallback dialogSetState, JobModelRepository jobRepo) {
  const prices = {
    intRegularPackage: 155,
    intSayoSabonPackage: 125,
    intOthersPackage: 0,
  };

  jobRepo.repoVarBasePriceAmount = prices[jobRepo.selectedPackage] ?? 155;

  jobRepo.repoVarTotalPriceRegSS =
      (jobRepo.repoVarBasePriceAmount * jobRepo.selectedFinalLoad) +
          jobRepo.repoVarTotalPriceShortCutRegSS;

  void incrementOne() {
    jobRepo.selectedFinalLoad += 1;
    resetPaymentStatus(jobRepo);

    dialogSetState();
  }

  void decrementOne() {
    jobRepo.selectedFinalLoad -= 1;
    if (jobRepo.selectedFinalLoad < 1) jobRepo.selectedFinalLoad = 1;
    resetPaymentStatus(jobRepo);

    dialogSetState();
  }

  return Visibility(
    visible: (jobRepo.selectedPackage == intOthersPackage
        ? false
        : !jobRepo.selectedPerKilo),
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28), // ← SAME AS KG
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
            color: Colors.black.withOpacity(0.35),
            blurRadius: 35, // ← SAME DEPTH AS KG
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 TOTAL PRICE (IDENTICAL STYLE)
          Column(
            children: [
              Text(
                "TOTAL",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(jobRepo.repoVarTotalPriceRegSS),
                style: const TextStyle(
                  fontSize: fontSizeTotalPrice,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 3,
                width: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          /// 📦 LOAD DISPLAY (MATCHED SIZE)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "${jobRepo.selectedFinalLoad} load",
                  style: const TextStyle(
                    fontSize: fontSizeKiloLoad, // ← SAME AS KG
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                    onTap: () {
                      jobRepo.selectedPerKilo = true;
                      resetPaymentStatus(jobRepo);
                      dialogSetState();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.purpleAccent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Switch to Kg",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 2),

          /// ➖➕ CONTROLS (SAME BUTTON STYLE)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              glassActionButton(
                label: "−1",
                onTap: decrementOne,
                disabled: jobRepo.selectedFinalLoad <= 1,
              ),
              const SizedBox(width: 12),
              glassActionButton(
                label: "+1",
                onTap: incrementOne,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
