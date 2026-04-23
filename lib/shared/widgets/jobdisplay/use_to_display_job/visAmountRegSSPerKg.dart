import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassActionButton.dart';

Visibility visAmountRegSSPerKg(BuildContext context,
    VoidCallback dialogSetState, JobModelRepository jobRepo) {
  jobRepo.repoVarBasePriceAmount = prices[jobRepo.selectedPackage] ?? 155;
  jobRepo.maxPartial = maxPartialOptions[jobRepo.selectedPackage] ?? 3;
  // 🧠 UI rules

  final bool showPointOne = jobRepo.selectedFinalKilo >= 8 &&
      (jobRepo.selectedFinalKilo % 8) < jobRepo.maxPartial;

  jobRepo.repoVarTotalPriceRegSS =
      computeTotalPrice(jobRepo.selectedFinalKilo, jobRepo) +
          jobRepo.repoVarTotalPriceShortCutRegSS;

  // ➕➖ handlers
  void incrementOne() {
    jobRepo.selectedFinalKilo += 1;
    jobRepo.selectedFinalKilo = jobRepo.selectedFinalKilo.floorToDouble();
    resetPaymentStatus(jobRepo);

    dialogSetState();
  }

  void incrementPointOne() {
    jobRepo.selectedFinalKilo =
        double.parse((jobRepo.selectedFinalKilo + 0.1).toStringAsFixed(1));
    resetPaymentStatus(jobRepo);

    dialogSetState();
  }

  void decrementOne() {
    jobRepo.selectedFinalKilo -= 1;
    if (jobRepo.selectedFinalKilo < 1) jobRepo.selectedFinalKilo = 1;
    jobRepo.selectedFinalKilo = jobRepo.selectedFinalKilo.floorToDouble();
    resetPaymentStatus(jobRepo);

    dialogSetState();
  }

  return Visibility(
    visible: false,
    // visible: (jobRepo.selectedPackage == intOthersPackage
    //     ? false
    //     : jobRepo.selectedPerKilo),
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 TOTAL PRICE
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

          /// 📦 QUANTITY DISPLAY
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
                  "${jobRepo.selectedFinalKilo.toStringAsFixed(
                    jobRepo.selectedFinalKilo % 1 == 0 ? 0 : 1,
                  )} kg",
                  style: const TextStyle(
                    fontSize: fontSizeKiloLoad,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                    onTap: () {
                      jobRepo.selectedPerKilo = false;
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
                        "Switch to Load",
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

          /// ➖➕ CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 42),
              glassActionButton(
                label: "−1",
                onTap: decrementOne,
                disabled: jobRepo.selectedFinalKilo <= 1,
              ),
              const SizedBox(width: 12),
              glassActionButton(
                label: "+1",
                onTap: incrementOne,
              ),
              const SizedBox(width: 12),
              Visibility(
                visible: showPointOne,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: glassActionButton(
                  label: "+0.1",
                  onTap: incrementPointOne,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
