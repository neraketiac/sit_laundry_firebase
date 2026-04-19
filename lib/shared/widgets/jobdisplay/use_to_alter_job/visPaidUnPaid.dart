import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassAmountField.dart';
import 'package:laundry_firebase/shared/widgets/actions/glassPaymentToggle.dart';

Visibility visPaidUnPaid(BuildContext context, VoidCallback dialogSetState,
    JobModelRepository jobRepo) {
  // final List<int> listPaidUnpaid = [
  //   paidCash,
  //   paidGCash,
  // ];

  String returnPaymentStatusDuringToggle() {
    void resetPartialAmount() {
      jobRepo.repoVarCashAmountVar.text = '';
      jobRepo.repoVarGCashAmountVar.text = '';
    }

    void setPartialAmount(TextEditingController controller) {
      //only changed to final price if still no input
      if (controller.text == '' || controller.text == '0') {
        if (jobRepo.finalPrice == 0) {
          if (jobRepo.selectedPackage == intOthersPackage) {
            controller.text = jobRepo.repoVarTotalPriceOthers.toString();
          } else {
            controller.text = jobRepo.repoVarTotalPriceRegSS.toString();
          }
        } else {
          controller.text = jobRepo.selectedFinalPrice.toString();
        }
      }
      // if (jobRepo.selectedPackage == othersPackage) {
      //   if ((int.tryParse(controller.text) ?? 0) < jobRepo.totalPriceOthers) {
      //     controller.text = jobRepo.totalPriceOthers.toString();
      //   }
      // } else {
      //   if ((int.tryParse(controller.text) ?? 0) < jobRepo.totalPriceRegSS) {
      //     controller.text = jobRepo.totalPriceRegSS.toString();
      //   }
      // }
    }

    if (jobRepo.selectedPaidCash && jobRepo.selectedPaidGCash) {
      if (jobRepo.selectedPaidCashAmount == 0 &&
          jobRepo.selectedPaidGCashAmount == 0) {
        resetPartialAmount();
      } else {
        jobRepo.repoVarCashAmountVar.text =
            jobRepo.selectedPaidCashAmount.toString();
        jobRepo.repoVarGCashAmountVar.text =
            jobRepo.selectedPaidGCashAmount.toString();
      }

      return 'Split payment';
    } else if (jobRepo.selectedPaidCash) {
      if (jobRepo.selectedPaidCashAmount == 0) {
        setPartialAmount(jobRepo.repoVarCashAmountVar);
      } else {
        jobRepo.repoVarCashAmountVar.text =
            jobRepo.selectedPaidCashAmount.toString();
      }

      return 'Paid Cash';
    } else if (jobRepo.selectedPaidGCash) {
      if (jobRepo.selectedPaidGCashAmount == 0) {
        setPartialAmount(jobRepo.repoVarGCashAmountVar);
      } else {
        jobRepo.repoVarGCashAmountVar.text =
            jobRepo.selectedPaidGCashAmount.toString();
      }

      return 'Paid GCash';
    }
    resetPartialAmount();
    return 'Unpaid';
  }

  actualPaymentStatus = returnPaymentStatusDuringToggle();

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 💰 STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: jobRepo.selectedUnpaid
                    ? [Colors.redAccent, Colors.orangeAccent]
                    : [Colors.greenAccent, Colors.tealAccent],
              ),
            ),
            child: Text(
              actualPaymentStatus,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 💳 PAYMENT METHOD TOGGLES
          Row(
            children: [
              Expanded(
                child: glassPaymentToggle(
                  label: "Cash",
                  selected: jobRepo.selectedPaidCash,
                  onTap: () {
                    if (!jobRepo.unpaid && jobRepo.paidCash) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Cash payment is already saved and cannot be removed.')),
                      );
                      return;
                    }
                    jobRepo.selectedPaidCash = !jobRepo.selectedPaidCash;
                    actualPaymentStatus = returnPaymentStatusDuringToggle();
                    dialogSetState();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: glassPaymentToggle(
                  label: "GCash",
                  selected: jobRepo.selectedPaidGCash,
                  onTap: () {
                    // prevent reverting to unpaid if already saved as paid
                    if (jobRepo.selectedPaidGCash &&
                        !jobRepo.selectedPaidCash &&
                        !jobRepo.unpaid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Cannot revert to unpaid once payment is saved.')),
                      );
                      return;
                    }
                    jobRepo.selectedPaidGCash = !jobRepo.selectedPaidGCash;
                    actualPaymentStatus = returnPaymentStatusDuringToggle();
                    dialogSetState();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 💵 AMOUNT FIELDS
          Row(
            children: [
              if (jobRepo.selectedPaidCash)
                Expanded(
                  child: glassAmountField(
                    label: "Cash Amount",
                    controller: jobRepo.repoVarCashAmountVar,
                  ),
                ),
              if (jobRepo.selectedPaidCash && jobRepo.selectedPaidGCash)
                const SizedBox(width: 12),
              if (jobRepo.selectedPaidGCash)
                Expanded(
                  child: glassAmountField(
                    label: "GCash Amount",
                    controller: jobRepo.repoVarGCashAmountVar,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          /// ✅ GCASH VERIFIED
          if (jobRepo.selectedPaidGCash)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GCash Verified",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: jobRepo.selectedPaidGCashVerified,
                  activeThumbColor: Colors.greenAccent,
                  onChanged: isAdmin
                      ? (value) {
                          jobRepo.selectedPaidGCashVerified = value;
                          dialogSetState();
                        }
                      : null,
                ),
                if (!isAdmin)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.lock, size: 14, color: Colors.white38),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}
