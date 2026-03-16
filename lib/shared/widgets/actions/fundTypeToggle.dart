import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/features/payments/repository/gcash_repository.dart';

Widget fundTypeToggle(
  VoidCallback dialogSetState,
  List<int> listIntToSelect,
  GCashRepository gRepo,
) {
  String getFundLabel(int index) {
    const labels = [
      "Cash-in",
      "Load",
      "Cash-Out",
    ];
    return labels[index];
  }

  return Visibility(
    visible: true,
    child: Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔹 TITLE
          Text(
            "Fund Type",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 14),

          /// 🔹 SEGMENTED CONTROL
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withOpacity(0.25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: List.generate(
                listIntToSelect.length,
                (index) {
                  final fundCode = listIntToSelect[index];
                  final isSelected = gRepo.selectedFundCode == fundCode;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        gRepo.selectedFundCode = fundCode;

                        dialogSetState();
                      },

                      /// 👇 DOUBLE TAP LOGIC CLEANLY HERE
                      onDoubleTap: () {
                        if (fundCode == menuOthLaundryPayment) {
                          customerAmountVar.text =
                              (int.tryParse(customerAmountVar.text) ?? 0 + 155)
                                  .toString();
                        }

                        dialogSetState();
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          getFundLabel(index),
                          style: TextStyle(
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
    ),
  );
}
